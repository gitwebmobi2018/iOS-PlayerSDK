//
//  ViewController.m
//  ZixiPlayerSDKDemo
//
//  Created by zixi on 8/10/17.
//  Copyright © 2017 zixi. All rights reserved.
//

#import "ViewController.h"
#import "TRAutocompleteView/TRAutocompleteView.h"
#import "TRAutocompleteView/TRAutocompleteItemsSource.h"
#import "ZixiAutocompleteTableViewCell.h"
#import "ZixiSuggestion.h"
#import "TRTextFieldExtensions.h"

@interface ViewController () <TRAutocompleteItemsSource, TRAutocompletionCellFactory, ZixiPlayerDelegate>

@property (strong, nonatomic) UIAlertController* bitrateSelectionAC;
@property (strong, nonatomic) UIAlertController* latencySelectionAC;
@property (strong, nonatomic) UIAlertController* connectingAC;
@property (strong, nonatomic) UIAlertController* reconnectingAC;
@property (assign, nonatomic) BOOL clientConnected;
@property (strong, nonatomic) NSArray* latencies;
@property (assign, nonatomic) NSNumber* selectedLatency;
@property (strong, nonatomic) NSString* deviceName;
@property (strong, nonatomic) TRAutocompleteView* autocompleteView;
@property (strong, nonatomic) NSMutableArray* suggestionArray;
@property (strong, nonatomic) NSString* suggesntionsFilePath;
@property (strong, nonatomic) NSNumber* selectedBitrate;
@property (strong, nonatomic) NSTimer* sessionInfoTimer;

@end

@implementation ViewController

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter]  removeObserver:self];
}

NSArray * nameFromDeviceName(NSString * deviceName)
{
	NSError * error;
	static NSString * expression = (@"^(?:iPhone|phone|iPad|iPod)\\s+(?:de\\s+)?|"
									"(\\S+?)(?:['’]?s)?(?:\\s+(?:iPhone|phone|iPad|iPod))?$|"
									"(\\S+?)(?:['’]?的)?(?:\\s*(?:iPhone|phone|iPad|iPod))?$|"
									"(\\S+)\\s+");
	static NSRange RangeNotFound = (NSRange){.location=NSNotFound, .length=0};
	NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:expression
																			options:(NSRegularExpressionCaseInsensitive)
																			  error:&error];
	NSMutableArray * name = [NSMutableArray new];
	for (NSTextCheckingResult * result in [regex matchesInString:deviceName
														 options:0
														   range:NSMakeRange(0, deviceName.length)]) {
		for (int i = 1; i < result.numberOfRanges; i++) {
			if (! NSEqualRanges([result rangeAtIndex:i], RangeNotFound)) {
				[name addObject:[deviceName substringWithRange:[result rangeAtIndex:i]].capitalizedString];
			}
		}
	}
	return name;
}

-(void) dismissKeyboard:(UITapGestureRecognizer*) r
{
	[self.view endEditing:YES];
}
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
	tap.numberOfTapsRequired = 1;
	tap.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:tap];
	
	_versionLabel.text = [zixiPlayer version];
	_currentBitrate.text = @"";
	_unrecoveredPackets.text = @"";

	[_videoPlayer layoutIfNeeded];
	_videoPlayer.autoReconnect = YES;
	_currentBitrateButton.hidden = YES;
	_clientConnected = NO;
	
	_latencies = @[@(100), @(200), @(300), @(500), @(1000), @(1500), @(2000), @(3000), @(4000), @(6000), @(8000)];
	
//	_deviceName	= [UIDevice.currentDevice.name stringByAppendingFormat:@"-%@", UIDevice.currentDevice.identifierForVendor.UUIDString];

	_autocompleteView = [TRAutocompleteView autocompleteViewBindedTo:_txtZixiURL usingSource:self cellFactory:self presentingIn:self];
	_autocompleteView.topMargin = -5;
	_autocompleteView.backgroundColor = _txtZixiURL.backgroundColor;
	_autocompleteView.didAutocompleteWith = ^(id<TRSuggestionItem> item)
	{
		_txtZixiURL.text = [item completionText];
	};
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if (paths && paths.count > 0)
	{
		_suggesntionsFilePath = [paths[0] stringByAppendingPathComponent:@"suggestions.plist"];
	}
	
	if (_suggesntionsFilePath)
		_suggestionArray = [NSMutableArray arrayWithContentsOfFile:_suggesntionsFilePath];
	
	if (!_suggestionArray)
		_suggestionArray = [[NSMutableArray alloc] init];
    
    [_txtZixiURL setLeftPadding:55];
	
	_videoPlayer.delegate = self;
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void) showReconnecting
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_reconnectingAC = [UIAlertController alertControllerWithTitle:nil
															message:@"Reconnecting...\n\n"
													 preferredStyle:UIAlertControllerStyleAlert];
		
		UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		indicator.color = [UIColor blackColor];
		indicator.translatesAutoresizingMaskIntoConstraints=NO;
		[_reconnectingAC.view addSubview:indicator];
		NSDictionary * views = @{@"pending" : _reconnectingAC.view, @"indicator" : indicator};
		
		NSArray * constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicator]-(60)-|" options:0 metrics:nil views:views];
		NSArray * constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
		NSArray * constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
		[_reconnectingAC.view addConstraints:constraints];
		[indicator setUserInteractionEnabled:NO];
		[indicator startAnimating];
		
		UIAlertAction* action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
			if (_videoPlayer)
			{
				[_videoPlayer disconnect];
			}
		}];
		[_reconnectingAC addAction:action];
	});
	
	if (_reconnectingAC.popoverPresentationController)
	{
		_reconnectingAC.popoverPresentationController.permittedArrowDirections = 0;
		_reconnectingAC.popoverPresentationController.sourceView = self.view;
		_reconnectingAC.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds),
																			CGRectGetMidY(self.view.bounds), 0, 0);
	}
	
	if ([self presentedViewController] == _reconnectingAC)
		return;
	else if ([self presentedViewController] == _connectingAC)
	{
		[_connectingAC dismissViewControllerAnimated:NO completion:^{
			[self presentViewController:_reconnectingAC animated:YES completion:nil];
		}];
	}
	else
		[self presentViewController:_reconnectingAC animated:YES completion:nil];
}

-(void) showConnecting
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_connectingAC = [UIAlertController alertControllerWithTitle:nil
															message:@"Please wait...\n\n"
													 preferredStyle:UIAlertControllerStyleAlert];
		
		UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		indicator.color = [UIColor blackColor];
		indicator.translatesAutoresizingMaskIntoConstraints=NO;
		[_connectingAC.view addSubview:indicator];
		NSDictionary * views = @{@"pending" : _connectingAC.view, @"indicator" : indicator};
		
		NSArray * constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicator]-(20)-|" options:0 metrics:nil views:views];
		NSArray * constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
		NSArray * constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
		[_connectingAC.view addConstraints:constraints];
		[indicator setUserInteractionEnabled:NO];
		[indicator startAnimating];
		
	});
	
	if (_connectingAC.popoverPresentationController)
	{
		_connectingAC.popoverPresentationController.permittedArrowDirections = 0;
		_connectingAC.popoverPresentationController.sourceView = self.view;
		_connectingAC.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds),
																			CGRectGetMidY(self.view.bounds), 0, 0);
	}
	[self presentViewController:_connectingAC animated:YES completion:nil];
}

- (IBAction)onConnect:(id)sender
{
	@synchronized (self) {

		if (_txtZixiURL.text.length == 0)
			return;
			
		if (!_clientConnected)
		{
			if (_txtZixiURL)
				[_txtZixiURL resignFirstResponder];
			
			_connectButton.enabled = NO;
			
			NSString* url = [_txtZixiURL.text copy];
			
			if ([url hasPrefix:@"zixi://"])
			{
				url = [url stringByReplacingOccurrencesOfString:@"zixi://" withString:@""];
			}
			
			NSLog(@"%@", url);
			NSPredicate* p = [NSPredicate predicateWithFormat:@"SELF == %@", url];
			NSArray* exist = [_suggestionArray filteredArrayUsingPredicate:p];
			if (exist && exist.count > 0)
			{
				NSUInteger index = [_suggestionArray indexOfObject:exist[0]];
				if (index < _suggestionArray.count && index != NSNotFound)
				{
					[_suggestionArray removeObjectAtIndex:index];
				}
			}
			
			NSMutableArray* newArray = [[NSMutableArray alloc] initWithObjects:url, nil];
			[newArray addObjectsFromArray:_suggestionArray];
			_suggestionArray = newArray;
			
			if (_suggesntionsFilePath && _suggestionArray)
				[_suggestionArray writeToFile:_suggesntionsFilePath atomically:YES];

			if (_videoPlayer)
			{
				NSString* prefix = @"zixi://";
				url = [prefix stringByAppendingString:url];
				NSLog(@"%@", url);

				[self showConnecting];
				[_videoPlayer connect:url
								   user:UIDevice.currentDevice.name
							   password:nil
								latency:(_selectedLatency != nil ? _selectedLatency.integerValue : 1000) ];
			}
		}
		else
		{
			if (_videoPlayer)
			{
				[_videoPlayer disconnect];
			}
			
		}
	}
}

- (IBAction)onSelectBitrate:(id)sender
{
	if (_videoPlayer && _videoPlayer.availableBitrates == nil)
		return;
	
	 void (^handler)(UIAlertAction*) = ^void(UIAlertAction* action)
	{
		NSUInteger index = [_bitrateSelectionAC.actions indexOfObject:action];
		if (_videoPlayer &&_videoPlayer.availableBitrates && _videoPlayer.availableBitrates.count > index)
			_selectedBitrate = [_videoPlayer.availableBitrates objectAtIndex:index];
		
		if (_selectedBitrate &&
			_videoPlayer.currentBitrate &&
			_selectedBitrate.longLongValue != _videoPlayer.currentBitrate.longLongValue)
		{
			[_videoPlayer setCurrentBitrate:_selectedBitrate];
			_currentBitrateButton.enabled = NO;
		}
		[_bitrateSelectionAC dismissViewControllerAnimated:NO completion:nil];
		_bitrateSelectionAC = nil;
	};
	
	_bitrateSelectionAC = [UIAlertController alertControllerWithTitle:@"Available Bitrates" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	for (NSNumber* bitrate in _videoPlayer.availableBitrates)
	{
		NSString* newBitrate = [NSString stringWithFormat:@"%d kbps", bitrate.intValue / 1000];

		UIAlertAction* action = [UIAlertAction actionWithTitle:newBitrate style:UIAlertActionStyleDefault handler:handler];
		[_bitrateSelectionAC addAction:action];
	}

	UIAlertAction* autoBitrate = [UIAlertAction actionWithTitle:@"Auto" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
		if (_videoPlayer &&_videoPlayer.availableBitrates)
			[_videoPlayer setCurrentBitrate:nil];
		
		[_bitrateSelectionAC dismissViewControllerAnimated:NO completion:nil];
		_bitrateSelectionAC = nil;
	}];
	[_bitrateSelectionAC addAction:autoBitrate];

	UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){
		[_bitrateSelectionAC dismissViewControllerAnimated:NO completion:nil];
		_bitrateSelectionAC = nil;
	}];
	[_bitrateSelectionAC addAction:cancel];
	
	if (_bitrateSelectionAC.popoverPresentationController)
	{
		_bitrateSelectionAC.popoverPresentationController.sourceView = _currentBitrateButton;
		_bitrateSelectionAC.popoverPresentationController.sourceRect = CGRectMake(-50, 0, 120, 100);
	}
	
	[self presentViewController:_bitrateSelectionAC animated:NO completion:nil];

}

- (IBAction)onSelectLatency:(id)sender
{
	void (^handler)(UIAlertAction*) = ^void(UIAlertAction* action)
	{
		NSUInteger index = [_latencySelectionAC.actions indexOfObject:action];
		if (index < _latencies.count)
			_selectedLatency = [_latencies objectAtIndex:index];
		else
			_selectedLatency = @(1000);
		
		[_latencySelectionAC dismissViewControllerAnimated:NO completion:nil];
		_bitrateSelectionAC = nil;
		
		NSString* buttonTitle = [NSString stringWithFormat:@"%ld ms", (long)_selectedLatency.integerValue];
		[_latencyButton setTitle:buttonTitle forState:UIControlStateNormal];
	};
	
	_latencySelectionAC = [UIAlertController alertControllerWithTitle:@"Select Latency" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
	for (NSNumber* latency in _latencies)
	{
		NSString* newLatency = [NSString stringWithFormat:@"%d ms", latency.intValue];
		
		UIAlertAction* action = [UIAlertAction actionWithTitle:newLatency style:UIAlertActionStyleDefault handler:handler];
		[_latencySelectionAC addAction:action];
	}
	
	UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){
		[_latencySelectionAC dismissViewControllerAnimated:NO completion:nil];
		_latencySelectionAC = nil;
	}];
	[_latencySelectionAC addAction:cancel];
	
	if (_latencySelectionAC.popoverPresentationController)
	{
		_latencySelectionAC.popoverPresentationController.sourceView = _latencyButton;
		_latencySelectionAC.popoverPresentationController.sourceRect = CGRectMake(-50, -80, 120, 100);
	}
	
	[self presentViewController:_latencySelectionAC animated:NO completion:nil];
}
#pragma mark - zixi player callbacks

-(void) onConnecting:(zixiPlayer*)thePlayer
{
	NSLog(@"On Connecting");
}

-(void) onConnected:(zixiPlayer*)thePlayer
{
	NSLog(@"On Connected");
	if (_videoPlayer)
	{
        if (_sessionInfoTimer)
        {
            [_sessionInfoTimer invalidate];
            _sessionInfoTimer = nil;
        }
        _sessionInfoTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer* timer)
                             {
                                 NSDictionary* statistics = [_videoPlayer getSessionInfo];
                                 NSLog(@"on session info");
                                 if (statistics)
                                 {
                                     NSNumber* bitrate     = [statistics objectForKey:kZixiPlayerStatisticsNetworkBitrateKey];
                                     if (bitrate)
                                     {
                                         _currentBitrate.text = [NSString stringWithFormat:@"%ld kbps", (bitrate.integerValue / 1000)];
                                     }
                                     
                                     NSNumber* drops        = [statistics objectForKey:kZixiPlayerStatisticsUnrecoveredPacketsKey];
                                     if (drops)
                                     {
                                         _unrecoveredPackets.text = [NSString stringWithFormat:@"%ld", (long)drops.integerValue];
                                     }
                                 }

                             }];
        
		_currentBitrate.text = @"";
		_unrecoveredPackets.text = @"";

		if (_connectingAC &&[self presentedViewController] == _connectingAC)
			[_connectingAC dismissViewControllerAnimated:NO completion:nil];
		else if (_reconnectingAC &&[self presentedViewController] == _reconnectingAC)
			[_reconnectingAC dismissViewControllerAnimated:NO completion:nil];

		_connectButton.enabled = YES;
		if (_videoPlayer.availableBitrates != nil && _videoPlayer.availableBitrates.count > 1)
		{
			NSString* currentBitrateText = [NSString stringWithFormat:@"%d kbps", _videoPlayer.currentBitrate.intValue / 1000];
			[_currentBitrateButton setTitle:currentBitrateText forState:UIControlStateNormal];
			_currentBitrateButton.hidden = NO;
			_currentBitrateButton.enabled = YES;
		}
		else
		{
			_currentBitrateButton.hidden = YES;
		}
		
		[_connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
	}
	@synchronized (self) {
		_clientConnected = YES;
	}
}

-(void) onReconnecting:(zixiPlayer*)thePlayer
{
	[self showReconnecting];
}

-(void) onDisconnected:(zixiPlayer*)thePlayer with:(NSError*) error
{
	NSLog(@"On Disconnected");
	@synchronized (self) {
		_clientConnected = NO;
	}
    
    if (_sessionInfoTimer)
    {
        [_sessionInfoTimer invalidate];
        _sessionInfoTimer = nil;
    }
    
    void (^handler)(void) = ^void()
	{
		_connectButton.enabled 			= YES;
		_currentBitrateButton.enabled 	= YES;
		[_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
		
		
		if (error)
		{
			if (error.code != 0)
			{
				UIAlertController* alert = [UIAlertController alertControllerWithTitle:error.domain
																			   message:error.localizedDescription
																		preferredStyle:UIAlertControllerStyleActionSheet];
				
				UIAlertAction* ok = [UIAlertAction
									 actionWithTitle:@"OK"
									 style:UIAlertActionStyleDefault
									 handler:^(UIAlertAction * action)
									 {
										 [alert dismissViewControllerAnimated:NO completion:nil];
										 
									 }];
				
				
				[alert addAction:ok];
				if (alert.popoverPresentationController)
				{
					alert.popoverPresentationController.permittedArrowDirections = 0;
					alert.popoverPresentationController.sourceView = self.view;
					alert.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds),
																				CGRectGetMidY(self.view.bounds), 0, 0);
				}
				
				[self presentViewController:alert animated:NO completion:nil];
			}
		}
		_currentBitrateButton.hidden = YES;
	};
	
	if (_connectingAC && [self presentedViewController] == _connectingAC)
		[_connectingAC dismissViewControllerAnimated:NO completion:handler];
	else
		handler();
}

-(void) onFailedToConnect:(zixiPlayer*)thePlayer with:(NSError*) error
{
	NSLog(@"On Failed to connect");
	[self onDisconnected:thePlayer with:error];
}

-(void) onStreamBitrateChanged:(zixiPlayer*)  thePlayer newBitrate:(NSNumber*) bitrate
{
	NSLog(@"OnStreamBitrateChanged");
	
	if (bitrate)
	{
		if (_selectedBitrate && _selectedBitrate.longLongValue == bitrate.longLongValue)
		{
			_currentBitrateButton.enabled = YES;
		}
		NSString* currentBitrateText = [NSString stringWithFormat:@"%d kbps", _videoPlayer.currentBitrate.intValue / 1000];
		[_currentBitrateButton setTitle:currentBitrateText forState:UIControlStateNormal];
		_currentBitrateButton.hidden = NO;
	}
}

-(void) onSourceConnected:(zixiPlayer*)	thePlayer
{
	NSLog(@"onSourceConnected");
	
}

-(void) onSourceDisconnected:(zixiPlayer*) thePlayer
{
	NSLog(@"onSourceDisconnected");
	
}

-(void) onVideoFormatChanged:(zixiPlayer*)	thePlayer newFormat:(NSDictionary*) videoSettings
{
	NSLog(@"onVideoFormatChanged");
	
}

-(void) onAudioFormatChanged:(zixiPlayer*)	thePlayer newFormat:(NSDictionary*) audioSettings
{
	NSLog(@"onAudioFormatChanged");
	
}

#pragma mark -

-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		if (_videoPlayer)
			[_videoPlayer layoutIfNeeded];
	}  completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[self onConnect:nil];
	return YES;
}

-(void) startPlayerWithURL:(NSURL*) urlToOpen
{
	if (urlToOpen != nil)
	{
		NSString* url = urlToOpen.absoluteString;
		NSString* s1 = [url stringByReplacingOccurrencesOfString:@"zixi://" withString:@""];
		
		_txtZixiURL.text = s1;
		[self onConnect:nil];
	}
}

#pragma mark - TRAutocompleteItemSource
- (NSUInteger)minimumCharactersToTrigger
{
	return 0;
}

- (void)itemsFor:(NSString *)query whenReady:(void (^)(NSArray *))suggestionsReady
{
	if (!_suggestionArray)
		return;
	if (_suggestionArray.count == 0)
		return;
	
	NSArray* items = _suggestionArray;
	NSArray* not_items = nil;
	if (query && ![query isEqualToString:@""])
	{
		NSPredicate* p = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", query];
		items = [_suggestionArray filteredArrayUsingPredicate:p];

		NSPredicate* p2 = [NSPredicate predicateWithFormat:@"NOT (SELF BEGINSWITH %@)", query];
		not_items = [_suggestionArray filteredArrayUsingPredicate:p2];
	}
	
	NSMutableArray* b = [[NSMutableArray alloc] init];
	if (items)
	{
		for (NSString* str in items)
		{
			ZixiSuggestion* zs = [[ZixiSuggestion alloc] initWith:str];
			[b addObject:zs];
		}
	}
	
	if (not_items)
	{
		for (NSString* str in not_items)
		{
			ZixiSuggestion* zs = [[ZixiSuggestion alloc] initWith:str];
			[b addObject:zs];
		}
	}
	suggestionsReady(b);
}

#pragma mark - TRAutocompleteCellFactory
- (id <TRAutocompletionCell>)createReusableCellWithIdentifier:(NSString *)identifier
{
	ZixiAutocompleteTableViewCell *cell = [[ZixiAutocompleteTableViewCell alloc]
										initWithStyle:UITableViewCellStyleDefault
										reuseIdentifier:identifier];
	
	cell.textLabel.font = [UIFont systemFontOfSize:16];
	cell.textLabel.textColor = [UIColor whiteColor];
	
	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
	
}
@end
