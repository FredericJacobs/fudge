//
//  FirstViewController.h
//  Tapp
//
//  Created by Frederic Jacobs on 20/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "AppNetStreamTableView.h"
#import "AppDotNetStream.h"


@interface StreamViewController : AppNetStreamTableView <AppDotNetStream>{
    UINavigationController *navController;
}

+ (Stream*) stream;
- (void) getNewStreamPosts;

@end
