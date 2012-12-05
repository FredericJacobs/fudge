//
//  FGNotificationEngine.m
//  Fudge
//
//  Created by Frederic Jacobs on 10/10/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "FGNotificationEngine.h"
#import "Stream.h"
#import "Post.h"
#import "AppDotNetSyncingEngine.h"
#import "AppDelegate.h"
#import "StreamViewController.h"
#import "RepliesViewController.h"

@implementation FGNotificationEngine

+ (id)sharedManager {
    static FGNotificationEngine *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(scrollFeedsAndSetTabBarForTimeLine)
                                                     name:@"homeStreamDidUpdate"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(scrollFeedsAndSetTabBarForMentions)
                                                     name:@"mentionsStreamDidUpdate"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hometimeLineHasBeenRead)
                                                     name:@"finishedReadingHomeStream"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mentionsHaveBeenRead)
                                                     name:@"finishedReadingMentions"
                                                   object:nil];

        
    }
    return self;
}


- (void) initialize {
    
    [self refresh];
}

- (void) refresh {
    
    AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    StreamViewController *stream = (StreamViewController*)[[myAppDelegate theRootViewController] timeLineOfType:kHomeTimeLineVC];
    RepliesViewController *repliesstream = (RepliesViewController*)[[myAppDelegate theRootViewController] timeLineOfType:kMentionsTimeLineVC];
    
    [stream getNewStreamPosts];
    [repliesstream getNewStreamPosts];
    
    [timer invalidate];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(refresh) userInfo:nil repeats:NO];
    
}

- (void) scrollFeedsAndSetTabBarForTimeLine {
    
    Post *post = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(ANY inStream == %@)", [[AppDotNetSyncingEngine sharedManager] streamOfType:kHomeTimeline andParameter:nil]];
    
    request.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *matches = [[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase]managedObjectContext] executeFetchRequest:request error:&error];
    
    post = [matches objectAtIndex:0];
    
    Stream *stream = [[AppDotNetSyncingEngine sharedManager] streamOfType:kHomeTimeline andParameter:nil];
    
    NSLog(@"%@ and %@", post.created_at, stream.seenPostDate);

    
    if ([post.created_at timeIntervalSinceDate:stream.seenPostDate] > 0) {
        
        // Scroll to old
        AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
            
        [myAppDelegate.theRootViewController setTimelineRead:NO];
            
    }
    
}

- (void) scrollFeedsAndSetTabBarForMentions {
    
    
    Post *post = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(ANY inStream == %@)", [[AppDotNetSyncingEngine sharedManager] streamOfType:kMentions andParameter:nil]];
    
    request.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *matches = [[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase]managedObjectContext] executeFetchRequest:request error:&error];
    
    post = [matches objectAtIndex:0];
    
    Stream *stream = [[AppDotNetSyncingEngine sharedManager] streamOfType:kMentions andParameter:nil];
    
    NSLog(@"Mentions : %@ and %@", post.created_at, stream.seenPostDate);

    
    if ([post.created_at timeIntervalSinceDate:stream.seenPostDate] > 0) {
        
        AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [myAppDelegate.theRootViewController setMentionsRead:NO];
        
    }
}


- (void) mentionsHaveBeenRead{
    
    AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [myAppDelegate.theRootViewController setMentionsRead:YES];
    
    Stream *stream = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Stream"];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:NO]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"type == %@", @"mentions"];
    
    request.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *matches = [[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase]managedObjectContext] executeFetchRequest:request error:&error];
    
    if ([matches count] == 1) {
        stream = [matches objectAtIndex:0];
        stream.seenPostDate = [self dateOfLatestMentionPost];
    }

    
}

-(void) hometimeLineHasBeenRead{
    
    AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [myAppDelegate.theRootViewController setTimelineRead:YES];
    
    Stream *stream = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Stream"];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:NO]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"type == %@", @"home"];
    
    request.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *matches = [[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase]managedObjectContext] executeFetchRequest:request error:&error];
    
    if ([matches count] == 1) {
        stream = [matches objectAtIndex:0];
        stream.seenPostDate = [self dateOfLatestPost];
        
        NSLog(@"%@ is now the latest post", stream.seenPostDate);
    }

    
}


- (NSDate*) dateOfLatestPost {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(ANY inStream == %@)", [[AppDotNetSyncingEngine sharedManager] streamOfType:kHomeTimeline andParameter:nil]];
    
    request.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *matches = [[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase]managedObjectContext] executeFetchRequest:request error:&error];
    
    Post *post = [matches objectAtIndex:0];
    
    return post.created_at;
}

- (NSDate*) dateOfLatestMentionPost {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(ANY inStream == %@)", [[AppDotNetSyncingEngine sharedManager] streamOfType:kMentions andParameter:nil]];
    
    request.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *matches = [[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase]managedObjectContext] executeFetchRequest:request error:&error];
    
    Post *post = [matches objectAtIndex:0];
    
    return post.created_at;
}


@end
