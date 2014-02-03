//
//  GPUser.m
//  Gampets
//
//  Created by Garrett Parrish on 1/24/14.
//
//

#import "GPUser.h"
#import <Parse/Parse.h>

@implementation GPUser

- (id) initWithPFUser: (PFUser *) pfuser
{
    self = [super init];
    
    if (self)
    {
        self.userName = [pfuser username];
    }
    
    return self;
}

@end
