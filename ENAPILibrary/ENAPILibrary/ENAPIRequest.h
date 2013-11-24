//
//  ENAPIRequest.h
//  libechonest
//
//  Copyright (c) 2013, Echo Nest Corporation
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//   * Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//   * Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//   * Neither the name of the tapsquare, llc nor the names of its contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL TAPSQUARE, LLC. BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>

@class ENAPIRequest;

/**
 * type definition of the ENAPIRequest completion block
 */
typedef void (^ENAPIRequestCompletionBlock)(ENAPIRequest *);


/*
#define CHECK_API_KEY if (nil == [ENAPIRequest apiKey]) { @throw [NSException exceptionWithName:@"APIKeyNotSetException" reason:@"Set the API key before calling this method" userInfo:nil]; }

#define CHECK_OAUTH_KEYS if (nil == [ENAPIRequest consumerKey] && nil == [ENAPIRequest sharedSecret]) { @throw [NSException exceptionWithName:@"OAuthKeysNotSetException" reason:@"Set the consumer key & shared secret before calling this method" userInfo:nil]; }
 */

static NSString __attribute__((unused)) * const ECHONEST_API_URL = @"http://developer.echonest.com/api/v4/";

/**
 * ENAPIRequest is designed to provide a simple, easy to use interface to the [Echo Nest web service API](http://developer.echonest.com/docs/v4).
 * Before making an Echo Nest web service request, set the apiKey using the "setApiKey" class method.  Alternately if you intend to access secured endpoints, use the "setApiKey:andConsumerKey:andSharedSecret:" class method.
 * To make an Echo Nest HTTP GET or POST request use the "GETWithEndpoint:andParameters:andCompletionBlock" or "POSTWithEndpoint:andParameters:andCompletionBlock" class methods respectively.  Put the request parameters into a dictionary and pass them to the request.  Create and pass a completion block with an ENAPIRequest parameter to be executed when the request completes.  In the completion block, check that the request completed successfully and then access the result from the response Dictionary.
 * Example usage...
 
    [ENAPIRequest GETWithEndpoint:@"artist/news"
        andParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"Radiohead", @"name",[NSNumber numberWithInt:15], @"results",nil] 
        andCompletionBlock:^(ENAPIRequest *request) {
            if (request.completedSuccessfully) {
                NSLog(@"response: %@", request.response);
            } else {
                NSLog(@"errorMessage: %@", request.errorMessage);
            }];

 */
@interface ENAPIRequest : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {

}

/**
 * sets the Echo Nest api key for all subsequent requests.
 @param apiKey the  api key
 */
+ (void)setApiKey:(NSString *)apiKey;

/**
 * Sets the api key, consumer key and shared secret for all subsequent requests.
 * Consumer key and shared secret are required only if calling OAuth secured endpoints.  Example: "sandbox/access"
 @param apiKey The Echo Nest api key.
 @param consumerKey The Echo Nest consumer key.
 @param secret The Echo Nest shared secret.
 */
+ (void)setApiKey:(NSString *)apiKey andConsumerKey:(NSString *)consumerKey andSharedSecret:(NSString *)secret;

// these methods are only used internally
+ (NSString *)apiKey;
+ (NSString *)consumerKey;
+ (NSString *)sharedSecret;
+ (NSArray *)securedEndpoints;
+ (BOOL)isSecuredEndpoint:(NSString *)endpoint;


/**
 * Execute a Echo Nest Web Service GET request and represent the JSON response as a dictionary object.
 @param endpoint The Echo Nest webservice endpoint.
 @param parameters The parameters for this endpoint as key/value pairs.
 @param completionBlock The block of code to be executed on completion of the request, the request instance is returned as a parameter to allow access to the response and/or error information.
 @return Returns the request instance, intended to be used for debugging or canceling an individual request.
 */
+ (ENAPIRequest *)GETWithEndpoint:(NSString *)endpoint
                    andParameters:(NSDictionary *)parameters
               andCompletionBlock:(ENAPIRequestCompletionBlock)completionBlock;

/**
 * Execute a Echo Nest Web Service POST request and represent the JSON response as a dictionary object.
 @param endpoint The Echo Nest webservice endpoint.
 @param parameters The parameters for this endpoint as key/value pairs.
 @param completionBlock The block of code to be executed on completion of the request, the request instance is returned as a parameter to allow access to the response data and/or error information.
 @return returns The request instance, intended to be used for debugging or canceling an individual request.
 */
+ (ENAPIRequest *)POSTWithEndpoint:(NSString *)endpoint
                     andParameters:(NSDictionary *)parameters
                andCompletionBlock:(ENAPIRequestCompletionBlock)completionBlock;

/**
 * Cancels all active requests.
 */
+ (void)cancelAllRequests;

/**
 * Cancels an individual request.
 */
- (void)cancelRequest;

/**
 * The Echo Nest web service response decoded to an NSDictionary object.
 */
@property (readonly) NSDictionary *response;

/**
 * The http response code, 200 is a successful response.
 */
@property (readonly) NSInteger httpResponseCode;

/**
 * The Echo Nest status code, 0 is a successful status.  [Echo Nest response code list.](http://developer.echonest.com/docs/v4/index.html#response-codes)
 */
@property (readonly) NSInteger echonestStatusCode;

/**
 * The Echo Nest status message.
 */
@property (readonly) NSString *echonestStatusMessage;

/**
 * A boolean indicating that the request completed successfully, that is, if the response status code is 200 and the Echo Nest status code is 0.
 */
@property (readonly) BOOL completedSuccessfully;

/**
 * An error message if the request did not complete successfully.
 */
@property (readonly) NSString *errorMessage;

/**
 * The Echo Nest endpoint.
 */
@property (readonly) NSString *endpoint;

/**
 * The Echo Nest parameters used for this request.
 */
@property (readonly) NSMutableDictionary *parameters;

/**
 * The full URL used for this request, useful for debugging.
 */
@property (nonatomic, strong, readonly) NSURL *url;

/**
 * The NSError generated by the NSURLRequest, useful for debugging.
 */
@property (nonatomic, strong, readonly) NSError *error;

/**
 * The raw data returned by the service, useful for debugging.
 */
@property (nonatomic, strong, readonly) NSData *data;


@end
