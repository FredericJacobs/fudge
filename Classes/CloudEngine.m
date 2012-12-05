//
//  CloudEngine.m
//  LocationAndCloudAppTest
//
//  Created by Frederic Jacobs on 5/9/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "CloudEngine.h"
#import "SFHFKeychainUtils.h"
#import "Common.h"

@implementation CloudEngine
@synthesize loginDelegate, imageUploadDelegate;

+ (id)sharedManager {
    static CloudEngine *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        engine = [CLAPIEngine engineWithDelegate:self];
        if ([self isLoggedIn]) {
            engine.email = [SFHFKeychainUtils getPasswordForUsername:kCloudEmailKeychainIdentifier andServiceName:kCloudEmailKeychainIdentifier error:nil];
            engine.password = [SFHFKeychainUtils getPasswordForUsername:kCloudPasswordKeychainIdentifier andServiceName:kCloudPasswordKeychainIdentifier error:nil];
        }
        
    }
    return self;
}

- (void) loginWithUsername:(NSString*)email Password:(NSString*)password AndDelegate:(id<CloudAppLoginDelegate>)toSetdelegate{
    
    engine.clearsCookies = YES;
    engine.email = email;
    loginDelegate = toSetdelegate;
    engine.password = password;
    
    // Validating credentials
    
    [engine getItemListStartingAtPage:1 itemsPerPage:1 userInfo:nil];
    
}

- (void) logoutAndCleanUp{
    
    engine.email = nil;
    engine.password = nil;
    
    [SFHFKeychainUtils deleteItemForUsername:kCloudPasswordKeychainIdentifier andServiceName:kCloudPasswordKeychainIdentifier error:nil];
    [SFHFKeychainUtils deleteItemForUsername:kCloudEmailKeychainIdentifier andServiceName:kCloudEmailKeychainIdentifier error:nil];
    
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
	NSLog(@"[FAIL]: %@, %@", connectionIdentifier, error);
    if (loginDelegate) {
        [loginDelegate loginDidSucceed:FALSE];
    }
}

- (void) itemListRetrievalSucceeded:(NSArray *)items connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo{
    if ([items count] == 1) {
        //Successful auth ! Storing to Keychain
        [SFHFKeychainUtils storeUsername:kCloudEmailKeychainIdentifier andPassword:engine.email forServiceName:kCloudEmailKeychainIdentifier updateExisting:YES error:nil];
        [SFHFKeychainUtils storeUsername:kCloudPasswordKeychainIdentifier andPassword:engine.password forServiceName:kCloudPasswordKeychainIdentifier updateExisting:YES error:nil];
        
        [loginDelegate loginDidSucceed:YES];
        //delegate = nil;
        
    }
    
}

- (void) fileUploadDidSucceedWithResultingItem:(CLWebItem *)item connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo{
    
    [imageUploadDelegate uploadDidComplete:YES WithLink:[[item URL]absoluteString]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    
}

- (void) uploadPictureToCloudApp:(UIImage*)image WithDelegate:(id<CloudAppImageUploadDelegate>)aDelegate{
    
    imageUploadDelegate = aDelegate;
    int r = arc4random() % 100000000000;
    [engine uploadFileWithName:[NSString stringWithFormat:@"fudge-%i.jpg",r] fileData:UIImagePNGRepresentation([CloudEngine imageWithImage:image scaledToSize:CGSizeMake(500, 500)]) userInfo:nil];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    CGSize cgsSourceImage = image.size;
    
    float nPercent = 0.0;
    float nPercentW = 0.0;
    float nPercentH = 0.0;
    
    nPercentW = ((float)newSize.width / (float)cgsSourceImage.width);
    nPercentH = ((float)newSize.height / (float)cgsSourceImage.height);
    
    if(nPercentH < nPercentW){
        nPercent = nPercentH;
    }
    else {
        nPercent = nPercentW;
    }
    
    CGSize destSize;
    destSize.width = (int)(cgsSourceImage.width * nPercent);
    destSize.height = (int)(cgsSourceImage.height * nPercent);
    
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,destSize.width,destSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (NSString*)email {
    return engine.email;
}

- (BOOL) isLoggedIn {
    
    NSError *error = nil;
    NSString *password = [SFHFKeychainUtils getPasswordForUsername:kCloudPasswordKeychainIdentifier
                                                     andServiceName:kCloudPasswordKeychainIdentifier error:&error];
    
    NSString *username = [SFHFKeychainUtils getPasswordForUsername:kCloudEmailKeychainIdentifier
                                                    andServiceName:kCloudEmailKeychainIdentifier error:&error];
    
    if(password == nil || username == nil)
    {
        [SFHFKeychainUtils deleteItemForUsername:kCloudPasswordKeychainIdentifier andServiceName:kCloudPasswordKeychainIdentifier error:&error];
        [SFHFKeychainUtils deleteItemForUsername:kCloudEmailKeychainIdentifier andServiceName:kCloudEmailKeychainIdentifier error:&error];
        return NO;
    }
    
    else return YES;    

}

@end

