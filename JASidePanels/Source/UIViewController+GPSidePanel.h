//
//
//
//
//  Created by Garrett Parrish on 1/15/14.
//  Copyright (c) 2014 Gampets. All rights reserved.
//
//
//


#import <Foundation/Foundation.h>

@class GPSidePanelController;

/* This optional category provides a convenience method for finding the current
 side panel controller that your view controller belongs to. It is similar to the
 Apple provided "navigationController" and "tabBarController" methods.
 */
@interface UIViewController (GPSidePanel)

// The nearest ancestor in the view controller hierarchy that is a side panel controller.
@property (nonatomic, weak, readonly) GPSidePanelController *sidePanelController;

@end
