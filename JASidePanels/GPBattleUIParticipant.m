//
//  GPBattleUIParticipant.m
//  Gampets
//
//  Created by Garrett Parrish on 1/22/14.
//
//

#define kBorderWidth 3.0
#define kCornerRadius 8.0
#define kPadding 4.0
#define kProPicSize 35.0

#import "GPBattleUIParticipant.h"
#import "GPBattle.h"
#import "GPAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

NSString * const WIDTH = @"width";
NSString * const HEIGHT = @"height";
float const SIZETOFIT = 0.0;

UIImage* profilePicByUserId(NSString* userId)
{
    PFQuery *proPicQuery = [PFUser query];
    [proPicQuery whereKey:@"objectId" equalTo:userId];
    [proPicQuery selectKeys:@[@"profile_picture"]];
    
    PFObject *response = [[proPicQuery findObjects] firstObject];
    PFFile *pic = [response objectForKey:@"profile_picture"];
    
    UIImage *image = [[UIImage alloc] initWithData:[pic getData]];
    
    UIGraphicsBeginImageContext(CGSizeMake(kProPicSize, kProPicSize));
    UIGraphicsGetCurrentContext();
    
    [image drawInRect: CGRectMake(0, 0, kProPicSize, kProPicSize)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return smallImage;
}

@interface GPBattleUIParticipant ()

@property MPMoviePlayerController *videoPlayerController;
@property UIImageView *profilePictureView;
@property UIImageView *countryFlag;
@property UILabel *nameLabel;
@property UILabel *locationLabel;
@property UIButton *saveButton;

//@property

@end

@implementation GPBattleUIParticipant

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Set things to initial values (fake images etc. while dowloading)
        // Set activity indicators
        
    }
    return self;
}

- (void) setAsUser: (NSString *) user inBattle: (GPBattle *) battle
{
    BOOL user1 = [user isEqualToString:@"user_1"];
    PFUser *participant = user1 ? battle.user1 : battle.user2;
    self.video = user1 ? battle.user1Video : battle.user2Video;
    
    self.profilePicture = profilePicByUserId(participant.objectId);
    self.userName = participant.username;
    self.location = [participant objectForKey:@"location"];
    
    self.user = participant;
    self.flag = [UIImage imageNamed:[participant objectForKey:@"flag_code"]];

    [self _fillViewWithContent];
}

- (void) _fillViewWithContent
{
    // Profile Picture
    self.profilePictureView = [[UIImageView alloc] initWithImage:self.profilePicture];
    [self.profilePictureView setFrame:CGRectMake(0.0, 0.0, kProPicSize, kProPicSize)];
    [self addSubview:self.profilePictureView];
    
    // Name label
    CGFloat nameX = self.profilePictureView.frame.size.width + kPadding;
    CGFloat nameY = 0.0;
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameX, nameY, SIZETOFIT, SIZETOFIT)];
    self.nameLabel.text = self.userName;
    self.nameLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
    self.nameLabel.font = [UIFont systemFontOfSize:12.0];
    [self.nameLabel sizeToFit];
    [self addSubview:self.nameLabel];
    
    // Flag
    CGFloat flagX = nameX;
    CGFloat flagY = self.nameLabel.frame.size.height + kPadding;
    self.countryFlag = [[UIImageView alloc] initWithImage:self.flag];
    [self.countryFlag setFrame:CGRectMake(flagX, flagY, 26.4, 18.15)];
    [self addSubview:self.countryFlag];
    
    // Location label
    CGFloat locX = self.profilePictureView.frame.size.width + self.countryFlag.frame.size.width + kPadding * 2;
    CGFloat locY = flagY;
    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(locX, locY, SIZETOFIT, SIZETOFIT)];

    self.locationLabel.font = [UIFont systemFontOfSize:12.0];
    self.locationLabel.text = self.location;
    self.locationLabel.textColor = [UIColor colorWithRed:112.0/255.0 green:48.0/255.0 blue:160.0/255.0 alpha:1.0];

    [self.locationLabel sizeToFit];
    [self addSubview:self.locationLabel];
    
    // Video Player
    self.videoPlayerController = [[MPMoviePlayerController alloc] init];
    [self.videoPlayerController.view setFrame:CGRectMake(0.0, self.frame.size.height *.30f,
                                                         self.frame.size.width, self.frame.size.height *.70f)];

    // Write data to file
    NSData *videoFileData = [[self.video objectForKey:@"file"] getData];
    NSString *videoFileName = [NSString stringWithFormat:@"%@.mp4", self.video.objectId];
    NSURL *fileUrl = [AppDelegate() writeVideoData:videoFileData toFileName:videoFileName];
    [self.videoPlayerController setContentURL:fileUrl];
    self.videoPlayerController.shouldAutoplay = YES;
    self.videoPlayerController.fullscreen = NO;
    self.videoPlayerController.movieSourceType = MPMovieSourceTypeFile;
    [self addSubview:self.videoPlayerController.view];
    
    // Save Button
    self.saveButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width *.70f,
                                                                 self.frame.size.height *.70f,
                                                                 self.frame.size.width *.25f,
                                                                 self.frame.size.height *.25f)];
    self.saveButton.titleLabel.text = @"Save";
    self.saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.saveButton];
    
}

@end
