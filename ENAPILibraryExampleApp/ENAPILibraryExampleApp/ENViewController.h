//
//  ENViewController.h
//  ENLibraryExample
//
//  Created by Jon Oakes on 12/7/12.
//  Copyright (c) 2012 The Echo Nest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENAPI.h"

@interface ENViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *textView;

- (IBAction)clearButtonAction:(id)sender;
- (IBAction)testGETButtonAction:(id)sender;
- (IBAction)testPOSTButtonAction:(id)sender;

@end
