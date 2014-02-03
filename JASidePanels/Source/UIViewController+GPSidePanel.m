//
//
//
//  Created by Garrett Parrish on 1/15/14.
//  Copyright (c) 2014 Gampets. All rights reserved.
//
//
//

#import "UIViewController+GPSidePanel.h"

#import "GPSidePanelController.h"

@implementation UIViewController (GPSidePanel)

- (GPSidePanelController *)sidePanelController
{
    UIViewController *iter = self.parentViewController;
    while (iter)
    {
        if ([iter isKindOfClass:[GPSidePanelController class]])
        {
            return (GPSidePanelController *)iter;
        }
        else if (iter.parentViewController && iter.parentViewController != iter)
        {
            iter = iter.parentViewController;
        }
        else
        {
            iter = nil;
        }
    }
    return nil;
}

@end
