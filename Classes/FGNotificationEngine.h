//
//  FGNotificationEngine.h
//  Fudge
//
//  Created by Frederic Jacobs on 10/10/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RootViewController.h"

@interface FGNotificationEngine : NSObject{

    NSTimer *timer;

}

+ (id)sharedManager;
- (void) initialize;
- (void) refresh;


@end
