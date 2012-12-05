//
//  SettingsViewController.m
//  Fudge
//
//  Created by Frederic Jacobs on 2/9/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "SettingsViewController.h"
#import "FXLabel.h"
#import "AppDelegate.h"
#import "CloudEngine.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	UIImage *gradientImage44 = [[UIImage imageNamed:@"navbar-background.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.navigationController.navigationBar setBackgroundImage:gradientImage44
                                                  forBarMetrics:UIBarMetricsDefault];
    
    
    
    FXLabel *navBarTitleLabel = [[FXLabel alloc]initWithFrame:CGRectMake(60, (44/2 - [UIFont fontWithName:@"HelveticaNeue-Bold" size:18].lineHeight /2 ), 200, [UIFont fontWithName:@"HelveticaNeue-Bold" size:18].lineHeight)];
    [self.navigationController.navigationBar addSubview:navBarTitleLabel];
    self.navigationController.navigationBar.clipsToBounds = YES;
    
    navBarTitleLabel.text = @"Settings";
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
    
    self.view.backgroundColor = [UIColor colorWithRed:23.0/255 green:15.0/255 blue:28.0/255 alpha:1];
    
    UIButton *confirmButtonUI = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButtonUI setImage:[UIImage imageNamed:@"navbar-button-post-default.png"] forState:UIControlStateNormal];
    [confirmButtonUI setImage:[UIImage imageNamed:@"navbar-button-post-active.png"] forState:UIControlStateHighlighted];
    [confirmButtonUI addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    confirmButtonUI.frame = CGRectMake(0, 0, 52, 43);
    confirmButtonUI.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:confirmButtonUI];
    
    UIButton *signoff = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    signoff.frame = CGRectMake(60, 44, 200, 44);
    [signoff setTitle:@"Sign Off" forState:UIControlStateNormal];
    
    [signoff addTarget:self action:@selector(signoff) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:signoff];
    
    
    cloudAppButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    cloudAppButton.frame = CGRectMake(10, 90, 300, 44);
    
    [self updateCloudAppLabel];
    
    [cloudAppButton addTarget:self action:@selector(cloudAppLogin) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:cloudAppButton];
    
}

- (void) updateCloudAppLabel{
    
    if ([[CloudEngine sharedManager] isLoggedIn]) {
        [cloudAppButton setTitle:[NSString stringWithFormat:@"Log out of %@",[[CloudEngine sharedManager]email]] forState:UIControlStateNormal];
    }
    else{
        [cloudAppButton setTitle:@"Sign In for CloudApp" forState:UIControlStateNormal];
    }
    
}

- (void) cloudAppLogin {
    if (![[CloudEngine sharedManager] isLoggedIn]) {
    
        UIAlertView *login = [[UIAlertView alloc]initWithTitle:@"Login to CloudApp" message:@"" delegate:self cancelButtonTitle:@"Sign In" otherButtonTitles:nil, nil];
        [login setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        UITextField *nameField = [login textFieldAtIndex:0];
        nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        nameField.placeholder = @"Email"; // Replace the standard placeholder text with something more applicable
        nameField.delegate = self;
        UITextField *passwordField = [login textFieldAtIndex:1]; // Capture the Password text field since there are 2 fields
        passwordField.delegate = self;
        [login show];
    }
    else {
        [[CloudEngine sharedManager]logoutAndCleanUp];
        [self updateCloudAppLabel];
        
    }

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput) {
        NSString *email =[[alertView textFieldAtIndex:0] text];
        NSString *password =[[alertView textFieldAtIndex:1] text];
        [[CloudEngine sharedManager] loginWithUsername:email Password:password AndDelegate:self];
    }
}


- (void) signoff {
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [delegate signOffAndCleanup];
    
}

- (void) loginDidSucceed:(BOOL)flag{
    
    if (flag) {
        [self updateCloudAppLabel];
    }
    else{
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Are you sure about that password ?" delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
        [alertview show];
    }
    
}

- (void) dismiss{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
