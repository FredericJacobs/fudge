//
//  AppDotNetStream.h
//  SDWebImage
//
//  Created by Frederic Jacobs on 23/8/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppDotNetStream <NSObject>

- (NSString*) titleForBanner;
- (Stream*) stream;
- (void) getNewStreamPosts;
- (void) getMoreStreamPosts;

@end
