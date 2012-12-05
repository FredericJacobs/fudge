//
//  AppDelegate.m
//  Tapp
//
//  Created by Frederic Jacobs on 20/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//
#import "AuthViewController.h"
#import "AppDotNetSyncingEngine.h"
#import "AppDelegate.h"
#import "ANSession.h"
#import "DiscussionViewController.h"
#import "RepliesViewController.h"
#import "CloudEngine.h"

@implementation AppDelegate
@synthesize navLabel, theRootViewController;


- (void) callBack {
    
    [theRootViewController dismissViewControllerAnimated:YES completion:nil];

}

- (void) signOffAndCleanup {
    
    UIImageView *tempScreen = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default.png"]];
    tempScreen.alpha = 0;
    tempScreen.frame = CGRectMake(0,20,320,460);
    [self.window addSubview:tempScreen];
    
    [UIView animateWithDuration:1.4f
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         [tempScreen setAlpha:1.0f];
                                              }
                     completion:^(BOOL finished) {
                         [theRootViewController removeFromParentViewController];
                         [[AppDotNetSyncingEngine sharedManager] wipeAuthCredentials];
                         theRootViewController = nil;
                         theRootViewController = [[RootViewController alloc]init];
                         [[ANSession defaultSession]setAccessToken:nil];
                         [self.window setRootViewController:theRootViewController];

                         [UIView animateWithDuration:1.4f
                                               delay:0.0f
                                             options:UIViewAnimationCurveEaseInOut
                                          animations:^{
                                              [tempScreen setAlpha:0.0f];
                                          }
                                          completion:^(BOOL finished) {
                                              [tempScreen removeFromSuperview];
                                              AuthViewController *authView = [[AuthViewController alloc]initWithNibName:nil bundle:nil];
                                              UINavigationController *nvc1 =  [[UINavigationController alloc] initWithRootViewController:authView];
                                              [theRootViewController presentViewController:nvc1 animated:YES completion:nil];

                                          }];
                     }];
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (!url) {  return NO; }
    
    NSString *URLString = [url absoluteString];

    NSString *postID = [URLString stringByReplacingOccurrencesOfString:@"fudge://postid=" withString:@""];
    
    
    
    [[ANSession defaultSession] postWithID:[postID integerValue] completion:^(ANResponse *response, ANPost *post, NSError *error){
        
        if (error) {
            NSLog(@"%@",error.debugDescription);
        }
        
        if (!error) {
            [self.theRootViewController.tappTabBarController setSelectedIndex:1];
            
            UINavigationController *replies = (UINavigationController*)self.theRootViewController.tappTabBarController.selectedViewController ;
            
            [replies pushViewController:[[DiscussionViewController alloc]initWithDiscussionID:post.threadID AndPostID:post.ID] animated:YES];
        }
    }];
  
    return YES;
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Add Main View
        
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    theRootViewController = [[RootViewController alloc]init];
    [self.window setRootViewController:theRootViewController];
    
    notificationEngine = [[FGNotificationEngine alloc]init];

    //[TestFlight takeOff: ADD TOKEN HERE];
    // Override point for customization after application launch.
        
    [self.window addSubview:theRootViewController.view];
    [self.window makeKeyAndVisible];
    
    if (![[AppDotNetSyncingEngine sharedManager]userIsLoggedIn]) {
        AuthViewController *authView = [[AuthViewController alloc]initWithNibName:nil bundle:nil];
        UINavigationController *nvc1 =  [[UINavigationController alloc] initWithRootViewController:authView];
        [theRootViewController presentViewController:nvc1 animated:YES completion:nil];
    }
    else{
         ANSession.defaultSession.accessToken = [[AppDotNetSyncingEngine sharedManager]token];
        [[ANSession defaultSession]userWithUsername:[[AppDotNetSyncingEngine sharedManager]username] completion:^(ANResponse *response, ANUser *user, NSError *error){
            [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%lli",user.ID] forKey:@"user_id"];
                }];
    }

    
    [CloudEngine sharedManager];
    
    
    return YES;

}


- (void) updateNavBarTitle:(NSString *)title{
    
    navLabel.text = title;
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [notificationEngine refresh];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   // [notificationEngine refresh];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
