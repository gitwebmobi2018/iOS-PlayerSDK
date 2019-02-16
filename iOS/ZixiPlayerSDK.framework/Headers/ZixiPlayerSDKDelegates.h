//
//  ZixiPlayerSDKDelegates.h
//  ZixiPlayerSDK
//
//  Created by zixi on 11/29/17.
//  Copyright © 2017 zixi. All rights reserved.
//

#ifndef ZixiPlayerSDKDelegates_h
#define ZixiPlayerSDKDelegates_h

OBJC_VISIBLE extern NSString* kZixiPlayerVideoParamCodecKey;
OBJC_VISIBLE extern NSString* kZixiPlayerVideoParamWidthKey;
OBJC_VISIBLE extern NSString* kZixiPlayerVideoParamHeightKey;
OBJC_VISIBLE extern NSString* kZixiPlayerVideoParamFrameRateKey;

OBJC_VISIBLE extern NSString* kZixiPlayerAudioCodecKey;
OBJC_VISIBLE extern NSString* kZixiPlayerAudioParamChannelsKey;
OBJC_VISIBLE extern NSString* kZixiPlayerAudioParamSamplingRateKey;

OBJC_VISIBLE extern NSString* kZixiPlayerStatisticsNetworkBitrateKey;
OBJC_VISIBLE extern NSString* kZixiPlayerStatisticsUnrecoveredPacketsKey;
OBJC_VISIBLE extern NSString* kZixiPlayerStatisticsDroppedPacketsKey;
OBJC_VISIBLE extern NSString* kZixiPlayerStreamSwitchKey;
OBJC_VISIBLE extern NSString* kZixiPlayerStatisticsRTTKey;
OBJC_VISIBLE extern NSString* kZixiPlayerStatisticsJitterKey;

OBJC_VISIBLE extern NSString* kZixiPlayerCompressedVideoQueueSizeKey;
OBJC_VISIBLE extern NSString* kZixiPlayerCompressedVideoFramesDroppedKey;
OBJC_VISIBLE extern NSString* kZixiPlayerTotalVideoFramesReceivedKey;
OBJC_VISIBLE extern NSString* kZixiPlayerTotalVideoBytesReceivedKey;
OBJC_VISIBLE extern NSString* kZixiPlayerDecodedVideoFramesKey;
OBJC_VISIBLE extern NSString* kZixiPlayerVideoDecoderErrors;
OBJC_VISIBLE extern NSString* kZixiPlayerVideoDecoderResets;
OBJC_VISIBLE extern NSString* kZixiPlayerVideoRendererDropped;
OBJC_VISIBLE extern NSString* kZixiPlayerVideoRendererRendered;

OBJC_VISIBLE extern NSString* kZixiPlayerCompressedAudioQueueSizeKey;
OBJC_VISIBLE extern NSString* kZixiPlayerCompressedAudioFramesDroppedKey;
OBJC_VISIBLE extern NSString* kZixiPlayerTotalAudioFramesReceivedKey;
OBJC_VISIBLE extern NSString* kZixiPlayerTotalAudioBytesReceivedKey;
OBJC_VISIBLE extern NSString* kZixiPlayerDecodedAudioFramesKey;
OBJC_VISIBLE extern NSString* kZixiPlayerDecodedAudioFramesFailedKey;

OBJC_VISIBLE extern NSString* kZixiPlayerAudioRendererQueueSize;
OBJC_VISIBLE extern NSString* kZixiPlayerAudioRendererMinQueueSize;
OBJC_VISIBLE extern NSString* kZixiPlayerAudioRendererMaxQueueSize;
OBJC_VISIBLE extern NSString* kZixiPlayerAudioRendererFramesRendered;
OBJC_VISIBLE extern NSString* kZixiPlayerAudioRendererPlayRate;
OBJC_VISIBLE extern NSString* kZixiPlayerAudioRendererSilenceRendered;

typedef NS_ENUM(NSInteger, ZixiDisplayMode)
{
	ZixiDisplayModeAspectFit,
	ZixiDisplayModeAspectCrop
} ;

@class zixiPlayer;

@protocol ZixiPlayerDelegate <NSObject>
@required

/**
 * Called before the player is initiating the connection to the broadcaster
 * Called from the main thread
 * @param thePlayer - the player object who initiated the call
 **/
-(void) onConnecting:(zixiPlayer*)thePlayer;

/**
 * Called after the player established a connection with the broadcaster
 * Called from the main thread
 * @param thePlayer - the player object who initiated the call
 **/
-(void) onConnected:(zixiPlayer*)thePlayer;

/**
 * Called after the player established a connection with the broadcaster but it was disconnected unexpectedly
 * Called from the main thread
 * @param thePlayer - the player object who initiated the call
 **/
-(void) onReconnecting:(zixiPlayer*)thePlayer;

/**
 * Called after the player established a connection with the broadcaster and it was disconnected
 * Called from the main thread
 * @param thePlayer - the player object who initiated the call
 * @param error     - error code and description
 **/
-(void) onDisconnected:(zixiPlayer*)thePlayer with:(NSError*) error;

/**
 * Called after the player failed to establish a connection with the broadcaster
 * Called from the main thread
 * @param thePlayer - the player object who initiated the call
 * @param error     - error code and description
 **/
-(void) onFailedToConnect:(zixiPlayer*)thePlayer with:(NSError*) error;

/**
 * Called after the player established a connection to a broadcaster and the source on the broadcaster has (re)started
 * Called from the main thread
 * @param thePlayer - the player object who initiated the call
 **/
-(void) onSourceConnected:(zixiPlayer*)		thePlayer;

/**
 * Called after the player established a connection to a broadcaster and the source on the broadcaster has stopped
 * Called from the main thread
 * @param thePlayer - the player object who initiated the call
 **/
-(void) onSourceDisconnected:(zixiPlayer*)	thePlayer;

/**
 * Called on first connection and when switching bitrates
 * @param thePlayer     - the player object who initiated the call
 * @param videoSettings - a dictionary with the new settings
 * available keys:
 *  kZixiPlayerVideoParamCodecKey		- video codec,      type NSNumber, 1: H264, 3: HEVC
 *  kZixiPlayerVideoParamWidthKey   	- video width,      type NSNumber
 *  kZixiPlayerVideoParamHeightKey  	- video height,     type NSNumber
 *  kZixiPlayerVideoParamFrameRateKey 	- video framerate,  type NSNumber, frames per second
  **/
-(void) onVideoFormatChanged:(zixiPlayer*)	thePlayer newFormat:(NSDictionary*) videoSettings;

/**
 * Called on first connection and when switching bitrates
 * @param thePlayer     - the player object who initiated the call
 * @param audioSettings - a dictionary with the new settings
 * available keys:
 *  kZixiPlayerAudioCodecKey          		- audio codec,              type NSNumber, 0:AAC, 1:MP3, 2:AC3, 5:Opus
 *  kZixiPlayerAudioParamChannelsKey  		- number of audio channels, type NSNumber
 *  kZixiPlayerAudioParamSamplingRateKey	- audio sampling rate,      type NSNumber
 **/
-(void) onAudioFormatChanged:(zixiPlayer*)	thePlayer newFormat:(NSDictionary*) audioSettings;

/**
 * Called after the player switch bitrate (automatically or manually)
 * Called from the main thread
 * @param thePlayer     - the player object who initiated the call
 * @param bitrate       - current selected bitrate
 **/
-(void) onStreamBitrateChanged:(zixiPlayer*)  thePlayer newBitrate:(NSNumber*) bitrate;

/**
 * Called when the player don't have enough data to play
 * Called from the main thread
 * @param thePlayer     - the player object who initiated the call
 **/
-(void) onPause:(zixiPlayer*)  thePlayer;

/**
 * Called when the player's internal buffers are full again
 * Called from the main thread
 * @param thePlayer     - the player object who initiated the call
 **/
-(void) onResume:(zixiPlayer*)  thePlayer;

@end

#endif /* ZixiPlayerSDKDelegates_h */

