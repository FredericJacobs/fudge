//
//  HashTagViewController.h
//  Tapp
//
//  Created by Frederic Jacobs on 26/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "AppNetStreamTableView.h"
#import "AppDotNetStream.h"

@interface HashTagViewController : AppNetStreamTableView <AppDotNetStream>{
    NSString *hashTag;
}

- (id) initWithHashtag:(NSString*)hash;

@end
