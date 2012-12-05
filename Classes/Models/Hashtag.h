//
//  Hashtag.h
//  Fudge
//
//  Created by Frederic Jacobs on 5/12/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Hashtag : NSManagedObject

@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSNumber * location;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) Post *inPost;

@end
