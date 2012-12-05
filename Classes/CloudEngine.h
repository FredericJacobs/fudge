//
//  CloudEngine.h
//  LocationAndCloudAppTest
//
//  Created by Frederic Jacobs on 5/9/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cloud.h"
#import "CloudAppImageUploadDelegate.h"
#import "CloudAppLoginDelegate.h"

@interface CloudEngine : NSObject<CLAPIEngineDelegate>{
    CLAPIEngine *engine;
    id<CloudAppLoginDelegate> loginDelegate;
    id<CloudAppImageUploadDelegate> imageUploadDelegate;
}

+ (id)sharedManager;

@property (nonatomic, readwrite) id<CloudAppLoginDelegate> loginDelegate;
@property (nonatomic, readwrite) id<CloudAppImageUploadDelegate> imageUploadDelegate;

- (void) loginWithUsername:(NSString*)email Password:(NSString*)password AndDelegate:(id<CloudAppLoginDelegate>)delegate;
- (void) uploadPictureToCloudApp:(UIImage*)image WithDelegate:(id<CloudAppImageUploadDelegate>)aDelegate;
- (BOOL) isLoggedIn;
- (NSString*)email;
- (void) logoutAndCleanUp;

@end
