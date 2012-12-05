//
//  AppNetStreamTableView.m
//  Tapp
//
//  Created by Frederic Jacobs on 23/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "AppNetStreamTableView.h"
#import "AppDotNetSyncingEngine.h"
#import "StreamTableViewCell.h"
#import "ANSession.h"
#import "UIImageView+WebCache.h"
#import "NSDictionary+SDExtensions.h"
#import "Utils.h"
#import "HashTagViewController.h"
#import "TSMiniWebBrowser.h"
#import "PostModalViewController.h"
#import "DiscussionViewController.h"
#import "User.h"
#import "ANPostLabel.h"
#import "ProfileViewController.h"
#import "Stream.h"

#define REFRESH_HEADER_HEIGHT 67.0f
#define kTopPostPadding 3.0f
#define kBottomPostPadding 8.0f

@implementation AppNetStreamTableView
@synthesize streamTableView, textLoading,textPull,textRelease,refreshHeaderView, refreshLabel, refreshTimeLabel;

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize suspendAutomaticTrackingOfChangesInManagedObjectContext = _suspendAutomaticTrackingOfChangesInManagedObjectContext;
@synthesize debug = _debug;


- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]];
    
    Stream *theStream = [self stream];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(ANY inStream == %@)", theStream];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[[[AppDotNetSyncingEngine sharedManager] fudgeDatabase] managedObjectContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (Stream*) stream {
    
    return nil;
    
}


- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        if (newfrc) {
            if (self.debug) NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            [self performFetch];
        } else {
            if (self.debug) NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            [self performFetch];
            
            [streamTableView reloadData];
        }
    }
}

- (void)performFetch
{
    if (self.fetchedResultsController) {
        if (self.fetchedResultsController.fetchRequest.predicate) {
            if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
        } else {
            if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    } else {
        if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    
    [streamTableView reloadData];
}


- (void) viewDidLoad {
    [super viewDidLoad];
    isGettingMore = FALSE;
    isLoading = FALSE;
    [self setupStrings];
    self.debug = FALSE;
    
    // Setting TableView
    self.view.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height-44);
    streamTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height-108) style:UITableViewStylePlain];
    self.streamTableView.backgroundColor = [UIColor colorWithRed:23.0/255 green:15.0/255 blue:28.0/255 alpha:1];
    streamTableView.delegate = self;
    streamTableView.dataSource = self;
    streamTableView.separatorColor = [UIColor colorWithRed:17/255. green:7/255. blue:25/255. alpha:1];
    [self.view addSubview:streamTableView];
    
    // Adding Header
    
    [self addPullToRefreshHeader];
    
    // setting shadows
    
    navBarShadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320,3)];
    navBarShadow.backgroundColor = [UIColor clearColor];
    navBarShadow.image = [[UIImage imageNamed:@"navbar-shadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.view addSubview:navBarShadow];
    navBarShadow.alpha = 0;
    
    NSLog(@"%f", [[UIScreen mainScreen] bounds].size.height);
    
    tabBarShadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 111, [[UIScreen mainScreen] bounds].size.width,3)];
    tabBarShadow.backgroundColor = [UIColor clearColor];
    tabBarShadow.image = [[UIImage imageNamed:@"tabbar-shadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.view addSubview:tabBarShadow];
    [self updateTime];
    [self setFetchResultController];
}


#pragma mark ScrollToRefresh

- (void)setupStrings{
    textPull = @"Pull to refresh...";
    textRelease = @"Release to refresh...";
    textLoading = @"Loading...";
}

- (void)addPullToRefreshHeader {
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor colorWithRed:23.0/255 green:15.0/255 blue:28.0/255 alpha:1];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 320, REFRESH_HEADER_HEIGHT/2)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    refreshLabel.textColor = [UIColor colorWithRed:109.0/255 green:75.0/255 blue:145.0/255 alpha:1];
    
    refreshTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, REFRESH_HEADER_HEIGHT/2, 320, REFRESH_HEADER_HEIGHT/2)];
    refreshTimeLabel.backgroundColor = [UIColor clearColor];
    refreshTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    refreshTimeLabel.textAlignment = NSTextAlignmentCenter;
    refreshTimeLabel.textColor = [UIColor colorWithRed:72.0/255 green:49.0/255 blue:119.0/255 alpha:1];
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshTimeLabel];
    [self.streamTableView addSubview:refreshHeaderView];
    
}

- (NSString*)titleForBanner{
    
    return @"";
}



- (void)viewDidAppear:(BOOL)animated{
    
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
        self.navigationController.navigationBar.clipsToBounds = YES;
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
    
    // if the content has never been loaded, go ahead and load it
    
    [self updateTime];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
    NSIndexPath*	selection = [self.streamTableView indexPathForSelectedRow];
    if (selection)
        [self.streamTableView deselectRowAtIndexPath:selection animated:YES];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.streamTableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.streamTableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                refreshLabel.text = self.textRelease;
                
            } else {
                // User is scrolling somewhere within the header
                refreshLabel.text = self.textPull;
            }
        }];
    }
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -200;
    if(y > h + reload_distance) {
        if (!isGettingMore && !isLoading) {
            [self getMoreRows];
        }
    }
    
    
    if (offset.y > 1) {
        navBarShadow.alpha = 1;
    }
    else{
        navBarShadow.alpha = 0;
    }
    
    if (y > h) {
        
        tabBarShadow.alpha = 0;
        
    }
    else if (y < h) {
        tabBarShadow.alpha = 1;
    }
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    
    if (scrollView.contentOffset.y <= 3) {
        
        [self setRead];
        
    }
    
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void) setRead{
    
    
}

- (void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    StreamTableViewCell *cell = (StreamTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
    cell.gradientOverlay.opacity = 1;
    cell.gradientOverlay.colors = [NSArray arrayWithObjects: (id)[UIColor colorWithRed:23/255. green:15/255. blue:28/255. alpha:1].CGColor,(id)[UIColor colorWithRed:23/255. green:15/255. blue:28/255. alpha:0.5].CGColor, nil];
    cell.highlightLine.alpha = 0;
    
}

- (void) unselectAllRows{
    for (int i = 0 ; i < [[streamTableView visibleCells] count]; i++) {
        StreamTableViewCell *cell = [[streamTableView visibleCells]objectAtIndex:i];
        cell.gradientOverlay.colors = [NSArray arrayWithObjects: (id)[UIColor clearColor].CGColor,(id)[UIColor blackColor].CGColor, nil];
        cell.gradientOverlay.opacity = 0.075;
        cell.highlightLine.alpha = 1;
    }
    
}

- (void) tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    [self unselectAllRows];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = indexPath.row;
    [self viewDiscussion:button];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void) setFetchResultController
{
    if ([[AppDotNetSyncingEngine sharedManager]dbIsReady]) {
        [self setupFetchedResultsController];
        
        if ([self.fetchedResultsController.fetchedObjects count] == 0) {
            [self loadFromScratch];
        }
        else{
            [self updateTime];
        }
    }
    else{
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(setFetchResultController)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void) loadFromScratch {
    
    [self getStream];
    
}

-(void) updateTime
{
    [self updateTimeLabels];
    
    [refreshTimer invalidate];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                    target:self
                                                  selector:@selector(updateTime)
                                                  userInfo:nil
                                                   repeats:NO];
}

- (void) updateTimeLabels{
    
    // Update the refresh header
    
    NSDate *date = [[self stream]refreshedAt];
    
    if (date) {
        
        refreshTimeLabel.text = [NSString stringWithFormat:@"Last Updated : %@",[[Utils stringForTimeDifferenceWith:date] lowercaseString]];
        
    }
    
    else{
        
        refreshTimeLabel.text = @"Not loaded yet";
        
    }
    
    // Update each line's time stamp
    
    for (int i=0; i < [[streamTableView visibleCells] count]; i++) {
        StreamTableViewCell *cell = (StreamTableViewCell*)[[streamTableView visibleCells] objectAtIndex:i];
        
        Post *post = [self.fetchedResultsController objectAtIndexPath:[[streamTableView indexPathsForVisibleRows]objectAtIndex:i]];
        
        NSString *timeLabel = [Utils stringForTimeDifferenceWith:post.created_at];
        
        cell.time.text = [NSString stringWithFormat:@"%@",timeLabel];
        
    }
}

- (void) getStream{
    
    [self getNewStreamPosts];
    
}

- (void) getMoreRows{
    
    [self getMoreStreamPosts];
    
}



- (void)startLoading {
    
    if (isLoading == FALSE) {
        [self refresh];
        isLoading = YES;
    }

    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        self.streamTableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        
        refreshLabel.text = self.textLoading;
        
        if ([self stream].refreshedAt) {
            refreshLabel.text = @"Refreshing";
        }
        
    }];
    
}

- (void)stopLoading {
    
    [self performFetch];
    
    isLoading = NO;
    
    NSDate *date = [[self stream]refreshedAt];
    
    if (date) {
        
        refreshTimeLabel.text = [NSString stringWithFormat:@"Last Updated : %@",[[Utils stringForTimeDifferenceWith:date] lowercaseString]];
        
    }
    
    else{
        
        refreshTimeLabel.text = @"Not loaded yet";
        
    }
    
    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        self.streamTableView.contentInset = UIEdgeInsetsZero;
    }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(stopLoadingComplete)];
                     }];
    
}

- (void)stopLoadingComplete {
    // Reset the header
    refreshLabel.text = self.textPull;
    [self updateTime];
}

- (void)refresh {
    [self getStream];
}


#pragma mark tableview setup


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return (45 + kTopPostPadding + [self requiredHeightForPostAtIndexPath:indexPath] + kBottomPostPadding);
    
}

- (CGFloat) requiredHeightForPostAtIndexPath:(NSIndexPath*)indexPath{
    
    Post *aPost  = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return [aPost.height298 floatValue];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Post *aPost  = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"Cell";
    
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
        
        cell.post.frame = CGRectMake(11, 45+kTopPostPadding , 298, 0);
        
        [[cell.post layer] setShadowOffset:CGSizeMake(0, -1)];
        [[cell.post layer] setShadowColor:[shadowColor CGColor]];
        [[cell.post layer] setShadowOpacity:1];
        [[cell.post layer] setShadowRadius:0];
        [cell addSubview:cell.post];
        [cell.post relayoutText];
    }
    
    [cell resizeForFrame:CGRectMake(0, 0, 320, 45 + kTopPostPadding + [self requiredHeightForPostAtIndexPath:indexPath] + kBottomPostPadding)];
    
    return cell;
    
}

- (void) viewDiscussion:(UIButton*)sender{
    
    Post *aPost  = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    DiscussionViewController *discussion = [[DiscussionViewController alloc] initWithDiscussionID:[[aPost thread_id] longLongValue] AndPostID:[[aPost id] longLongValue]];
    [self.navigationController pushViewController:discussion animated:YES];
    
}


- (void) replyToPost:(UIButton*)sender{
    
    Post *currentPost = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    [[AppDotNetSyncingEngine sharedManager] composeResponseForPost:currentPost];
    
}

- (void) getMoreStreamPosts{
    
}
-(void) getNewStreamPosts{
    
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        [streamTableView beginUpdates];
        self.beganUpdates = YES;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [streamTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [streamTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [streamTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
                
            case NSFetchedResultsChangeDelete:
                [streamTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [streamTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [streamTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [streamTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.beganUpdates) [streamTableView endUpdates];
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend) {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}


@end
