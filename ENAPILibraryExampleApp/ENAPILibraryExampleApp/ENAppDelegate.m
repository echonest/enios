//
//  ENAppDelegate.m
//  ENLibraryExample
//
//  Created by Jon Oakes on 12/7/12.
//  Copyright (c) 2012 The Echo Nest. All rights reserved.
//

#import "ENAppDelegate.h"

#import "ENViewController.h"

@implementation ENAppDelegate

- (NSString *)apiKey {
    return [[[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)consumerKey {
    return [[[NSUserDefaults standardUserDefaults] stringForKey:@"consumerKey"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)sharedSecret {
    return [[[NSUserDefaults standardUserDefaults] stringForKey:@"sharedSecret"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)initializeSettingsToSettingsDefaults {
    NSLog(@"initializing settings to the settings defaults");
    
	NSString *pathStr = [[NSBundle mainBundle] bundlePath];
	NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
	NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
	
	NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
	NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
	
	NSMutableDictionary *appDefaults = [NSMutableDictionary new];
	
	NSDictionary *prefItem;
	for (prefItem in prefSpecifierArray) {
		NSString *keyValueStr = [prefItem objectForKey:@"Key"];
		id defaultValue = [prefItem objectForKey:@"DefaultValue"];
		
		if (keyValueStr != nil && defaultValue != nil) {
			[appDefaults setObject:defaultValue forKey:keyValueStr];
		}
	}
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initializeSettingsToSettingsDefaults];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ENViewController alloc] initWithNibName:@"ENViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ENViewController alloc] initWithNibName:@"ENViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    [[NSUserDefaults standardUserDefaults] synchronize];
    [ENAPIRequest setApiKey:self.apiKey  andConsumerKey:self.consumerKey  andSharedSecret:self.sharedSecret];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
