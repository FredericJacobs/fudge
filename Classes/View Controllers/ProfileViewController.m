//
//  ProfileViewController.m
//  Fudge
//
//  Created by Frederic Jacobs on 10/10/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "ProfileViewController.h"
#import "FXLabel.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "ANSession.h"
#import "Post+Fetch.h"
#import "Stream.h"
#import "AppDotNetSyncingEngine.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (id) initWithUserID:(long long)aUserID ;{
    
    self = [super initWithNibName:nil bundle:nil];
    
    userID = aUserID;
    username = @"";
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    
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
    [self fetchUsername];
}

- (void) popToPreviousViewController {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void) fetchUsername {
    
    [[ANSession defaultSession] userWithID:userID completion:^(ANResponse *response, ANUser *user, NSError *error){
        
        if (!error) {
            
            username = user.name;
            [self updateTitle];
        }
    }];
    
}

- (void) updateTitle {
    
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:[FXLabel class]]) {
            FXLabel *label = (FXLabel*) view;
            label.text = username;
        }
    }
}



- (NSString*) titleForBanner {
    
    return username;
}

- (Stream*) stream {
    
    return [[AppDotNetSyncingEngine sharedManager] streamOfType:kUserPosts andParameter:[NSString stringWithFormat:@"%llu",userID]];;
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
        
        
        [ANSession.defaultSession postsForUserWithID:userID betweenID:postId andID:ANUnspecifiedPostID completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
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
    
    else{
        
        [ANSession.defaultSession postsForUserWithID:userID betweenID:ANUnspecifiedPostID andID:ANUnspecifiedPostID completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
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
        
        [ANSession.defaultSession postsForUserWithID:userID betweenID:ANUnspecifiedPostID andID:postId completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
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
                
                isGettingMore = FALSE;
            }
            
        }];
        
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL labelExists = NO;
    
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:[FXLabel class]]) {
            FXLabel *label = (FXLabel*) view;
            label.text = [self titleForBanner];
            labelExists = YES;
        }
    }
    
    if (!labelExists) {
        
        FXLabel *navBarTitleLabel = [[FXLabel alloc]initWithFrame:CGRectMake(60, (44/2 - [UIFont fontWithName:@"HelveticaNeue-Bold" size:18].lineHeight /2 ), 200, [UIFont fontWithName:@"HelveticaNeue-Bold" size:18].lineHeight)];
        [self.navigationController.navigationBar addSubview:navBarTitleLabel];
        
        navBarTitleLabel.text = [self titleForBanner];
        navBarTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        navBarTitleLabel.textColor = [UIColor colorWithRed:169/255. green:154/255. blue:186/255. alpha:1];
        navBarTitleLabel.backgroundColor = [UIColor clearColor];
        navBarTitleLabel.shadowColor = [UIColor blackColor];
        navBarTitleLabel.textAlignment = NSTextAlignmentCenter;
        navBarTitleLabel.shadowBlur=0;
        navBarTitleLabel.shadowOffset= CGSizeMake(0, -1);
        navBarTitleLabel.gradientStartColor = [UIColor whiteColor];
        navBarTitleLabel.gradientEndColor = [UIColor clearColor];
        navBarTitleLabel.gradientStartPoint = CGPointMake(0, 0.3);
        navBarTitleLabel.gradientEndPoint = CGPointMake(0, 0.8);
        navBarTitleLabel.numberOfLines = 1;
        [navBarTitleLabel clipsToBounds];
    }
    
    
    // Do any additional setup after loading the view.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
