//
//  AppDotNetSyncingEngine.m
//  Tapp
//
//  Created by Frederic Jacobs on 22/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "AppDotNetSyncingEngine.h"
#import "SFHFKeychainUtils.h"
#import "Common.h"
#import "PostModalViewController.h"
#import "AppDelegate.h"
#import "Stream.h"
#import "Post.h"
#import "FGNotificationEngine.h"

@implementation AppDotNetSyncingEngine

@synthesize dbIsReady;

@synthesize fudgeDatabase;

+ (id)sharedManager {
    static AppDotNetSyncingEngine *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        sharedMyManager.dbIsReady = FALSE;
    });
    return sharedMyManager;
}

- (User*) currentUser {
    
    User *me = nil;
    NSError *error = nil;
    
    NSFetchRequest *userRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    userRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES]];
    [userRequest setFetchLimit:1];
    
    NSString *username = [self username];
    
    userRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", username];
    NSArray *matches = [[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext] executeFetchRequest:userRequest error: &error];
    
    me = [matches objectAtIndex:0];

    return me;
}

- (void) composeResponseForPost:(Post*)post {
    
    AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    PostModalViewController *vc5 = [[PostModalViewController alloc] initWithReplyToPost:post];
    UINavigationController *nvc5 =  [[UINavigationController alloc] initWithRootViewController:vc5];
    
    nvc5.navigationBar.clipsToBounds = YES;
    
    [myAppDelegate.theRootViewController presentViewController:nvc5 animated:YES completion:nil];
    
}

- (Stream*) streamOfType:(StreamType)streamType andParameter:(NSString*)string {
    
    Stream *stream = nil;
    NSString *timelineString = nil;
    NSString *username = nil;
    NSError *error = nil;
    
    NSFetchRequest *timelineRequest = [NSFetchRequest fetchRequestWithEntityName:@"Stream"];
    
    timelineRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]];
    [timelineRequest setFetchLimit:1];
    
    if (streamType == kHomeTimeline){
       
        timelineString = @"home" ;
        
    }
    
    else if (streamType == kMentions){
        timelineString = @"mentions" ;
    }
    
    else if (streamType == kThread){
        timelineString = @"thread";
    }
    
    else if (streamType == kSearch){
        timelineString = @"search";
    }
    
    else if (streamType == kUserPosts){
        timelineString = @"user";
    }
        
    if (!string) {
        
        username = [[AppDotNetSyncingEngine sharedManager] username];
        
    }
    else {
        username = string;
    }
    
    timelineRequest.predicate = [NSPredicate predicateWithFormat:@"type == %@ AND identifier == %@",timelineString, username];
    NSArray *matches = [[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext] executeFetchRequest:timelineRequest error: &error];
    
    if ([matches count] == 1) {
        
        stream = [matches objectAtIndex:0];
        
        //NSLog(@"%@ (%@)has been queried and has %i posts", [stream type], [stream identifier], [[stream post] count]);
        
    }
    
    else if ([matches count] == 0){
        
        stream = [NSEntityDescription insertNewObjectForEntityForName:@"Stream" inManagedObjectContext:[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext]];
        stream.type = timelineString;
        stream.identifier = username;
        stream.seenPostDate = [NSDate dateWithTimeIntervalSince1970:0];
        
        //NSLog(@"%@ (%@)has been queried and has no posts", [stream type], [stream identifier]);
        
    }
    
    else {
        NSLog(@"EOW Exception : Shouldn't happen");
    }
    
    return stream;
    
}


- (ISO8601DateFormatter*) dateFormatter {
    return formatter;
}

- (id)init {
    if (self = [super init]) {
        formatter = [ISO8601DateFormatter new];
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"FudgeDB"];
        self.fudgeDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
    return self;
}

- (void)setFudgeDatabase:(UIManagedDocument *)newDB
{
    if (fudgeDatabase != newDB) {
        fudgeDatabase = newDB;
        [self useDocument];
    }
}

- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.fudgeDatabase.fileURL path]]) {
        // does not exist on disk, so create it
        [self.fudgeDatabase saveToURL:self.fudgeDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            
            if (!success) {
                NSLog(@"Failed to open db");
                dbIsReady = FALSE ;
            }
            
            if (success) {
                dbIsReady = TRUE;
                [self updateMyDetails];
                [[FGNotificationEngine sharedManager]initialize];
            }
            
        }];
    } else if (self.fudgeDatabase.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.fudgeDatabase openWithCompletionHandler:^(BOOL success) {
            
            if (!success) {
                NSLog(@"Failed to open db");
                dbIsReady = FALSE ;
            }
            
            if (success) {
                dbIsReady = TRUE;
                [self updateMyDetails];
                [[FGNotificationEngine sharedManager]initialize];
            }
        }];
    } else if (self.fudgeDatabase.documentState == UIDocumentStateNormal) {
        dbIsReady = TRUE;
        [[FGNotificationEngine sharedManager]initialize];
    }
}

- (void) updateMyDetails {

    [[ANSession defaultSession] userWithID:ANMeUserID completion:^(ANResponse *response, ANUser *updatedUser, NSError *error){
        
        if (error) {
            return ;
        }
        
        else if (updatedUser){
        
        NSFetchRequest *userRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        
        userRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES]];
        [userRequest setFetchLimit:1];
        
        NSString *username = [self username];
        
        userRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", username];
        NSArray *matches = [[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext] executeFetchRequest:userRequest error: &error];
        
        if ([matches count] == 1) {
            
            User *user = nil;
            
            user = [matches objectAtIndex:0];
            user.bio = updatedUser.userDescription.text;
            user.fullname = updatedUser.name;
            user.follower_count = [NSNumber numberWithInt:updatedUser.counts.followers];
            user.following_count = [NSNumber numberWithInt:updatedUser.counts.following];
            user.followingHim = [NSNumber numberWithBool:updatedUser.youFollow];
            user.followsMe = [NSNumber numberWithBool:updatedUser.followsYou];
            user.username = updatedUser.username;
            user.joined_date = updatedUser.createdAt;
            user.muted = [NSNumber numberWithBool:updatedUser.youMuted];
            user.posts_count = [NSNumber numberWithInt:updatedUser.counts.posts];
            user.coverPictureURL = [updatedUser.coverImage.URL absoluteString];
            user.profilePictureURL = [updatedUser.avatarImage.URL absoluteString];
            
        }
        else if ([matches count] == 0){
            
            // if he doesn't we fill everything in
            NSLog(@"No match, creating user");
            User *user = nil;
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[fudgeDatabase managedObjectContext]];
            user.fullname = updatedUser.name;
            user.userID = [NSNumber numberWithInt:updatedUser.ID];
            user.bio = updatedUser.userDescription.text;
            user.follower_count = [NSNumber numberWithInt:updatedUser.counts.followers];
            user.following_count = [NSNumber numberWithInt:updatedUser.counts.following];
            user.followingHim = [NSNumber numberWithBool:updatedUser.youFollow];
            user.followsMe = [NSNumber numberWithBool:updatedUser.followsYou];
            user.username = updatedUser.username;
            user.joined_date = updatedUser.createdAt;
            user.muted = [NSNumber numberWithBool:updatedUser.youMuted];
            user.posts_count = [NSNumber numberWithInt:updatedUser.counts.posts];
            user.coverPictureURL = [updatedUser.coverImage.URL absoluteString];
            user.profilePictureURL = [updatedUser.avatarImage.URL absoluteString];
        }
            
        } 
    }];
}

- (NSString*) username{
    
    return [SFHFKeychainUtils getPasswordForUsername:kAppDotNetUsernameKeychainIdentifier andServiceName:kAppDotNetUsernameKeychainIdentifier error:nil];
    
}

- (NSString*) token {
    
    return [SFHFKeychainUtils getPasswordForUsername:kAppDotNetTokenKeychainIdentifier andServiceName:kAppDotNetTokenKeychainIdentifier error:nil];
    
}

-(BOOL) userIsLoggedIn
{
    NSError *error = nil;
    NSString *authToken = [SFHFKeychainUtils getPasswordForUsername:kAppDotNetTokenKeychainIdentifier
                                                     andServiceName:kAppDotNetTokenKeychainIdentifier error:&error];
    
    NSString *username = [SFHFKeychainUtils getPasswordForUsername:kAppDotNetUsernameKeychainIdentifier
                                                    andServiceName:kAppDotNetUsernameKeychainIdentifier error:&error];
    
    if(authToken == nil || username == nil)
    {
        [SFHFKeychainUtils deleteItemForUsername:kAppDotNetTokenKeychainIdentifier andServiceName:kAppDotNetTokenKeychainIdentifier error:&error];
        [SFHFKeychainUtils deleteItemForUsername:kAppDotNetUsernameKeychainIdentifier andServiceName:kAppDotNetUsernameKeychainIdentifier error:&error];
        return NO;
    }
    else return YES;
}

- (void) loginWithUsername:(NSString*) username AndToken:(NSString*) token{
    
    [SFHFKeychainUtils storeUsername:kAppDotNetTokenKeychainIdentifier andPassword:token forServiceName:kAppDotNetTokenKeychainIdentifier updateExisting:YES error:nil];
    [SFHFKeychainUtils storeUsername:kAppDotNetUsernameKeychainIdentifier andPassword:username forServiceName:kAppDotNetUsernameKeychainIdentifier updateExisting:YES error:nil];
    
}

-(void) wipeAuthCredentials
{
    NSError *error = nil;
    
    [SFHFKeychainUtils deleteItemForUsername:kAppDotNetUsernameKeychainIdentifier andServiceName:kAppDotNetUsernameKeychainIdentifier error:&error];
    [SFHFKeychainUtils deleteItemForUsername:kAppDotNetTokenKeychainIdentifier andServiceName:kAppDotNetTokenKeychainIdentifier error:&error];
    
    [SFHFKeychainUtils storeUsername:nil andPassword:nil forServiceName:kAppDotNetUsernameKeychainIdentifier updateExisting:YES error:&error];
    [SFHFKeychainUtils storeUsername:nil andPassword:nil forServiceName:kAppDotNetTokenKeychainIdentifier updateExisting:YES error:&error];
    
    [NSUserDefaults resetStandardUserDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSFileManager defaultManager] removeItemAtURL:self.fudgeDatabase.fileURL error:nil];
}



@end
