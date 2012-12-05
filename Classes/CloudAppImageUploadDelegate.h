//
//  CloudAppImageUploadDelegate.h
//  Fudge
//
//  Created by Frederic Jacobs on 5/9/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CloudAppImageUploadDelegate <NSObject>

- (void) uploadDidComplete:(BOOL)flag WithLink:(NSString*)link;

@end
