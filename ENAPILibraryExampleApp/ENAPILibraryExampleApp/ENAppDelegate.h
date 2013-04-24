//
//  ENAppDelegate.h
//  ENLibraryTestApp
//
//  Created by Jon Oakes on 1/7/13.
//  Copyright (c) 2013 The Echo Nest Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ENViewController;

@interface ENAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ENViewController *viewController;

@end
