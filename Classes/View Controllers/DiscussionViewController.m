//
//  DiscussionViewController.m
//  Fudge
//
//  Created by Frederic Jacobs on 29/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "DiscussionViewController.h"
#import "AppNetStreamTableView.h"
#import "AppDotNetSyncingEngine.h"
#import "ANSession.h"
#import "../../Libraries/SDWebImage/SDWebImage/UIImageView+WebCache.h"
#import "NSDictionary+SDExtensions.h"
#import "Utils.h"
#import "StreamTableViewCell.h"
#import "HashTagViewController.h"
#import "../../Libraries/TSMiniWebBrowser/TSMiniWebBrowser.h"
#import "PostModalViewController.h"
#import "ProfileViewController.h"
#import "DiscussionTableViewCell.h"
#import "Post+Fetch.h"
#import "User.h"

#define REFRESH_HEADER_HEIGHT 67.0f
#define kTopPostPadding 3.0f
#define kBottomPostPadding 8.0f

@implementation DiscussionViewController

- (void) viewWillAppear:(BOOL)animated{
    
    isGettingMore = TRUE;
    
    UIImage *gradientImage44 = [[UIImage imageNamed:@"navbar-background.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.navigationController.navigationBar setBackgroundImage:gradientImage44
                                                  forBarMetrics:UIBarMetricsDefault];
    
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
    streamTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    streamTableView.separatorColor = [UIColor clearColor];
}

- (Stream*) stream {
    
    return [[AppDotNetSyncingEngine sharedManager] streamOfType:kThread andParameter:[NSString stringWithFormat:@"%lli",threadID]];;
    
}

- (id)initWithDiscussionID:(ANResourceID)discussionID AndPostID:(ANResourceID)postID
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        threadID = discussionID;
        thePostID = postID;
        firstLoad = YES;
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Post *aPost  = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([[aPost id] isEqualToNumber: [NSNumber numberWithLongLong:thePostID]]) {
        
        
        static NSString *CellIdentifier = @"DiscussionCell";
        StreamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[StreamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell.reply addTarget:self action:@selector(replyToPost:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        // Adding fullname
        
        [cell.fullName setTitle:[[aPost posted_by] fullname] forState:UIControlStateNormal];
        
        // Adding username
        
        [cell.username setTitle:[NSString stringWithFormat:@"@%@", aPost.posted_by.username]  forState:UIControlStateNormal];
        cell.time.text = [NSString stringWithFormat:@"%@",[Utils stringForTimeDifferenceWith:aPost.created_at]];
        
        // Adding Avatars
        
        [cell.profilePicture setImageWithURL:[NSURL URLWithString:aPost.posted_by.profilePictureURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
        // Adding Quotes
        
        cell.reply.tag = indexPath.row;
        
        NSAttributedString *string = [ANPostLabel attributedStringForPostData:aPost];
        
        if (cell.post) {
            [cell.post setAttributedString:string];
            [cell.post reloadInputViews];
            [cell.post relayoutText];
        }
        else {
            
            cell.post = [[ANPostLabel alloc]initWithAttributedString:string width:298];
            
            cell.post.tapHandler = ^BOOL (NSString *type, NSString *value) {
                BOOL result = NO;
                if ([type isEqualToString:@"hashtag"])
                {
                    NSString *hashtag = value;
                    HashTagViewController *hashtagController = [[HashTagViewController alloc]initWithHashtag:hashtag];
                    [self.navigationController pushViewController:hashtagController animated:YES];
                }
                else
                    if ([type isEqualToString:@"name"])
                    {
                        ProfileViewController *profile = [[ProfileViewController alloc] initWithUserID:[value longLongValue]];
                        [self.navigationController pushViewController:profile animated:YES];
                    }
                    else
                        if ([type isEqualToString:@"link"])
                        {
                            NSURL *url = [NSURL URLWithString:value];
                            if ([[UIApplication sharedApplication] canOpenURL:url])
                            {
                                
                                TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:url];
                                webBrowser.showActionButton = YES;
                                webBrowser.showReloadButton = YES;
                                webBrowser.mode = TSMiniWebBrowserModeNavigation;
                                [self.navigationController pushViewController:webBrowser animated:YES];
                            }
                            
                        }
                return result;
            };
            
            cell.post.longPressHandler = ^BOOL (NSString *type, NSString *value) {
                if([type isEqualToString:@"link"])
                {
                    //Do Something
                    
                }
                else
                {
                    // TODO: Craft a URL pointing to the post on alpha.app.net
                    //       open the action sheet above with this URL. @jtregunna
                }
                return NO;
            };

            
            cell.post.backgroundColor = [UIColor clearColor];
            UIColor *shadowColor = [UIColor colorWithRed:23/255. green:15/255. blue:28/255. alpha:1];
            
            cell.post.frame = CGRectMake(11, 45+kTopPostPadding+10 , 298, 100);
            
            [[cell.post layer] setShadowOffset:CGSizeMake(0, -1)];
            [[cell.post layer] setShadowColor:[shadowColor CGColor]];
            [[cell.post layer] setShadowOpacity:1];
            [[cell.post layer] setShadowRadius:0];
            [cell addSubview:cell.post];
            [cell.post relayoutText];
        }
        if (indexPath.row == 0 ) {
            [cell resizeForDiscussionViewFrame:CGRectMake(0, 0, 320, [self tableView:tableView heightForRowAtIndexPath:indexPath]-10)];
        }
        
        else {
            [cell resizeForDiscussionViewFrame:CGRectMake(0, 10, 320, [self tableView:tableView heightForRowAtIndexPath:indexPath]-20)];
        }
        
        return cell;
    }
    
    else {
        static NSString *CellIdentifier = @"StreamCell";
        
        DiscussionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[DiscussionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell.reply addTarget:self action:@selector(replyToPost:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [cell.fullName setTitle:[[aPost posted_by] fullname] forState:UIControlStateNormal];
        
        // Adding username
        
        [cell.username setTitle:[NSString stringWithFormat:@"@%@", aPost.posted_by.username]  forState:UIControlStateNormal];
        cell.time.text = [NSString stringWithFormat:@"%@",[Utils stringForTimeDifferenceWith:aPost.created_at]];
        
        // Adding Avatars
        
        [cell.profilePicture setImageWithURL:[NSURL URLWithString:aPost.posted_by.profilePictureURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        // Adding Quotes
        
        cell.reply.tag = indexPath.row;
        NSAttributedString *string = [ANPostLabel attributedStringForPostData:aPost];
        
        if (cell.post) {
            [cell.post setAttributedString:string];
            [cell.post reloadInputViews];
            [cell.post relayoutText];
        }
        else {
            
            cell.post = [[ANPostLabel alloc]initWithAttributedString:string width:298];
            cell.post.backgroundColor = [UIColor clearColor];
            UIColor *shadowColor = [UIColor colorWithRed:23/255. green:15/255. blue:28/255. alpha:1];
            
            cell.post.frame = CGRectMake(21, 45+kTopPostPadding , 278, 100);
            
            cell.post.tapHandler = ^BOOL (NSString *type, NSString *value) {
                BOOL result = NO;
                if ([type isEqualToString:@"hashtag"])
                {
                    NSString *hashtag = value;
                    HashTagViewController *hashtagController = [[HashTagViewController alloc]initWithHashtag:hashtag];
                    [self.navigationController pushViewController:hashtagController animated:YES];
                }
                else
                    if ([type isEqualToString:@"name"])
                    {
                        ProfileViewController *profile = [[ProfileViewController alloc] initWithUserID:[value longLongValue]];
                        [self.navigationController pushViewController:profile animated:YES];
                    }
                    else
                        if ([type isEqualToString:@"link"])
                        {
                            NSURL *url = [NSURL URLWithString:value];
                            if ([[UIApplication sharedApplication] canOpenURL:url])
                            {
                                
                                TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:url];
                                webBrowser.showActionButton = YES;
                                webBrowser.showReloadButton = YES;
                                webBrowser.mode = TSMiniWebBrowserModeNavigation;
                                [self.navigationController pushViewController:webBrowser animated:YES];
                            }
                            
                        }
                return result;
            };
            
            cell.post.longPressHandler = ^BOOL (NSString *type, NSString *value) {
                if([type isEqualToString:@"link"])
                {
                    //Do Something
                    
                }
                else
                {
                    // TODO: Craft a URL pointing to the post on alpha.app.net
                    //       open the action sheet above with this URL. @jtregunna
                }
                return NO;
            };

            
            [[cell.post layer] setShadowOffset:CGSizeMake(0, -1)];
            [[cell.post layer] setShadowColor:[shadowColor CGColor]];
            [[cell.post layer] setShadowOpacity:1];
            [[cell.post layer] setShadowRadius:0];
            [cell addSubview:cell.post];
            [cell.post relayoutText];
        }
        
        [cell resizeForFrame:CGRectMake(10, 0, 300, [self tableView:tableView heightForRowAtIndexPath:indexPath])];
        
        return cell;
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Post *aPost  = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([[aPost id] isEqualToNumber: [NSNumber numberWithLongLong:thePostID]]) {
        
        return (65 + kTopPostPadding + [self requiredHeightForPostAtIndexPath:indexPath] + kBottomPostPadding);
    }
    else{
        return (45 + kTopPostPadding + [self requiredHeightForPassivePostAtIndexPath:indexPath] + kBottomPostPadding);
    }
}

- (CGFloat) requiredHeightForPassivePostAtIndexPath:(NSIndexPath*)indexPath{
    
    DTAttributedTextContentView *contentView = [[DTAttributedTextContentView alloc] initWithAttributedString:[ANPostLabel attributedStringForPostData:[self.fetchedResultsController objectAtIndexPath:indexPath]] width:278];
    
    contentView.frame = CGRectMake(-300, 0, 278, 100);
    
    [self.view addSubview:contentView];
    
    [contentView relayoutText];
    
    CGFloat height = contentView.frame.size.height;
    
    [contentView removeFromSuperview];
    
    return height;
    
}

- (NSString*)titleForBanner{
    
    return @"Conversation";
}

- (void) popToPreviousViewController {
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController removeFromParentViewController];
    [refreshTimer invalidate];
    
}

- (void)viewDidAppear:(BOOL)animated{
    if ([[AppDotNetSyncingEngine sharedManager] userIsLoggedIn]) {
        [self startLoading];
    }
    
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
    
    
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}


- (void) viewDiscussion:(UIButton*)sender{
    
    
}

- (void) getStream {
    
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
        
        [ANSession.defaultSession postsReplyingToPostWithID:threadID betweenID:postId andID:ANUnspecifiedPostID completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
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
                
                int row = -1;
                
                for (int i = 0 ; i < [[self.fetchedResultsController fetchedObjects] count]; i++) {
                    Post *currentPost = [[self.fetchedResultsController fetchedObjects] objectAtIndex:i];
                    if ([currentPost.id longLongValue] == thePostID) {
                        row = i;
                    }
                }
                
                if (firstLoad && row != -1) {
                    [streamTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    firstLoad = FALSE;
                }
                
            }
            
        }];

        
    }
    
    else{
        
        [ANSession.defaultSession postsReplyingToPostWithID:threadID betweenID:threadID andID:ANUnspecifiedPostID completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
            if (response.hasMore){
                
                NSLog(@"It has");
                
            }
            else {
                
                NSLog(@"It doesn't");
            }
            
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
                
                [self getMoreStreamPosts];
                
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
    
    if ([matches count] == 0) {
        
        [[ANSession defaultSession] postWithID:threadID completion:^(ANResponse *response, ANPost *post, NSError *error){
            
            if (error) {
                return ;
            }
            
            
            if (!post) {
                NSLog(@"No More Posts");
                return;
            }
            
            [Post postWithAppNetInfo:post inManagedObjectContext:[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext]inStream:stream];
            
            
            int row = -1;
            
            for (int i = 0 ; i < [[self.fetchedResultsController fetchedObjects] count]; i++) {
                Post *currentPost = [[self.fetchedResultsController fetchedObjects] objectAtIndex:i];
                if ([currentPost.id longLongValue] == thePostID) {
                    row = i;
                }
            }
            
            if (firstLoad && row != -1) {
                [streamTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                firstLoad = FALSE;
            }
            
        }];
        
    }
    
    if ([matches count] == 1) {
        
        Post *aPost = [matches objectAtIndex:0];
        
        postId = [aPost.id longLongValue];
        
        [ANSession.defaultSession postsReplyingToPostWithID:threadID betweenID: threadID andID:postId completion:^(ANResponse *response, NSArray *posts, NSError *error){
            
            if (error) {
                return ;
            }
            
            
            if (!posts) {
                NSLog(@"No More Posts");
                return;
            }
            
            
            if (posts != nil) {
                
                NSLog(@"%i", [posts count]);
                
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
                
                int row = -1;
                
                for (int i = 0 ; i < [[self.fetchedResultsController fetchedObjects] count]; i++) {
                    Post *currentPost = [[self.fetchedResultsController fetchedObjects] objectAtIndex:i];
                    if ([currentPost.id longLongValue] == thePostID) {
                        row = i;
                    }
                }
                
                if (firstLoad && row != -1) {
                    [streamTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    firstLoad = FALSE;
                }
                
                if ([posts count] != 0) {
                 
                    [self getMoreStreamPosts];
                    
                }
                
                else if ([posts count] == 0) {
                    [[ANSession defaultSession] postWithID:threadID completion:^(ANResponse *response, ANPost *post, NSError *error){
                        
                        if (error) {
                            return ;
                        }
                        
                        
                        if (!post) {
                            NSLog(@"No More Posts");
                            return;
                        }
                        
                        [Post postWithAppNetInfo:post inManagedObjectContext:[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext]inStream:stream];
                        
                        
                        int row = -1;
                        
                        for (int i = 0 ; i < [[self.fetchedResultsController fetchedObjects] count]; i++) {
                            Post *currentPost = [[self.fetchedResultsController fetchedObjects] objectAtIndex:i];
                            if ([currentPost.id longLongValue] == thePostID) {
                                row = i;
                            }
                        }
                        
                        if (firstLoad && row != -1) {
                            [streamTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            firstLoad = FALSE;
                        }
                        
                    }];
                }
            }
            
        }];
        
    }
}


@end
