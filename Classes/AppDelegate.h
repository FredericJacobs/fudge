//
//  AppDelegate.h
//  Tapp
//
//  Created by Frederic Jacobs on 20/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXLabel.h"
#import "TapNavBarDelegate.h"
#import "RootViewController.h"
#import "FGNotificationEngine.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, TapNavBarDelegate>{
    
    UIViewController *tabbar;
    FXLabel *navLabel;
    RootViewController *theRootViewController;
    FGNotificationEngine *notificationEngine;
    
}
@property (nonatomic,retain) FXLabel *navLabel;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) RootViewController *theRootViewController;

- (void) callBack;
- (void) updateNavBarTitle:(NSString *)title;
- (void) signOffAndCleanup ;

@end
