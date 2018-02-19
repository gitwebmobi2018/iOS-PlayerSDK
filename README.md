# iOS-OnAirSdk

Importing ZixiOnAirSDKStatic.Framework to your project :

1. Click on project navigator
2. Select your project (in project navigator)
3. Select your target
4. Click on "Build Phases"
5. Expand "Embedded Binaries"
6. Drag and drop "ZixiPlayerSDK.framework" on to the list
7. Click on "Build Settings" and type 'search' in the search box
8. Make sure that XCode added the path of ZixiPlayerSDK to "Framework Search Paths"
9. Type 'Other Linker Flags' in the search box
10. Add '-all_load' flag to 'Other Linker Flags'

#import <ZixiPlayerSDK/ZixiPlayerSDK.h> from a .h or .m file file (e.g. UIViewController.h)

Using the framework:
You can either use it dynamically (creating objects in run time) or within the interface builder.

Using it dynamically
1. import <ZixiPlayerSDK/ZixiPlayerSDK.h> to your .m file
2. Add a new property to your interface. property type is zixiPlayer*
3. allocate and initilaze the object by using initWithFrame
4. add the new object to your view ([self.view addSubView:_videoPlayer])
5. use the SDK functions to connect/disconnect to/from zixi stream

-(void) viewDidLoad
{
	[super viewDidLoad];
	
	_videoPlayer = [[zixiPlayer alloc] initWithFrame:CGRectMake(0,0,200,200)];
	[self.view addSubView:_videoPlayer];
}

-(IBAction) onConnect:(id)sender
{
	if (_videoPlayer)
	{
		[_videoPlayer connect:url
						   user:UIDevice.currentDevice.name
					   password:nil
				  decryptionKey:nil
						latency:1000];
	}
}

Using the SDK within the interface builder:
1. Open the h file of you view (controller)
2. import <ZixiPlayerSDK/ZixiPlayerSDK.h> to your .h file
3. Open the interface builder and add a simple view to your viewcontroller/view
4. Open the identity inspector
5. Make sure to select the newly added view and set 'Class' to 'zixiPlayer' (in the identity inspector)
6. Create an outlet for your newly added view in the view controller h file. make sure to set the type to 'zixiPlayer'.
7. Use it (see onConnect: above)

