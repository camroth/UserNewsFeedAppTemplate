//
//
//
//  Created by Garrett Parrish on 1/15/14.
//  Copyright (c) 2014 Gampets. All rights reserved.
//
//

#import "GPDebugViewController.h"

@interface GPDebugViewController ()

@end

@implementation GPDebugViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%@ viewWillAppear", self);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%@ viewDidAppear", self);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"%@ viewWillDisappear", self);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"%@ viewDidDisappear", self);
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    NSLog(@"%@ willMoveToParentViewController %@", self, parent);
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    NSLog(@"%@ didMoveToParentViewController %@", self, parent);
}

@end
