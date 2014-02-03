//
//
//
//  Created by Garrett Parrish on 1/15/14.
//  Copyright (c) 2014 Gampets. All rights reserved.
//
//
//

#import "GPAppDelegate.h"
#import "GPLeftViewController.h"
#import "GPSidePanelController.h"

#import "UIViewController+GPSidePanel.h"
#import "GPCenterViewController.h"
#import "GPLogInViewController.h"

@interface GPLeftViewController ()

@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) UIButton *changeCenterPanel;

@property (nonatomic, weak) UIButton *homeButton;
@property (nonatomic, weak) UIButton *activityButton;
@property (nonatomic, weak) UIButton *friendsButton;
@property (nonatomic, weak) UIButton *battleButton;
@property (nonatomic, weak) UIButton *settingsButton;
@property (nonatomic, weak) UIButton *signOutButton;

@end

@implementation GPLeftViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor grayColor];
	
	UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:30.0f];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
	
    label.text = [PFUser currentUser].username;
    
    UIImageView *proPic = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 200.0f, 200.0f)];

    [[PFUser currentUser] objectForKey:@"profile_picture"];

    
	[label sizeToFit];
	label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:label];
    self.label = label;

    CGFloat buttonSpacing = 60.0f;
    CGFloat firstButtonY = 100.0f;
    
    // Home
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, firstButtonY + buttonSpacing * 0.0, 200.0f, 40.0f);
    [button setTitle:@"HOME" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_homeTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self formatAndAddButton:button];
    self.homeButton = button;
    
    // Activity
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, firstButtonY + buttonSpacing * 1.0, 200.0f, 40.0f);
    [button setTitle:@"ACTIVITY" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_activityTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self formatAndAddButton:button];
    self.activityButton = button;

    // Friends
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, firstButtonY + buttonSpacing * 2.0, 200.0f, 40.0f);
    [button setTitle:@"FRIENDS" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_friendsTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self formatAndAddButton:button];
    self.friendsButton = button;

    // Battle
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, firstButtonY + buttonSpacing * 3.0, 200.0f, 40.0f);
    [button setTitle:@"BATTLE" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_battleTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self formatAndAddButton:button];
    self.battleButton = button;

    // Settings
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, firstButtonY + buttonSpacing * 4.0, 200.0f, 40.0f);
    [button setTitle:@"SETTINGS" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_settingsTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self formatAndAddButton:button];
    self.settingsButton = button;

    // Sign out
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, firstButtonY + buttonSpacing * 5.0, 200.0f, 40.0f);
    [button setTitle:@"SIGN OUT" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_signOutTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self formatAndAddButton:button];
    
    self.signOutButton = button;

}

- (void) formatAndAddButton: (UIButton *) button
{
    button.titleLabel.font = [UIFont systemFontOfSize:25.0f];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.label.center = CGPointMake(floorf(self.sidePanelController.leftVisibleWidth/2.0f), 45.0f);
}

#pragma mark - Button Actions

- (void) _homeTapped:(id)sender
{
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[GPCenterViewController alloc] init]];
}

- (void) _activityTapped:(id)sender
{
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[GPCenterViewController alloc] init]];
}

- (void) _friendsTapped:(id)sender
{
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[GPCenterViewController alloc] init]];
}

- (void) _battleTapped:(id)sender
{
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[GPCenterViewController alloc] init]];
}

- (void) _settingsTapped:(id)sender
{
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[GPCenterViewController alloc] init]];
}

- (void) _signOutTapped:(id)sender
{
    [PFUser logOut];
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
