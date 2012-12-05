//
//  RepliesViewController.m
//  Tapp
//
//  Created by Frederic Jacobs on 23/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "RepliesViewController.h"
#import "ANSession.h"
#import "AppDotNetSyncingEngine.h"
#import "AppDelegate.h"
#import "Post+Fetch.h"
#import "Stream.h"

@interface RepliesViewController ()

@end

@implementation RepliesViewController
@synthesize navController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

+ (Stream*) stream {
    
    return [[AppDotNetSyncingEngine sharedManager] streamOfType:kMentions andParameter:nil];;
    
}

- (void) loadFromScratch {
    
}


- (void) setRead{
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"finishedReadingMentions"
     object:self];
    
    
}

- (Stream*) stream {
    
    return [[AppDotNetSyncingEngine sharedManager] streamOfType:kMentions andParameter:nil];;
    
}

- (void) getNewStreamPosts {
    
    Stream *stream = [self stream];
    
    // Let's first check if we do have older posts
    
    NSFetchRequest *lastIDRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    
    lastIDRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]];
    
    lastIDRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY inStream == %@)", stream];
    
    [lastIDRequest setFetchLimit:1];
    
    NSError *error = nil;
    
    NSArray *IDmatches = [[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext] executeFetchRequest:lastIDRequest error: &error];
    
    long long postId ;
    
    // One match, fetch newer posts
    
    if ([IDmatches count] == 1) {
        
        Post *post = [IDmatches objectAtIndex:0];
        
        postId = [post.id longLongValue];
        
        [ANSession.defaultSession postsMentioningUserWithID:ANMeUserID betweenID:postId andID:ANUnspecifiedPostID completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
            if (error) {
                [self stopLoading];
                return ;
            }
            
            if (posts != nil) {
                
                NSMutableArray *removeDeleted = [NSMutableArray arrayWithArray:posts];
                
                for (int i = 0; i < [removeDeleted count]; i++) {
                    if ([[removeDeleted objectAtIndex:i] isDeleted]) {
                        [removeDeleted removeObjectAtIndex:i];
                        i--;
                    }
                }
                
                for (ANPost *post in removeDeleted){
                    
                    [Post postWithAppNetInfo:post inManagedObjectContext:[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext] inStream:stream];
                    
                }
                
                stream.refreshedAt = [NSDate date];
                
                [self stopLoading];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"mentionsStreamDidUpdate"
                 object:nil];
                
                
            }
            
        }];
        
        
    }
    
    // No match, fetch 20 newest posts
    
    else {
        
        [ANSession.defaultSession postsMentioningUserWithID:ANMeUserID betweenID:ANUnspecifiedPostID andID:ANUnspecifiedPostID completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
            
            if (error) {
                [self stopLoading];
                return ;
            }
            
            
            NSMutableArray *removeDeleted = [NSMutableArray arrayWithArray:posts];
            
            for (int i = 0; i < [removeDeleted count]; i++) {
                if ([[removeDeleted objectAtIndex:i] isDeleted]) {
                    [removeDeleted removeObjectAtIndex:i];
                    i--;
                }
            }
            
            for (ANPost *post in removeDeleted){
                
                [Post postWithAppNetInfo:post inManagedObjectContext:[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext] inStream:stream];
                
            }
            
            stream.refreshedAt = [NSDate date];
            
            [self stopLoading];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"mentionsStreamDidUpdate"
             object:nil];
            
        }];
        
    }
    
}


- (void) getMoreStreamPosts{
    
    Stream *stream = [self stream];
    
    NSFetchRequest *lastIDRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    
    lastIDRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]];
    [lastIDRequest setFetchLimit:1];
    Stream *theStream = [self stream];
    lastIDRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY inStream == %@)", theStream];
    
    NSError *error = nil;
    
    NSArray *matches = [[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext] executeFetchRequest:lastIDRequest error: &error];
    
    long long postId ;
    
    if ([matches count] == 1) {
        
        Post *aPost = [matches objectAtIndex:0];
        
        postId = [aPost.id longLongValue];
        
        isGettingMore = TRUE;
        
        
        [ANSession.defaultSession postsMentioningUserWithID:ANMeUserID betweenID:  ANUnspecifiedPostID andID:postId completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
            if (error) {
                [self stopLoading];
                
                isGettingMore = FALSE;
                
                return ;
            }
            
            
            if (posts != nil) {
                
                NSMutableArray *removeDeleted = [NSMutableArray arrayWithArray:posts];
                
                for (int i = 0; i < [removeDeleted count]; i++) {
                    if ([[removeDeleted objectAtIndex:i] isDeleted]) {
                        [removeDeleted removeObjectAtIndex:i];
                        i--;
                    }
                }
                
                for (ANPost *post in removeDeleted){
                    
                    
                    [Post postWithAppNetInfo:post inManagedObjectContext:[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext]inStream:stream];
                    
                }
                
                isGettingMore = false;
            }
            
        }];
        
        
    }
    
    else{
        NSLog(@"Shouldn't happen");
    }
    
}

- (NSString*) titleForBanner {
    
    return @"Replies";
}

- (void) viewWillAppear:(BOOL)animated {
    
    
    UIImage *gradientImage44 = [[UIImage imageNamed:@"navbar-background.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.navigationController.navigationBar setBackgroundImage:gradientImage44
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.clipsToBounds = YES;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
