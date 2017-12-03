//
//  ViewController.h
//  ZixiPlayerSDKDemo
//
//  Created by zixi on 8/10/17.
//  Copyright © 2017 zixi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZixiPlayerSDK/ZixiPlayerSDK.h>

@interface ViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtZixiURL;
@property (weak, nonatomic) IBOutlet zixiPlayer *videoPlayer;
@property (weak, nonatomic) IBOutlet UIButton *currentBitrateButton;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *latencyButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentBitrate;
@property (weak, nonatomic) IBOutlet UILabel *unrecoveredPackets;

- (IBAction)onConnect:(id)sender;
- (IBAction)onSelectBitrate:(id)sender;
- (IBAction)onSelectLatency:(id)sender;
-(void) startPlayerWithURL:(NSURL*) urlToOpen;
@end

