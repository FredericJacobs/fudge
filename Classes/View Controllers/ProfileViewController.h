//
//  ProfileViewController.h
//  Fudge
//
//  Created by Frederic Jacobs on 10/10/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "AppNetStreamTableView.h"
#import "AppDotNetStream.h"

@interface ProfileViewController : AppNetStreamTableView <AppDotNetStream>{
    
    long long userID;
    NSString *username;

}

- (id) initWithUserID:(long long)aUserID;

@end
