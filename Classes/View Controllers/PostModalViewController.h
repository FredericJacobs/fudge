//
//  PostModalViewController.h
//  Tapp
//
//  Created by Frederic Jacobs on 26/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudAppImageUploadDelegate.h"
#import "Post.h"

typedef enum
{
    ANPostModeNew = 1,
    ANPostModeReply,
    ANPostModeRepost
} ANPostMode;


@interface PostModalViewController : UIViewController <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CloudAppImageUploadDelegate>{
    UIBarButtonItem *postButton;
    UILabel *characterCountLabel;
    UITextView *postTextView;
    UIView *groupView;
    NSString *postText;
    NSDictionary *postData;
    UIImageView *myProfilePicture;
    UIButton *fullName;
    UIButton *username;
    UIButton *pictureButton;
}

- (id)init;
- (id)initWithReplyToPost:(Post *)replyToPost;


@end
