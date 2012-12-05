//
//  AppNetStreamTableView.h
//  Tapp
//
//  Created by Frederic Jacobs on 23/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "FXLabel.h"
#import "ANPostLabel.h"

@interface AppNetStreamTableView : UIViewController<UITableViewDataSource,UITableViewDelegate, NSFetchedResultsControllerDelegate>{
    UIView *refreshHeaderView;
    UILabel *refreshLabel;
    UITableView *streamTableView;
    BOOL isDragging;
    BOOL isLoading;
    NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;
    UIImageView *navBarShadow;
    UIImageView *tabBarShadow;
    UILabel *refreshTimeLabel;
    BOOL isGettingMore;
    NSTimer *refreshTimer;
}

@property (nonatomic,retain) UITableView *streamTableView;
@property (nonatomic, retain) UIView *refreshHeaderView;
@property (nonatomic, retain) UILabel *refreshTimeLabel;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL beganUpdates;
@property (nonatomic, retain) NSFetchedResultsController *resultsController;

- (void)setupStrings;
- (void)addPullToRefreshHeader;
- (void)startLoading;
- (void)stopLoading;
- (void)refresh;
- (CGFloat) requiredHeightForPostAtIndexPath:(NSIndexPath*)indexPath;

- (void)performFetch;
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;

// Set to YES to get some debugging output in the console.
@property BOOL debug;


@end
