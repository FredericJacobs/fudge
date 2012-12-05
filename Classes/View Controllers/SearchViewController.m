//
//  SearchViewController.m
//  Tapp
//
//  Created by Frederic Jacobs on 25/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController



- (void) viewWillAppear:(BOOL)animated {
    
    
    UIImage *gradientImage44 = [[UIImage imageNamed:@"navbar-background.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.navigationController.navigationBar setBackgroundImage:gradientImage44
                                                  forBarMetrics:UIBarMetricsDefault];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
