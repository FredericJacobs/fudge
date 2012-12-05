//
//  PostModalViewController.m
//  Tapp
//
//  Created by Frederic Jacobs on 26/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "PostModalViewController.h"
#import "../../Libraries/FXLabel/FXLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDotNetSyncingEngine.h"
#import "NSDictionary+SDExtensions.h"
#import "ANSession.h"
#import "AppDelegate.h"
#import "CloudEngine.h"
#import "../../Libraries/SDWebImage/SDWebImage/UIImageView+WebCache.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Post+ReplyToUsernames.h"


@interface PostModalViewController ()

-(void) updateCharCountLabel: (NSNotification *)notification;
-(void) registerForNotifications;
-(void) unregisterForNotifications;

@end

@implementation PostModalViewController{
    UIImage *postImage;
    ANPostMode postMode;
    ANDraft *draft;
    NSMutableString *currentCapture;
    NSRange currentCaptureRange;
    NSArray* currentSuggestions;
}


- (id)init{
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithReplyToPost:(Post *)replyToPost {
    
    self = [self initWithNibName:nil bundle:nil];
    
    draft = [[ANDraft alloc]init];
    
    draft.replyTo = [replyToPost. id longLongValue];
    
    postMode = ANPostModeReply;
    
    draft.text = [replyToPost mentionsStrings];
    
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        draft = [[ANDraft alloc]init];
        postMode = ANPostModeNew;
        self.view.backgroundColor = [UIColor colorWithRed:23/255. green:15/255. blue:28/255. alpha:1];
        
        postTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, 57, 300, [[UIScreen mainScreen]bounds].size.height - 480 + 137)];
        
        [postTextView setBackgroundColor:[UIColor clearColor]];
        postTextView.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        
        postTextView.textColor = [UIColor colorWithRed:169/255. green:154/255. blue:186/255. alpha:1];
        
        [self.view addSubview:postTextView];
        
        
        UIImage *cellBackgroundImageSource = [[UIImage imageNamed:@"post-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        UIImageView *cellBackGroundImage = [[UIImageView alloc]initWithImage:cellBackgroundImageSource];
        cellBackGroundImage.frame = CGRectMake(0, 0, 320, 55);
        cellBackGroundImage.contentMode = UIViewContentModeScaleToFill;
        [self.view addSubview:cellBackGroundImage];
        
        [[cellBackGroundImage layer] setShadowOffset:CGSizeMake(0, 1)];
        [[cellBackGroundImage layer] setShadowColor:[[UIColor blackColor] CGColor]];
        [[cellBackGroundImage layer] setShadowOpacity:1];
        [[cellBackGroundImage layer] setShadowRadius:0];
        
        
        CAGradientLayer *gradientOverlay = [CAGradientLayer layer];
        
        gradientOverlay.colors = [NSArray arrayWithObjects: (id)[UIColor clearColor].CGColor,(id)[UIColor blackColor].CGColor, nil];
        
        gradientOverlay.frame = CGRectMake(0, 0, 320, 55);
        
        //set its opacity from 0 ~ 1
        gradientOverlay.opacity = 0.25;
        //add it as sublayer of self.layer (it will be over the layer with the background image
        [self.view.layer addSublayer:gradientOverlay];
        
        UIFont *characterFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        characterCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(275, 18, 35,characterFont.lineHeight)];
        characterCountLabel.text = @"256";
        characterCountLabel.font = characterFont;
        characterCountLabel.textAlignment = NSTextAlignmentRight;
        characterCountLabel.textColor = [UIColor colorWithRed:95/255. green:51/255. blue:142/255. alpha:1];
        characterCountLabel.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:characterCountLabel];

        
        // Setting the placeholders for the rest of the content
        
        fullName = [UIButton buttonWithType:UIButtonTypeCustom];
        fullName.frame = CGRectMake(53, 10, 0, 0);
        
        [fullName setTitleColor:[UIColor colorWithRed:207/255. green:197/255. blue:218/255. alpha:1] forState:UIControlStateNormal];
        fullName.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        
        [self.view addSubview:fullName];
        
        [[fullName layer] setShadowOffset:CGSizeMake(0, -1)];
        [[fullName layer] setShadowColor:[[UIColor blackColor] CGColor]];
        [[fullName layer] setShadowOpacity:1];
        [[fullName layer] setShadowRadius:0];

        username = [UIButton buttonWithType:UIButtonTypeCustom];
        username.frame = CGRectMake(53, 28, 200, 20);
        [username setTitleColor:[UIColor colorWithRed:126/255. green:81/255. blue:174/255. alpha:1] forState:UIControlStateNormal];
        username.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        [self.view addSubview:username];
        
        [[username layer] setShadowOffset:CGSizeMake(0, -1)];
        [[username layer] setShadowColor:[[UIColor blackColor] CGColor]];
        [[username layer] setShadowOpacity:1];
        [[username layer] setShadowRadius:0];
                
        myProfilePicture = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 32, 32)];
        myProfilePicture.clipsToBounds = YES;
        myProfilePicture.contentMode = UIViewContentModeScaleAspectFill;
        
        UIImageView *canvas = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"avatar-overlay-32.png"]];
        canvas.frame = CGRectMake(9, 9, 36, 36);
        
        [self.view addSubview:myProfilePicture];
        [self.view addSubview:canvas];
        
        if ([[CloudEngine sharedManager]isLoggedIn]) {
            pictureButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
            pictureButton.frame = CGRectMake(270, 160, 44, 44);
            [pictureButton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:pictureButton];
        }
    }
    return self;
}

- (void) takePicture{
    
    
    [self startCameraControllerFromViewController:self usingDelegate:self];
    
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.mediaTypes = [NSArray arrayWithObject:(id)kUTTypeImage];
    
    cameraUI.delegate = delegate;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    return YES;
    
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        // Save the new image (original or edited) to the Camera Roll
        [self dismissViewControllerAnimated:YES completion:^{
            
            [[CloudEngine sharedManager] uploadPictureToCloudApp:imageToSave WithDelegate:self];
            pictureButton.enabled = false;
            postButton.enabled = false;
            postTextView.editable = false;
            
        }];
        
    }
    
}

- (void) uploadDidComplete:(BOOL)flag WithLink:(NSString *)link {
    if (flag) {
        postTextView.text = [postTextView.text stringByAppendingString:[NSString stringWithFormat:@" %@",link]];
    }
    else {
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"We had an issue uploading your picture, can you try again ?" delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
        [alertview show];
    }
    
    postTextView.editable = TRUE;
    postButton.enabled = TRUE;
    [postTextView becomeFirstResponder];

}

- (void) viewWillAppear:(BOOL)animated{
    
    
    [super viewWillAppear:animated];
    
    UIImage *gradientImage44 = [[UIImage imageNamed:@"navbar-background.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.navigationController.navigationBar setBackgroundImage:gradientImage44
                                                  forBarMetrics:UIBarMetricsDefault];
    
    BOOL labelExists = NO;
    
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:[FXLabel class]]) {
            FXLabel *label = (FXLabel*) view;
            label.text = @"New Post";
            labelExists = YES;
        }
    }
    
    if (!labelExists) {
        
        FXLabel *navBarTitleLabel = [[FXLabel alloc]initWithFrame:CGRectMake(60, (44/2 - [UIFont fontWithName:@"HelveticaNeue-Bold" size:18].lineHeight /2 ), 200, [UIFont fontWithName:@"HelveticaNeue-Bold" size:18].lineHeight)];
        [self.navigationController.navigationBar addSubview:navBarTitleLabel];
        self.navigationController.navigationBar.clipsToBounds = YES;
        
        navBarTitleLabel.text = @"New Post";
        navBarTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        navBarTitleLabel.textColor = [UIColor colorWithRed:169/255. green:154/255. blue:186/255. alpha:1];
        navBarTitleLabel.backgroundColor = [UIColor clearColor];
        navBarTitleLabel.shadowColor = [UIColor blackColor];
        navBarTitleLabel.textAlignment = NSTextAlignmentCenter;
        navBarTitleLabel.shadowBlur=0;
        navBarTitleLabel.shadowOffset= CGSizeMake(0, -1);
        navBarTitleLabel.gradientStartColor = [UIColor whiteColor];
        navBarTitleLabel.gradientEndColor = [UIColor clearColor];
        navBarTitleLabel.gradientStartPoint = CGPointMake(0, 0.3);
        navBarTitleLabel.gradientEndPoint = CGPointMake(0, 0.8);
        navBarTitleLabel.numberOfLines = 1;
        [navBarTitleLabel clipsToBounds];
    }

    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"navbar-button-cancel-default.png"] forState:UIControlStateNormal];
    [cancelButton setImage:[UIImage imageNamed:@"navbar-button-cancel-active.png"] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(dismissPostStatusViewController) forControlEvents:UIControlEventTouchUpInside];
    
    cancelButton.frame = CGRectMake(0, 0, 52, 43);
    cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    UIBarButtonItem *cancelContainer = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem= cancelContainer;
    
    UIButton *postUIButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postUIButton setImage:[UIImage imageNamed:@"navbar-button-post-default.png"] forState:UIControlStateNormal];
    [postUIButton setImage:[UIImage imageNamed:@"navbar-button-post-active.png"] forState:UIControlStateHighlighted];
    [postUIButton addTarget:self action:@selector(internalPerformADNPost) forControlEvents:UIControlEventTouchUpInside];
    postUIButton.frame = CGRectMake(0, 0, 52, 43);
    postUIButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    postButton= [[UIBarButtonItem alloc] initWithCustomView:postUIButton];
    self.navigationItem.rightBarButtonItem = postButton;
    
    [self setPersonnalDetails];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(applyKeyboardSizeChange:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(applyKeyboardSizeChange:) name:UIKeyboardWillHideNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(applyKeyboardSizeChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
}



- (void)setPersonnalDetails{
    
    User *me = [[AppDotNetSyncingEngine sharedManager] currentUser];
    
    [fullName setTitle:me.fullname forState:UIControlStateNormal];
    [fullName sizeToFit];
        
    [username setTitle:[NSString stringWithFormat:@"@%@",me.username] forState:UIControlStateNormal];
    [username sizeToFit];

    [myProfilePicture setImageWithURL:[NSURL URLWithString:me.profilePictureURL]];
        
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [postTextView becomeFirstResponder];
    switch (postMode) {
        case ANPostModeNew:
            break;
        case ANPostModeReply:
            postTextView.text = draft.text;
            break;
        case ANPostModeRepost:
        {
            NSString *originalText = [postData objectForKey:@"text"];
            NSString *posterUsername = [postData objectForKey:@"user.username"];
            postTextView.text = [NSString stringWithFormat:@"RP @%@: %@", posterUsername, originalText];
            postTextView.selectedRange = NSMakeRange(0,0);
            break;
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForNotifications];

    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCharCountLabel:) name:UITextViewTextDidChangeNotification object:nil];
    [self addObserver:self forKeyPath:@"postText" options:0 context:0];
}

-(void) unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [self removeObserver:self forKeyPath:@"postText"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"postText"]) {
        postTextView.text = postText;
        [self updateCharCountLabel:nil];
    }
}

-(void) updateCharCountLabel: (NSNotification *) notification
{
    NSInteger textLength = 256 - [postTextView.text length];
    
    // account for the imgur url.
    if (postImage)
        textLength -= 29;
    
    // unblock / block post button
    if(textLength > 0 && textLength < 256) {
        postButton.enabled = YES;
    } else {
        postButton.enabled = NO;
    }
    
    characterCountLabel.text = [NSString stringWithFormat:@"%i", textLength];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    postTextView.text = textView.text;
}

- (void)internalPerformADNPost
{
    if([postTextView.text length] < 256)
    {
        draft.text = postTextView.text;
        self.navigationItem.rightBarButtonItem.enabled = FALSE;
        [draft createPostViaSession:[ANSession defaultSession] completion:^(ANResponse *response, ANPost * post, NSError * error) {
        if(!post) {
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"We had an issue posting"
                                  message: @"Try again !"
                                  delegate: self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"OK",nil];
            [alert show];
          
        }
            else{
                    
                [self posted];

            }
        }];
    }
}


- (void) posted {
    
        [self unregisterForNotifications];
        [[FGNotificationEngine sharedManager] refresh];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    
}


-(void)dismissPostStatusViewController
{
    
        [self dismissViewControllerAnimated:YES completion:nil];
        [self unregisterForNotifications];
        return;
   
}

-(IBAction) postStatusToAppNet:(id)sender
{
    if([postTextView.text length] < 256)
    {
        [postTextView resignFirstResponder];
        if (postImage)
        {
            /*
             [SVProgressHUD showWithStatus:@"Uploading image..." maskType:SVProgressHUDMaskTypeBlack];
             [[ANAPICall sharedAppAPI] uploadImage:postImage caption:@"" uiCompletionBlock:^(id dataObject, NSError *error) {
             NSString *urlForImage = [dataObject stringForKeyPath:@"upload.links.original"];
             if (urlForImage)
             {
             NSString *newPostText = [NSString stringWithFormat:@"%@ %@", postTextView.text, urlForImage];
             postTextView.text = newPostText;
             
             [self internalPerformADNPost];
             }
             else
             {
             [MKInfoPanel showPanelInView:self.view
             type:MKInfoPanelTypeError
             title:@"Image upload failed"
             subtitle:@"Imgur may be down for maintenance or overloaded."
             hideAfter:4];
             }
             [SVProgressHUD dismiss];
             }];
             */
        }
        else
        {
            [self internalPerformADNPost];
        }
    }
}


#pragma mark - Textview delegate


#pragma mark - UIKeyboard handling

- (void) applyKeyboardSizeChange:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    CGRect keyboardEndFrame;
    [[dict valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    keyboardEndFrame = [self.view convertRect:keyboardEndFrame fromView:nil];
    
   
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
