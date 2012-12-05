//
//  RepliesViewController.h
//  Tapp
//
//  Created by Frederic Jacobs on 23/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "AppNetStreamTableView.h"
#import "AppDotNetStream.h"

@interface RepliesViewController : AppNetStreamTableView <AppDotNetStream>{
    
    UINavigationController *navController;
    
}


+ (Stream*) stream;

- (void) getNewStreamPosts;

@property (nonatomic,retain) UINavigationController *navController;

@end
