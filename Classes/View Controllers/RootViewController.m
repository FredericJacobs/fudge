//
//  RootViewController.m
//  Tapp
//
//  Created by Frederic Jacobs on 25/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
#import "StreamViewController.h"
#import "RepliesViewController.h"
#import "SearchViewController.h"
#import "MyProfileViewController.h"
#import "VoidViewController.h"
#import "PostModalViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController
@synthesize tappTabBarController;

- (id) init {
    
    self = [super initWithNibName:nil bundle:nil];
    
    tappTabBarController = [[UITabBarController alloc] init];
    tappTabBarController.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen] bounds].size.height+5);
    tappTabBarController.tabBar.frame = CGRectMake(0, [[UIScreen mainScreen]bounds].size.height-56, [[UIScreen mainScreen] bounds].size.width,40);
        
    if ([[UITabBar class] respondsToSelector:@selector(setShadowImage:)]){
        tappTabBarController.tabBar.shadowImage = [self imageWithColor:[UIColor clearColor]];
    }
    
    tappTabBarController.delegate = self;
    
    StreamViewController *vc1 = [[StreamViewController alloc] init];
    RepliesViewController * vc2 = [[RepliesViewController alloc] init];
    SearchViewController *vc3 = [[SearchViewController alloc]init];
    MyProfileViewController *vc4 = [[MyProfileViewController alloc]init];
    VoidViewController *vc5 = [[VoidViewController alloc] init];
    
    vc1.view.bounds = [[UIScreen mainScreen]bounds];
    
    
    UINavigationController *nvc1 =  [[UINavigationController alloc] initWithRootViewController:vc1];
    UINavigationController *nvc2 =  [[UINavigationController alloc] initWithRootViewController:vc2];
    UINavigationController *nvc3 =  [[UINavigationController alloc] initWithRootViewController:vc3];
    UINavigationController *nvc4 =  [[UINavigationController alloc] initWithRootViewController:vc4];
    UINavigationController *nvc5 =  [[UINavigationController alloc] initWithRootViewController:vc5];
    
    
    NSArray* controllers = [NSArray arrayWithObjects:nvc1, nvc2,nvc3,nvc4, nvc5, nil];
    tappTabBarController.viewControllers = controllers;
    
    [tappTabBarController setDelegate:self];
    //Add the tab bar controller's current view as a subview of the window
    [self.view addSubview:tappTabBarController.view];
    
    return self;
}

- (void) viewDidLoad{
    
    UIImage *streamImage = [UIImage imageNamed:@"tabbar-stream-default.png"];
    UIImage *streamSelectedImage = [UIImage imageNamed:@"tabbar-stream-selected.png"];
    
    UIImage *repliesImage = [UIImage imageNamed:@"tabbar-replies-default.png"];
    UIImage *repliesSelectedImage = [UIImage imageNamed:@"tabbar-replies-selected.png"];
    
    UIImage *searchImage = [UIImage imageNamed:@"tabbar-search-disabled.png"];
    
    UIImage *profileImage = [UIImage imageNamed:@"tabbar-profile-default.png"];
    UIImage *profileSelectedImage = [UIImage imageNamed:@"tabbar-profile-selected.png"];
    
    UIImage *newImage = [UIImage imageNamed:@"tabbar-new-default.png"];
    UIImage *newActiveImage = [UIImage imageNamed:@"tabbar-new-active.png"];
    
    UITabBar *tabBarView = tappTabBarController.tabBar;
    
    UITabBarItem *item0 = [tabBarView.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBarView.items objectAtIndex:1];
    UITabBarItem *item2 = [tabBarView.items objectAtIndex:2];
    UITabBarItem *item3 = [tabBarView.items objectAtIndex:3];
    UITabBarItem *item4 = [tabBarView.items objectAtIndex:4];
    
    [item0 setFinishedSelectedImage:streamSelectedImage withFinishedUnselectedImage:streamImage];
    [item1 setFinishedSelectedImage:repliesSelectedImage withFinishedUnselectedImage:repliesImage];
    [item2 setFinishedSelectedImage:searchImage withFinishedUnselectedImage:searchImage];
    [item3 setFinishedSelectedImage:profileSelectedImage withFinishedUnselectedImage:profileImage];
    [item4 setFinishedSelectedImage:newActiveImage withFinishedUnselectedImage:newImage];
    
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0,0,320,1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    UINavigationController *nvc = (UINavigationController*)viewController;
    
    for (int i = 0; i < nvc.viewControllers.count; i++) {

    if ([[nvc.viewControllers objectAtIndex:i] isKindOfClass:[VoidViewController class]]) {
        tabBarController.selectedIndex = indexMemory;
        
        PostModalViewController *vc5 = [[PostModalViewController alloc] initWithNibName:nil bundle:nil ];
        UINavigationController *nvc5 =  [[UINavigationController alloc] initWithRootViewController:vc5];
        
        [self presentViewController:nvc5 animated:YES completion:nil];
        
    }
    
    if (indexMemory == tabBarController.selectedIndex) {
        UINavigationController *nvc = (UINavigationController*)viewController;
        for (int i = 0; i < nvc.viewControllers.count; i++) {
            
            if ([[nvc.viewControllers objectAtIndex:i] isKindOfClass:[AppNetStreamTableView class]]) {
                AppNetStreamTableView *stream = (AppNetStreamTableView*)[nvc.viewControllers objectAtIndex:i];
                
                [stream.streamTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:YES];
            }
        }

    }
    indexMemory = tabBarController.selectedIndex;
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    UINavigationController *nvc = (UINavigationController*)viewController;

    for (int i = 0; i < nvc.viewControllers.count; i++) {
        if ([[nvc.viewControllers objectAtIndex:i] isKindOfClass:[SearchViewController class]]) {
            return FALSE;
        }
    }
    
    return TRUE;
}

- (AppNetStreamTableView *) timeLineOfType:(StreamVC)vc {
    
    if (vc == kHomeTimeLineVC) {
        UINavigationController *nvc = [tappTabBarController.viewControllers objectAtIndex:0]
        ;
        
        for (int i = 0; i < nvc.viewControllers.count; i++) {
            
            if ([[nvc.viewControllers objectAtIndex:i] isKindOfClass:[AppNetStreamTableView class]]) {
                StreamViewController *stream = (StreamViewController*)[nvc.viewControllers objectAtIndex:i];
                
                return stream;
            }
        }
    }
    
    else if (vc == kMentionsTimeLineVC) {
        UINavigationController *nvc2 = [tappTabBarController.viewControllers objectAtIndex:1];
        
        for (int i = 0; i < nvc2.viewControllers.count; i++) {
            
            if ([[nvc2.viewControllers objectAtIndex:i] isKindOfClass:[AppNetStreamTableView class]]) {
                RepliesViewController *stream = (RepliesViewController*)[nvc2.viewControllers objectAtIndex:i];
                
                return stream;
            }
        }

    }
    
    return nil;
    
}

- (void) setTimelineRead:(BOOL)read {
    
    UITabBarItem *item = [tappTabBarController.tabBar.items objectAtIndex:0];
    
    if (read) {
        
        UIImage *streamImage = [UIImage imageNamed:@"tabbar-stream-default.png"];
        UIImage *streamSelectedImage = [UIImage imageNamed:@"tabbar-stream-selected.png"];
        
        [item setFinishedSelectedImage:streamSelectedImage withFinishedUnselectedImage:streamImage];
    }

    else {
        
        UIImage *streamImage = [UIImage imageNamed:@"tabbar-stream-default-new.png"];
        UIImage *streamSelectedImage = [UIImage imageNamed:@"tabbar-stream-selected-new.png"];
        
        [item setFinishedSelectedImage:streamSelectedImage withFinishedUnselectedImage:streamImage];
    }
    
}

- (void) setMentionsRead:(BOOL)read{
    
    UITabBarItem *item = [tappTabBarController.tabBar.items objectAtIndex:1];
    
    if (read) {
        
        UIImage *streamImage = [UIImage imageNamed:@"tabbar-replies-default.png"];
        UIImage *streamSelectedImage = [UIImage imageNamed:@"tabbar-replies-selected.png"];
        
        [item setFinishedSelectedImage:streamSelectedImage withFinishedUnselectedImage:streamImage];
    }
    
    else {
        
        UIImage *streamImage = [UIImage imageNamed:@"tabbar-replies-default-new.png"];
        UIImage *streamSelectedImage = [UIImage imageNamed:@"tabbar-replies-selected-new.png"];
        
        [item setFinishedSelectedImage:streamSelectedImage withFinishedUnselectedImage:streamImage];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
