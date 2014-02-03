//
//  GPBattle.m
//  Gampets
//
//  Created by Garrett Parrish on 1/22/14.
//
//

#import "GPBattle.h"
#import "GPAppDelegate.h"

// Query helper methods
PFObject* battleById(NSString* battleId)
{
    PFQuery *battleQuery = [PFQuery queryWithClassName:GPBATTLE];
    [battleQuery getObjectWithId:battleId];
    return [[battleQuery findObjects] firstObject];
}

PFUser* userById(NSString* userId)
{
    PFQuery *userQuery = [PFUser query];
    [userQuery getObjectWithId:userId];
    return [[userQuery findObjects] firstObject];
}

PFObject* videoById(NSString* videoId)
{
    NSLog(@"Requesting video: %@", videoId);
    PFQuery *videoQuery = [PFQuery queryWithClassName:GPVIDEO];
    [videoQuery getObjectWithId:videoId];
    return [[videoQuery findObjects] firstObject];
}

@implementation GPBattle

- (id) initWithBattleId: (NSString *) battleId
{
    self = [super init];

    PFObject *battle = battleById(battleId);

    // Set properties of battle
    self.objectId = [battle objectForKey:@"objectId"];
    self.user1 = userById([battle objectForKey:@"user_1"]);
    self.user2 = userById([battle objectForKey:@"user_2"]);
    self.user1Video = videoById([battle objectForKey:@"video_1"]);
    self.user2Video = videoById([battle objectForKey:@"video_2"]);
    
    NSLog(@"Battle Created: %@ User 1: %@ (Video: %@) User 2: %@ (Video: %@)", self.objectId, self.user1.objectId, self.user1Video.objectId, self.user2.objectId, self.user2Video.objectId);
    
    return self;
}


@end
