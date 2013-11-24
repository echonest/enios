//
//  ENViewController.m
//  ENLibraryExample
//
//  Created by Jon Oakes on 12/7/12.
//  Copyright (c) 2012 The Echo Nest. All rights reserved.
//

#import "ENViewController.h"
#import "ENAPI.h"

@interface ENViewController ()

@property (strong, nonatomic) ENAPIRequest *request;
@property (readonly) NSString *apiKey;
@property (readonly) NSString *consumerKey;
@property (readonly) NSString *sharedSecret;

@end

@implementation ENViewController

@synthesize request = _request;
@synthesize textView = _textView;

- (NSString *)apiKey {
    return [[[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendUpdateNotification:) name:@"ENTasteProfileLibrary.updateSent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUpdateCompleteNotification:) name:@"ENTasteProfileLibrary.updateComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSimilarQueryCompleteNotification:) name:@"ENTasteProfileLibrary.similarQueryComplete" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)clearButtonAction:(id)sender {
    self.textView.text = nil;
}

-(void)updateTextViewAfterNewsRequest:(ENAPIRequest *)request {
    self.textView.text = [NSString stringWithFormat:@"http status code: %d\nechonest status code: %d\nechonest status message: %@\nerror message: %@\nnews: %@",
                          request.httpResponseCode,
                          request.echonestStatusCode,
                          request.echonestStatusMessage,
                          request.errorMessage,
                          [request.response valueForKeyPath:@"response.news"]
                          ];
}

- (IBAction)testGETButtonAction:(id)sender {
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:@"Radiohead" forKey:@"name"];
    [parameters setValue:[NSNumber numberWithInteger:15] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/news"
                    andParameters:parameters
               andCompletionBlock:^(ENAPIRequest *request) {
                   [self updateTextViewAfterNewsRequest:request];
               }];
    
}

- (NSString *)uniqueId {
    CFUUIDRef cfuuidRef = CFUUIDCreate (NULL);
    CFStringRef cfStringRef = CFUUIDCreateString (NULL, cfuuidRef);
    CFRelease(cfuuidRef);
    NSString *result = (NSString *)CFBridgingRelease(cfStringRef);
    
    if (result == nil) {
        NSLog(@"Error unable to create unique Id");
    }
    
	return result;
}

- (IBAction)testPOSTButtonAction:(id)sender {
    NSString *catalogName = [self uniqueId];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:catalogName forKey:@"name"];
    [parameters setValue:@"song" forKey:@"type"];
    
    [ENAPIRequest POSTWithEndpoint:@"catalog/create" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         NSString *catalogId = (NSString *)[request.response valueForKeyPath:@"response.id"];

         self.textView.text = [NSString stringWithFormat:@"Catalog Create Request\nhttp status code: %d\nechonest status code: %d\nechonest status message: %@\nerror message: %@\nid: %@\n",
                               request.httpResponseCode,
                               request.echonestStatusCode,
                               request.echonestStatusMessage,
                               request.errorMessage,
                               catalogId
                               ];

         NSMutableDictionary *parameters = [NSMutableDictionary new];
         [parameters setValue:catalogId forKey:@"id"];
         
         [ENAPIRequest POSTWithEndpoint:@"catalog/delete" andParameters:parameters andCompletionBlock:
          ^(ENAPIRequest *request) {
              self.textView.text = [NSString stringWithFormat:@"%@\nCatalog Delete Request\nhttp status code: %d\nechonest status code: %d\nechonest status message: %@\nerror message: %@\nid: %@\n",
                                    self.textView.text,
                                    request.httpResponseCode,
                                    request.echonestStatusCode,
                                    request.echonestStatusMessage,
                                    request.errorMessage,
                                    catalogId
                                    ];
          }];
     }];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
