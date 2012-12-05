//
//  Link.h
//  Fudge
//
//  Created by Frederic Jacobs on 5/12/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Link : NSManagedObject

@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * location;
@property (nonatomic, retain) Post *inPost;

@end
