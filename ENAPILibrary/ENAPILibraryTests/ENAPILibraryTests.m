//
//  ENAPILibraryTests.m
//  ENAPILibraryTests
//
//  Created by Jon Oakes on 1/13/13.
//  Copyright (c) 2013 The Echo Nest Corporation. All rights reserved.
//

#import "ENAPILibraryTests.h"
#import "ENAPI.h"
#import "ENAPIRequest.h"
#import "TestSemaphor.h"

static NSString *TEST_API_KEY = @"ZNXZA8ZGUJVNLWH87";


@implementation ENAPILibraryTests

- (void)setUp {
    [super setUp];
    [ENAPIRequest setApiKey:TEST_API_KEY];
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testNoAPIKey {
    [ENAPIRequest setApiKey:nil];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue: @"Radiohead" forKey:@"name"];
    [parameters setValue: [NSNumber numberWithInt:2] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/profile" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         NSLog(@"request %@", request);
         STAssertEquals(request.httpResponseCode, 400, @"Expected 400 response, got: %d", request.httpResponseCode);
         STAssertEquals(request.echonestStatusCode, 1, @"Expected 4 response, got: %d", request.echonestStatusCode);
         
         //NSLog(@"request.echonestStatusCode %d", request.echonestStatusCode);
         //NSLog(@"errorMessage %@", request.errorMessage);
         
         [[TestSemaphor sharedInstance] lift:@"testNoAPIKey"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testNoAPIKey"];
    [ENAPIRequest setApiKey:TEST_API_KEY];
    
}

- (BOOL)testSuccessfulCompletion:(ENAPIRequest *)request {
    STAssertEquals(request.httpResponseCode, 200, @"Expected 200 response, got: %d", request.httpResponseCode);
    STAssertEquals(request.echonestStatusCode, 0, @"Expected 0 response, got: %d", request.echonestStatusCode);
    STAssertNil(request.error, @"Expected nil response, got: %@", request.error);
    STAssertNil(request.errorMessage, @"Expected nil response, got: %@", request.errorMessage);
}



- (void)testArtistBiographies {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    NSArray *licenses = [NSArray arrayWithObjects:ENLicenseCreativeCommonsBy_SA, nil];
    [parameters setValue: @"Radiohead" forKey:@"name"];
    [parameters setValue: licenses forKey:@"license"];
    [parameters setValue: [NSNumber numberWithInt:1] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/biographies" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.biographies"] count], (NSUInteger)1, @"expected 1 result");
         [[TestSemaphor sharedInstance] lift:@"testArtistBiographies"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistBiographies"];
    
}


- (void)testArtistBiographiesNilLicenses {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue: @"Radiohead" forKey:@"name"];
    [parameters setValue: [NSNumber numberWithInt:5] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/biographies" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.biographies"] count], (NSUInteger)5, @"expected 5 results");
         [[TestSemaphor sharedInstance] lift:@"testArtistBiographies"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistBiographies"];
    
}

- (void)testArtistBlogs {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:@"Daft Punk" forKey:@"name"];
    [parameters setValue: [NSNumber numberWithInt:2] forKey:@"results"];
    [parameters setValue:[NSNumber numberWithBool:YES] forKey:@"high_relevance"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/blogs" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.blogs"] count], (NSUInteger)2, @"expected 2 results");
         [[TestSemaphor sharedInstance] lift:@"testArtistBlogs"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistBlogs"];

}

- (void)testArtistBlogsWithID {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:@"ARF8HTQ1187B9AE693" forKey:@"id"];
    [parameters setValue:[NSNumber numberWithBool:YES] forKey:@"high_relevance"];
    [parameters setValue: [NSNumber numberWithInt:2] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/blogs" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.blogs"] count], (NSUInteger)2, @"expected 2 results");
         [[TestSemaphor sharedInstance] lift:@"testArtistBlogsWithID"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistBlogsWithID"];
    
}

- (void)testArtistFamiliarity {
    NSString *searchArtist = @"Justin Bieber";
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:searchArtist forKey:@"name"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/familiarity" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         NSDictionary *artist = [request.response valueForKeyPath:@"response.artist"];
         STAssertTrue([[artist valueForKey:@"name"] isEqualToString:searchArtist], @"%@ != %@", [artist valueForKey:@"name"], searchArtist);
         [[TestSemaphor sharedInstance] lift:@"testArtistFamiliarity"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistFamiliarity"];
    
    
}

- (void)testArtistHotttnesss {
    NSString *searchArtist = @"Radiohead";
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:searchArtist forKey:@"name"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/hotttnesss" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         NSDictionary *artist = [request.response valueForKeyPath:@"response.artist"];
         STAssertTrue([[artist valueForKey:@"name"] isEqualToString:searchArtist], @"%@ != %@", [artist valueForKey:@"name"], searchArtist);
         [[TestSemaphor sharedInstance] lift:@"testArtistHotttnesss"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistHotttnesss"];
    
}

- (void)testArtistImages {
    NSString *searchArtist = @"Amanda Palmer";
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:searchArtist forKey:@"name"];
    [parameters setValue: [NSNumber numberWithInt:10] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/images" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.images"] count], (NSUInteger)10, @"expected 10 results");
         [[TestSemaphor sharedInstance] lift:@"testArtistImages"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistImages"];
    
    
}

- (void)testArtistNews {
    NSString *searchArtist = @"The New Pornographers";
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:searchArtist forKey:@"name"];
    [parameters setValue: [NSNumber numberWithInt:15] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/news" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.news"] count], (NSUInteger)15, @"expected 15 results");
         [[TestSemaphor sharedInstance] lift:@"testArtistNews"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistNews"];
    
}

- (void)testArtistProfile {
    NSString *searchArtist = @"RJD2";
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:searchArtist forKey:@"name"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/profile" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         NSDictionary *artist = [request.response valueForKeyPath:@"response.artist"];
         STAssertTrue([[artist valueForKey:@"name"] isEqualToString:searchArtist], @"Unexpected artist name");
         STAssertTrue([[artist valueForKey:@"id"] isEqualToString:@"ARQG4O41187B98A03B"], @"Unexpected artist id");
         [[TestSemaphor sharedInstance] lift:@"testArtistProfile"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistProfile"];
    
}

- (void)testArtistProfileWithBuckets {
    NSString *searchArtist = @"RJD2";
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:searchArtist forKey:@"name"];
    [parameters setValue:[NSArray arrayWithObjects:@"blogs", @"images", nil] forKey:@"bucket"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/profile" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         NSDictionary *artist = [request.response valueForKeyPath:@"response.artist"];
         STAssertTrue([[artist valueForKey:@"name"] isEqualToString:searchArtist], @"Unexpected artist name");
         STAssertTrue([[artist valueForKey:@"id"] isEqualToString:@"ARQG4O41187B98A03B"], @"Unexpected artist id");
         NSArray *blogs = [artist valueForKey:@"blogs"];
         STAssertNotNil(blogs, @"we should've gotten some blogs");
         NSArray *images = [artist valueForKey:@"images"];
         STAssertNotNil(images, @"we should've gotten some images");
         [[TestSemaphor sharedInstance] lift:@"testArtistProfileWithBuckets"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistProfileWithBuckets"];
    
}

- (void)testArtistReviews {
    NSString *searchArtist = @"Blockhead";
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:searchArtist forKey:@"name"];
    [parameters setValue: [NSNumber numberWithInt:15] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/reviews" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.reviews"] count], (NSUInteger)15, @"expected 15 results");
         [[TestSemaphor sharedInstance] lift:@"testArtistReviews"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistReviews"];
    
}

- (void)testArtistSongsWithName {
    NSString *searchArtist = @"Blockhead";
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:searchArtist forKey:@"name"];
    [parameters setValue:[NSNumber numberWithInt:15] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/songs" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.songs"] count], (NSUInteger)15, @"expected 15 results");
         [[TestSemaphor sharedInstance] lift:@"testArtistSongsWithName"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistSongsWithName"];
    
}

- (void)testArtistSongsWithID {
    NSString *ID = @"ARF8HTQ1187B9AE693";
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:ID forKey:@"id"];
    [parameters setValue:[NSNumber numberWithInt:15] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/songs" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.songs"] count], (NSUInteger)15, @"expected 15 results");
         [[TestSemaphor sharedInstance] lift:@"testArtistSongsWithID"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistSongsWithID"];
    
}

- (void)testArtistSearch {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:[NSArray arrayWithObjects:@"mood:chill", @"style:electronic", nil] forKey:@"description"];
    [parameters setValue:[NSNumber numberWithFloat:0.5f] forKey:@"min_familiarity"];
    [parameters setValue:[NSNumber numberWithFloat:0.5f] forKey:@"min_hotttnesss"];
    [parameters setValue:[NSNumber numberWithBool:YES] forKey:@"fuzzy_match"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/search" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         NSArray *artists = [request.response valueForKeyPath:@"response.artists"];
         STAssertTrue(artists.count > 0, @"Expected artist.count > 0");
         [[TestSemaphor sharedInstance] lift:@"testArtistSearch"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistSearch"];
    
}

- (void)testArtistSimilar {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:[NSArray arrayWithObjects:@"Radiohead", @"Portishead", nil] forKey:@"name"];
    [parameters setValue: [NSNumber numberWithInt:15] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/similar" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.artists"] count], (NSUInteger)15, @"expected 15 results");
         [[TestSemaphor sharedInstance] lift:@"testArtistSimilar"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistSimilar"];
    
}

- (void)testArtistTerms {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:@"RJD2" forKey:@"name"];
    [parameters setValue:ENSortWeight forKey:@"sort"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/terms" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         NSArray *terms = [request.response valueForKeyPath:@"response.terms"];
         STAssertTrue(terms.count > 0, @"Expected at least 1 term");
         [[TestSemaphor sharedInstance] lift:@"testArtistTerms"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistTerms"];
    
}

- (void)testArtistTopHottt {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue: [NSNumber numberWithInt:15] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/top_hottt" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.artists"] count], (NSUInteger)15, @"expected 15 results");
         [[TestSemaphor sharedInstance] lift:@"testArtistTopHottt"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistTopHottt"];
    
}

- (void)testArtistTopTerms {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue: [NSNumber numberWithInt:15] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/top_terms" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.terms"] count], (NSUInteger)15, @"expected 15 results");
         [[TestSemaphor sharedInstance] lift:@"testArtistTopTerms"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistTopTerms"];
    
}

- (void)testArtistURLs {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:@"Depeche Mode" forKey:@"name"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/urls" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         NSString *wikipediaURL = [request.response valueForKeyPath:@"response.urls.wikipedia_url"];
         STAssertTrue([wikipediaURL isEqualToString:@"http://en.wikipedia.org/wiki/Depeche_Mode"], @"Expected Wikipedia URL, got: %@", wikipediaURL);
         [[TestSemaphor sharedInstance] lift:@"testArtistURLs"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistURLs"];
    
}

- (void)testArtistVideo {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:@"Lady Gaga" forKey:@"name"];
    [parameters setValue: [NSNumber numberWithInt:15] forKey:@"results"];
    
    [ENAPIRequest GETWithEndpoint:@"artist/video" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.video"] count], (NSUInteger)15, @"expected 15 results");
         [[TestSemaphor sharedInstance] lift:@"testArtistVideo"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testArtistVideo"];
    
}

- (void)testSongSearch {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:@"Down with Hot Chip" forKey:@"combined"];
    [parameters setValue: [NSNumber numberWithInt:8] forKey:@"results"];
    [parameters setValue:[NSNumber numberWithFloat:0.9f] forKey:@"max_danceability"];
    
    [ENAPIRequest GETWithEndpoint:@"song/search" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.songs"] count], (NSUInteger)8, @"expected 8 results");
         [[TestSemaphor sharedInstance] lift:@"testSongSearch"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testSongSearch"];
    
}

- (void)testSongSearchBPM {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue: [NSNumber numberWithInt:25] forKey:@"results"];
    [parameters setValue:[NSNumber numberWithFloat:96.4f] forKey:@"max_tempo"];
    [parameters setValue:[NSNumber numberWithFloat:94.f] forKey:@"min_tempo"];
    [parameters setValue:[NSNumber numberWithFloat:0.9f] forKey:@"artist_max_familiarity"];
    [parameters setValue:[NSNumber numberWithFloat:0.5f] forKey:@"artist_min_familiarity"];
    [parameters setValue:[NSArray arrayWithObjects:@"style:hip-hop", @"mood:aggressive", nil] forKey:@"description"];
    
    [ENAPIRequest GETWithEndpoint:@"song/search" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.songs"] count], (NSUInteger)25, @"expected 25 results");
         [[TestSemaphor sharedInstance] lift:@"testSongSearchBPM"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testSongSearchBPM"];
    
}

- (void)testSongProfile {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue: [NSNumber numberWithInt:10] forKey:@"results"];
    [parameters setValue:[NSNumber numberWithFloat:100.f] forKey:@"max_tempo"];
    [parameters setValue:[NSNumber numberWithFloat:90.f] forKey:@"min_tempo"];
    [parameters setValue:[NSArray arrayWithObjects:@"style:indie", @"mood:pensive", nil] forKey:@"description"];
    
    [ENAPIRequest GETWithEndpoint:@"song/search" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         NSArray *songs = [request.response valueForKeyPath:@"response.songs"];
         STAssertEquals([[request.response valueForKeyPath:@"response.songs"] count], (NSUInteger)10, @"expected 10 results");

         
         NSMutableArray *ids = [NSMutableArray new];
         for (NSDictionary *song in songs) {
             [ids addObject:[song valueForKey:@"id"]];
         }
         
         NSMutableDictionary *parameters = [NSMutableDictionary new];
         [ENAPIRequest GETWithEndpoint:@"song/search" andParameters:parameters andCompletionBlock:
          ^(ENAPIRequest *request) {
              [parameters setValue:ids forKey:@"id"];
              [parameters setValue:[NSArray arrayWithObjects:@"audio_summary", nil] forKey:@"bucket"];
              STAssertEquals([[request.response valueForKeyPath:@"response.songs"] count], (NSUInteger)15, @"expected 15 results");
              [[TestSemaphor sharedInstance] lift:@"testSongProfile"];
          }];
         
         
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testSongProfile"];
    
}

- (void)testTrackProfile {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.echonest.ENAPILibraryTests"];
    NSString *testMp3Path = [[bundle URLForResource:@"test" withExtension:@"mp3"] path];
    NSData *data = [NSData dataWithContentsOfFile:testMp3Path];
    NSString *md5 = [ENAPI calculateMD5DigestFromData:data];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:md5 forKey:@"md5"];
    [parameters setValue:@"audio_summary" forKey:@"bucket"];
    
    [ENAPIRequest GETWithEndpoint:@"track/profile" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         NSDictionary *track = [request.response valueForKeyPath:@"response.track"];
         STAssertTrue([[track valueForKey:@"artist"] isEqualToString:@"Tycho"], @"Expected matching artist");
         [[TestSemaphor sharedInstance] lift:@"testTrackProfile"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testTrackProfile"];
    
}

- (void)testStaticPlaylist {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:@"artist-description" forKey:@"type"];
    [parameters setValue:@"mood:chill" forKey:@"description"];
    [parameters setValue:[NSNumber numberWithFloat:95.f] forKey:@"max_tempo"];
    [parameters setValue:[NSNumber numberWithFloat:90.f] forKey:@"min_tempo"];
    [parameters setValue:[NSNumber numberWithFloat:0.7f] forKey:@"artist_min_hotttnesss"];
    [parameters setValue:[NSNumber numberWithInteger:0] forKey:@"key"];  // C
    [parameters setValue:[NSNumber numberWithInteger:0] forKey:@"mode"]; // minor
    [parameters setValue:@"audio_summary" forKey:@"bucket"];
    
    [ENAPIRequest GETWithEndpoint:@"playlist/static" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         STAssertEquals([[request.response valueForKeyPath:@"response.songs"] count], (NSUInteger)15, @"expected 1 results");
         [[TestSemaphor sharedInstance] lift:@"testStaticPlaylist"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testStaticPlaylist"];
    

}

- (void)test404 {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    [ENAPIRequest GETWithEndpoint:@"foo/bar" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         STAssertTrue(request.httpResponseCode == 404, @"Expected 404");
         [[TestSemaphor sharedInstance] lift:@"test404"];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"test404"];
    
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


- (void)testCatalogCreateDelete {
    NSString *catalogName = [self uniqueId];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:catalogName forKey:@"name"];
    [parameters setValue:@"song" forKey:@"type"];
    
    [ENAPIRequest POSTWithEndpoint:@"catalog/create" andParameters:parameters andCompletionBlock:
     ^(ENAPIRequest *request) {
         [self testSuccessfulCompletion:request];
         NSString *catalogId = (NSString *)[request.response valueForKeyPath:@"response.id"];
         STAssertNotNil(catalogId, @"expected not nil id result");
         
         NSMutableDictionary *parameters = [NSMutableDictionary new];
         [parameters setValue:catalogId forKey:@"id"];
         
         [ENAPIRequest POSTWithEndpoint:@"catalog/delete" andParameters:parameters andCompletionBlock:
          ^(ENAPIRequest *request) {
              [self testSuccessfulCompletion:request];
              [[TestSemaphor sharedInstance] lift:@"testCatalogCreateDelete"];
          }];
     }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"testCatalogCreateDelete"];
    
}



@end
