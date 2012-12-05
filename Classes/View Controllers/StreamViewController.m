//
//  FirstViewController.m
//  Tapp
//
//  Created by Frederic Jacobs on 20/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "StreamViewController.h"
#import "AppDelegate.h"
#import "ANSession.h"
#import "AppDotNetSyncingEngine.h"
#import "Post+Fetch.h"
#import "Stream.h"


@interface StreamViewController ()

@end

@implementation StreamViewController


#pragma mark Initializing

- (Stream*) stream {
    
    if ([[AppDotNetSyncingEngine sharedManager]dbIsReady]) {
        
        return [[AppDotNetSyncingEngine sharedManager] streamOfType:kHomeTimeline andParameter:nil];
    }
    else {
        return nil;
    }

}


+ (Stream*) stream {
    
    if ([[AppDotNetSyncingEngine sharedManager]dbIsReady]) {
        
        return [[AppDotNetSyncingEngine sharedManager] streamOfType:kHomeTimeline andParameter:nil];
    }
    else {
        return nil;
    }
    
}

- (void) setRead{
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"finishedReadingHomeStream"
     object:self];

    
}

- (void) viewWillAppear:(BOOL)animated {
    
    
    UIImage *gradientImage44 = [[UIImage imageNamed:@"navbar-background.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.navigationController.navigationBar setBackgroundImage:gradientImage44
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.clipsToBounds = YES;
    
}


- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]];    
    
    Stream *stream = [self stream];
    
    if (stream) {
    
        request.predicate = [NSPredicate predicateWithFormat:@"(ANY inStream == %@)", [self stream]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext]
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        
    }
    
    else {
        
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(setFetchResultController)
                                       userInfo:nil
                                        repeats:NO];
        
    }
    
}

- (void) getNewStreamPosts {
    
    Stream *stream = [self stream];
    
    // Let's first check if we do have older posts
    
    NSFetchRequest *lastIDRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    
    lastIDRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]];
    [lastIDRequest setFetchLimit:1];
    
    lastIDRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY inStream == %@)", stream];
    
    NSError *error = nil;
    
    NSArray *IDmatches = [[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext] executeFetchRequest:lastIDRequest error: &error];
    
    long long postId ;
    
    // One match, fetch newer posts
    
    if ([IDmatches count] == 1) {
        
        Post *post = [IDmatches objectAtIndex:0];
        
        postId = [post.id longLongValue];
        
        [ANSession.defaultSession postsInStreamBetweenID:postId andID:ANUnspecifiedPostID completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
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
                 postNotificationName:@"homeStreamDidUpdate"
                 object:nil];
            }
            
        }];
        
        
    }
    
    // No match, fetch 20 newest posts
    
    else {
        
        [ANSession.defaultSession postsInStreamWithCompletion:^(ANResponse *response, NSArray *posts, NSError *error){
            
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
             postNotificationName:@"homeStreamDidUpdate"
             object:nil];
            
        }];
        
    }
    
}


- (void) getMoreStreamPosts{
    
    
    Stream *stream = [self stream];
    
    NSFetchRequest *lastIDRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    
    lastIDRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]];
    [lastIDRequest setFetchLimit:1];

    lastIDRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY inStream == %@)", stream];
    
    NSError *error = nil;
    
    NSArray *matches = [[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext] executeFetchRequest:lastIDRequest error: &error];
    
    long long postId ;
    
    if ([matches count] == 1) {
        
        Post *aPost = [matches objectAtIndex:0];
        
        postId = [aPost.id longLongValue];
        
        isGettingMore = TRUE;
        
        [ANSession.defaultSession postsInStreamBetweenID: ANUnspecifiedPostID andID:postId completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
            if (error) {
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

- (void) loadFromScratch {
    
}


- (NSString*)titleForBanner{
    
    return @"My Stream";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
