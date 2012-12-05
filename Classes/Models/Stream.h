//
//  Stream.h
//  Fudge
//
//  Created by Frederic Jacobs on 5/12/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Stream : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSDate * refreshedAt;
@property (nonatomic, retain) NSDate * seenPostDate;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *post;
@end

@interface Stream (CoreDataGeneratedAccessors)

- (void)addPostObject:(Post *)value;
- (void)removePostObject:(Post *)value;
- (void)addPost:(NSSet *)values;
- (void)removePost:(NSSet *)values;

@end
