//
//  GPUser.h
//  Gampets
//
//  Created by Garrett Parrish on 1/24/14.
//
//

#import <Foundation/Foundation.h>

@interface GPUser : NSObject

@property UIImage *profilePicture;
@property NSDictionary *profile;
@property NSMutableArray *history;
@property NSString *userName;
@property NSString *location;
@property NSString *accountType;

@end
