//
//  TapNavBarDelegate.h
//  Tapp
//
//  Created by Frederic Jacobs on 23/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TapNavBarDelegate <NSObject>

- (void) updateNavBarTitle:(NSString*)title;

@end
