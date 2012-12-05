//
//  AppDotNetSyncingEngine.h
//  Tapp
//
//  Created by Frederic Jacobs on 22/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISO8601DateFormatter.h"
#import "Stream.h"
#import "User.h"

@interface AppDotNetSyncingEngine : NSObject{
    ISO8601DateFormatter *formatter;
    BOOL dbIsReady;
}

typedef enum {
    kHomeTimeline,
    kMentions,
    kSearch,
    kUserPosts,
    kThread
} StreamType;

- (User*) currentUser;

+ (id)sharedManager;
- (BOOL) userIsLoggedIn;
- (void) loginWithUsername:(NSString*) username AndToken:(NSString*) token;
- (NSString*) token ;
- (NSString*) username;
- (void) composeResponseForPost:(Post*)post;
-(void) wipeAuthCredentials;
- (ISO8601DateFormatter*) dateFormatter;
- (Stream*) streamOfType:(StreamType)streamType andParameter:(NSString*)string;

@property (nonatomic, strong) UIManagedDocument *fudgeDatabase;
@property BOOL dbIsReady;

@end
