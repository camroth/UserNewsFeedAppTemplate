//
//  GPBattleUIParticipant.h
//  Gampets
//
//  Created by Garrett Parrish on 1/22/14.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "GPBattle.h"

@interface GPBattleUIParticipant : UIView

@property UIImage *profilePicture;
@property NSString *userName;
@property NSString *location;
@property PFUser *user;
@property UIImage *flag;
@property PFObject *video;

- (void) setAsUser: (NSString *) user inBattle: (GPBattle *) battle;

@end
