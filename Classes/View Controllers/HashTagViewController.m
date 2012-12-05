//
//  HashTagViewController.m
//  Tapp
//
//  Created by Frederic Jacobs on 26/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "HashTagViewController.h"
#import "ANSession.h"
#import "AppDotNetSyncingEngine.h"
#import "Post+Fetch.h"

@interface HashTagViewController ()

@end

@implementation HashTagViewController

- (id) initWithHashtag:(NSString*)hash {
    self = [super init];
    hashTag = hash;
    
    return self;
    
}

- (Stream*) stream {
    
    return [[AppDotNetSyncingEngine sharedManager] streamOfType:kSearch andParameter:hashTag];;
    
}

- (NSString*)titleForBanner{
    
    return [NSString stringWithFormat:@"#%@", hashTag];
}



- (void) viewWillAppear:(BOOL)animated{
    
    UIButton *backLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [backLabel setImage:[UIImage imageNamed:@"navbar-button-back-default.png"] forState:UIControlStateNormal];
    [backLabel setImage:[UIImage imageNamed:@"navbar-button-back-active.png"] forState:UIControlStateHighlighted];
    [backLabel addTarget:self action:@selector(popToPreviousViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backContainer = [[UIBarButtonItem alloc] initWithTitle:@"Post"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:nil
                                                                     action:nil];
    
    backLabel.frame = CGRectMake(0, 0, 52, 43);
    backLabel.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    backContainer.customView = backLabel;
    self.navigationItem.leftBarButtonItem= backContainer;
    
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
    
    if ([IDmatches count] == 1) {
        
        Post *post = [IDmatches objectAtIndex:0];
        
        postId = [post.id longLongValue];
        
        [ANSession.defaultSession postsWithTag:hashTag  betweenID:postId andID:ANUnspecifiedPostID completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
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
                
            }
            
        }];
        
    }
    
    else {
        
        [ANSession.defaultSession postsWithTag:hashTag completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
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
                
                
            }
            
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
        
        [ANSession.defaultSession postsWithTag:hashTag betweenID: ANUnspecifiedPostID andID:postId completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
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
                    
                    
                    [Post postWithAppNetInfo:post inManagedObjectContext:[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext]inStream:stream];
                    
                }
                
                isGettingMore = false;
            }
            
        }];
        
    }
}



- (void) popToPreviousViewController {
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController removeFromParentViewController];
    [refreshTimer invalidate];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
