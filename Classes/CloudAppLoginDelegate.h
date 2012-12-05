//
//  CloudAppLoginDelegate.h
//  Fudge
//
//  Created by Frederic Jacobs on 5/9/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CloudAppLoginDelegate <NSObject>

- (void) loginDidSucceed:(BOOL)flag;

@end
