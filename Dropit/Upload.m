//
//  Upload.m
//  Dropit
//
//  Created by John Hobbs on 4/9/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import "Upload.h"
#import "Configuration.h"

#import <sys/stat.h>
#import <AFNetworking/AFNetworking.h>

@implementation Upload

+ (NSNumber *)sizeInBytes:(NSURL *)pathURL {
    struct stat fstat;
    if(stat([pathURL fileSystemRepresentation], &fstat)) {
        return nil;
    }
    return [NSNumber numberWithLongLong:fstat.st_size];
}

+ (NSString *)mimeType:(NSString *)extension {
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)(extension),
                                                            NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if(MIMEType) {
        return (__bridge_transfer NSString *)MIMEType;
    }
    else {
        CFRelease(MIMEType);
        return @"application/octet-stream";
    }
    
}

- (id)initWithURL:(NSURL *)fileURL {
    // Yuck
    NSString *filePath = [fileURL path];
    NSArray *pathParts = [filePath componentsSeparatedByString:@"/"];
    NSString *fileName = pathParts[[pathParts count]-1];
    NSArray *filenameParts = [fileName componentsSeparatedByString:@"."];
    NSString *extension = filenameParts[[filenameParts count]-1];

    self = [self initWithURL:fileURL mimeType:[Upload mimeType:extension] fileName:fileName];
    
    return self;
}

- (id)initWithURL:(NSURL *)fileURL mimeType:(NSString *)mimeType fileName:(NSString *)fileName {
    self = [super init];
    
    if(self) {
        self.fileURL = fileURL;
        self.filename = fileName;
        self.mimeType = mimeType;
        self.size = [Upload sizeInBytes:fileURL];
    }
    
    return self;
    
}

- (void)changeState:(UploadState)state {
    self.state = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:UploadStateChangedNotification
                                                        object:self
                                                      userInfo:@{kUploadState: @(self.state)}];
}

- (AFHTTPRequestOperationManager *)getAPIHTTPRequestManager {
    AFHTTPRequestOperationManager *apiManager = [[AFHTTPRequestOperationManager alloc] init];
    apiManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [apiManager.requestSerializer setAuthorizationHeaderFieldWithUsername:DROPIT_USERNAME password:DROPIT_PASSWORD];
    return apiManager;
}

- (void)start {
    [self changeState:UploadStateSigning];
    
    NSLog(@"Start: %@ : %@ : %@", _filename, _mimeType, _size);
    
    AFHTTPRequestOperationManager *manager = [self getAPIHTTPRequestManager];
    AFHTTPRequestOperation *sign = [manager POST:[NSString stringWithFormat:@"%@/upload/sign", DROPIT_SERVER]
                                      parameters:@{@"filename": _filename, @"content_type": _mimeType, @"size": _size}
                       constructingBodyWithBlock:nil
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             
                                             [self changeState:UploadStateSigned];
                                             
                                             self.token     = responseObject[@"token"];
                                             self.viewURL   = responseObject[@"view_url"];
                                             self.directURL = responseObject[@"direct_url"];
                                             
                                             [[NSNotificationCenter defaultCenter] postNotificationName:UploadCreatedNotification
                                                                                                 object:self
                                                                                               userInfo:@{kUploadDirectURL: self.directURL,
                                                                                                          kUploadViewURL: self.viewURL}];
                                             
                                             NSDictionary *params = @{
                                                  @"key": responseObject[@"key"],
                                                  @"AWSAccessKeyId": responseObject[@"AWSAccessKeyId"],
                                                  @"acl": responseObject[@"acl"],
                                                  @"success_action_status": responseObject[@"success_action_status"],
                                                  @"policy": responseObject[@"policy"],
                                                  @"signature": responseObject[@"signature"],
                                                  @"content-type": self.mimeType
                                              };
                                             
                                             [self upload:responseObject[@"upload_url"] params:params];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Failure :(");
                                             NSLog(@"%@", error);
                                             [self changeState:UploadStateFailed];
                                         }];
    [sign start];
    
}

- (void)upload:(NSString *)uploadURL params:(NSDictionary *)params {
    [self changeState:UploadStateUploading];
    
    NSLog(@"Upload: %@ : %@ : %@", uploadURL, _filename, _mimeType);
    
    AFHTTPRequestOperationManager *s3Manager = [[AFHTTPRequestOperationManager alloc] init];
    AFHTTPRequestOperation *op = [s3Manager POST:uploadURL
                                      parameters:params
                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                           NSError *error;
                           [formData appendPartWithFileURL:self.fileURL
                                                      name:@"file"
                                                  fileName:self.filename
                                                  mimeType:self.mimeType
                                                     error:&error];
                           if(error) {
                               // TODO
                               [self changeState:UploadStateFailed];
                               NSLog(@"Error: %@", error);
                           }
                       } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           NSLog(@"Success: %@", operation.responseString);
                           [self changeState:UploadStateUploaded];
                           [self complete];
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           NSLog(@"Error:\n%@\n\n%@", operation.responseString, error);
                       }];
    
    [op setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        float progress = (float) totalBytesWritten / (float) totalBytesExpectedToWrite;
        self.uploadProgress = progress;
        [[NSNotificationCenter defaultCenter] postNotificationName:UploadProgressNotification
                                                            object:self
                                                          userInfo:@{kUploadProgress: [NSNumber numberWithFloat:progress]}];
    }];
    
    
    [op start];
}

- (void)complete {
    
    [self changeState:UploadStateCompleting];
    
    AFHTTPRequestOperationManager *manager = [self getAPIHTTPRequestManager];
    AFHTTPRequestOperation *complete = [manager POST:[NSString stringWithFormat:@"%@/upload/complete", DROPIT_SERVER]
                                             parameters:@{@"token": self.token}
                              constructingBodyWithBlock:nil
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                    NSLog(@"%@", self.directURL);
                                                    [self changeState:UploadStateComplete];
                                                }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    NSLog(@"Error: %@", error);
                                                    [self changeState:UploadStateUploaded];
                                                }];
    [complete start];
}

@end
