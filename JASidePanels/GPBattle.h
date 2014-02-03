//
//  GPBattle.h
//  Gampets
//
//  Created by Garrett Parrish on 1/22/14.
//
//

#import "GPAppDelegate.h"
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

static NSString *const GPBATTLE = @"GPBattle";
static NSString *const GPVIDEO = @"GPVideo";

@interface GPBattle : NSObject

- (id) initWithBattleId: (NSString *) battleId;

@property PFUser *user1;
@property PFUser *user2;
@property PFObject *user1Video;
@property PFObject *user2Video;
@property NSString *objectId;

@end
