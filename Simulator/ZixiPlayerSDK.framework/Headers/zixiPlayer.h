//
//  videoPlayer.h
//  zixiClientSDKTester
//
//  Created by zixi on 7/11/17.
//  Copyright © 2017 zixi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import "ZixiPlayerSDKDelegates.h"

OBJC_VISIBLE @interface zixiPlayer : UIView 

/**
 Returns a zixiPlayer object initialized with the supplied dimensions.
 **/
-(nonnull instancetype)initWithFrame:(CGRect)frame;

/**
 * Send a connection request to a zixi broadcaster
 * @param zixiURL  		- zixi url (url format:  zixi://<server[:port]>/<stream_name>)
 * @param userName 		- user name passed to the zixi broadcaster for authorization purposes (limited to 45 characters)
 * @param password 		- password passed to the zixi broadcaster for authorization purposes (limited to 128 characters), can be nil (no password)
 * @param decryptionKey	- decryption key to use for manually encrypted streams (AES 128/192/256).
						  string must be 64/96/128 characters. can be nil if no encryption is used.
 * @param latency  		- connection latency in milliseconds
 **/
-(void) connect:(NSString* _Nonnull) zixiURL user:(NSString* _Nonnull) userName password:( NSString* _Nullable ) password decryptionKey:(NSString* _Nullable)decryptionKey latency:(NSInteger) latency ;

/**
 disconnect the streaming session
 **/
-(void) disconnect;

/**
 * Returns NSDictionary object with these keys:
 * kZixiPlayerNetworkBitrateKey             - current network bitrate
 * kZixiPlayerUnrecoveredPacketsKey         - amount of unrecovered packets
 * kZixiPlayerStreamSwitchKey				- total number of stream switch (adaptive streams only)
 * kZixiPlayerCompressedVideoQueueSizeKey   - compressed video queue size
 * kZixiPlayerCompressedVideoFramesDroppedKey - total number of dropped compressed video frames
 * kZixiPlayerTotalVideoFramesReceivedKey   - total number of received compressed video frames
 * kZixiPlayerTotalVideoBytesReceivedKey    - total number of bytes of compressed video frames
 * kZixiPlayerDecodedVideoFramesKey         - total number of decoded video frames
 * kZixiPlayerVideoDecoderErrors			- total number of decode errors
 * kZixiPlayerVideoDecodersResets			- total number of decoder resets
 *
 * kZixiPlayerCompressedAudioQueueSizeKey   - compressed audio queue size
 * kZixiPlayerCompressedAudioFramesDroppedKey - total number of dropped compressed audio frames
 * kZixiPlayerTotalAudioFramesReceivedKey   - total number of received compressed audio frames
 * kZixiPlayerTotalAudioBytesReceivedKey    - total number of bytes of compressed audio frames
 * kZixiPlayerDecodedAudioFramesKey         - total number of decoded audio frames
 *
 * Audio renderer
 * kZixiPlayerAudioRendererQueueSize		- current audio renderer queue size
 * kZixiPlayerAudioRendererMinQueueSize		- last minimal queue size (during the last 2 seconds)
 * kZixiPlayerAudioRendererMaxQueueSize		- last maximal queue size (during the last 2 seconds)
 * kZixiPlayerAudioRendererFramesRendered	- total number of played audio frames
 * kZixiPlayerAudioRendererPlayRate			- current audio renderer play rate

 **/
-(NSDictionary* _Nullable) getSessionInfo;

/**
 * Returns the current presentation time stamp of kCMTimeInvalid if stream is audio only
 **/
-(CMTime) getCurrentPTS;

/**
 * Returns the SDK version
 **/
+(NSString* _Nonnull) version;

/**
 * When connecting to an adaptive stream, availableBitrates array will contain the available bitrates as defined on the broadcaster
 * availableBitrates will be nil if the stream is non adaptive stream
 **/
@property (nonatomic, readonly, nullable) NSArray* availableBitrates;

/**
 * When connecting to an adaptive stream, use currentBitrate to switch between the bitrates (use values from availableBitrates array) or
 * set to nil to let the player to switch automatically according to the network conditions.
 **/
@property (nonatomic, nullable) NSNumber* currentBitrate;


/**
 * If set to TRUE, the player will connect automatically after an unexpectred disconnection
 * default is FALSE
 **/
@property (assign, nonatomic) BOOL autoReconnect;

/**
 * A delegate to a ZixiPlayerDelegate protocol.
 * The player will call the ZixiPlayerDelegate protocol methods and notify the user about player status changes
 **/
@property (weak, nullable) id <ZixiPlayerDelegate> delegate;

/**
 * A boolean property to indicate if the zixi player is paused or not
 **/
@property (nonatomic, readonly) BOOL isPaused;

@property (assign, nonatomic) ZixiDisplayMode displayMode;
@end
