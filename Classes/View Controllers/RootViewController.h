//
//  RootViewController.h
//  Tapp
//
//  Created by Frederic Jacobs on 25/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXLabel.h"
#import "AppNetStreamTableView.h"

@interface RootViewController : UIViewController <UITabBarControllerDelegate> {
    FXLabel *titleLabel;
    UITabBarController *tappTabBarController;
    int indexMemory;
    RootViewController *rootViewController;
}

typedef enum {
    kHomeTimeLineVC,
    kMentionsTimeLineVC,
} StreamVC;

@property (nonatomic, retain) UITabBarController *tappTabBarController;

- (AppNetStreamTableView *) timeLineOfType:(StreamVC)vc;
- (void) setTimelineRead:(BOOL)flag;
- (void) setMentionsRead:(BOOL)flag;

@end

