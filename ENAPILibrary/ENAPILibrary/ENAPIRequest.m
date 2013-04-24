//
//  ENAPIRequest.m
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

#import "ENAPI.h"

static NSTimeInterval requestTimeoutInterval = 30.0;
static NSString *boundary = @"0xKhTmLbOuNdArY";

@interface ENAPIRequest() {
    NSDictionary *_response;
    NSMutableDictionary *_parameters;
}

- (void)initiatePostRequest;
- (NSInteger)generateTimestamp;
- (NSString *)generateNonce:(NSInteger)timestamp;
- (NSString *)constructBaseSignatureForOAuth;
- (void)includeOAuthParams;

@property (nonatomic, copy) ENAPIRequestCompletionBlock completionBlock;

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, strong, readwrite) NSData *data;
@property (nonatomic, strong, readwrite) NSURLConnection *connection;
@property (nonatomic, strong, readwrite) NSHTTPURLResponse *urlResponse;

+ (void)setSharedSecret:(NSString *)secret;
+ (void)setConsumerKey:(NSString *)key;
+ (void)addSecuredEndpoint:(NSString *)endpoint;


@end

@implementation ENAPIRequest

@synthesize endpoint = _endpoint;
@synthesize completionBlock = _completionBlock;

@synthesize url = _url;
@synthesize error = _error;
@synthesize data = _data;
@synthesize urlResponse = _urlResponse;
@synthesize connection = _connection;

static NSString *EN_API_KEY = nil;
static NSString *EN_CONSUMER_KEY = nil;
static NSString *EN_SHARED_SECRET = nil;
static NSMutableArray *EN_SECURED_ENDPOINTS = nil;

#pragma mark - Private Constructor

- (ENAPIRequest *)initWithEndpoint:(NSString *)endpoint
                     andParameters:(NSDictionary *)parameters
                andCompletionBlock:(ENAPIRequestCompletionBlock)completionBlock {
    
    self = [super init];
    if (self) {
        
        //CHECK_API_KEY
        self.completionBlock = completionBlock;
        _endpoint = endpoint;
        [self.parameters addEntriesFromDictionary:parameters];
        [self.parameters setValue:[ENAPIRequest apiKey] forKey:@"api_key"];
        [self.parameters setValue:@"json" forKey:@"format"];
        if ([ENAPIRequest isSecuredEndpoint:_endpoint]) {
            // fail fast is consumer key & secret missing
            //CHECK_OAUTH_KEYS
            [self includeOAuthParams];
        }
        
        self.data = [NSMutableData new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendCancelNotification:) name:@"ENTasteProfileLibrary.cancel" object:nil];
        
    }
    return self;
}

#pragma mark - Private Methods

- (NSString *)constructURL {
    NSString *ret = [NSString stringWithFormat:@"%@%@?%@", ECHONEST_API_URL, self.endpoint, [ENAPI encodeDictionaryAsQueryString:self.parameters]];
    return ret;
}

- (NSInteger)generateTimestamp {
    NSDate *now = [[NSDate alloc] init];
    NSTimeInterval timestamp = [now timeIntervalSince1970];
    return (NSInteger)timestamp;
}

- (NSString *)generateNonce:(NSInteger)timestamp {
    NSString *tmp = [[NSString alloc] initWithFormat:@"%d", timestamp];
    NSData *nonceData = [tmp dataUsingEncoding:NSUTF8StringEncoding];
    NSString *nonce = [ENAPI calculateMD5DigestFromData:nonceData];
    return nonce;
}

- (NSString *)constructBaseSignatureForOAuth {
    NSString *queryString = [ENAPI encodeDictionaryAsQueryString:self.parameters];
    
    NSString *base_signature = [NSString stringWithFormat:@"GET&%@%@&%@",
                                ENEscapeStringForURL(ECHONEST_API_URL),
                                ENEscapeStringForURL(self.endpoint),
                                ENEscapeStringForURL(queryString)];
    
    NSString *signature = [ENAPI signString:base_signature andEncodeWithSecret:[ENAPIRequest sharedSecret]];
    
    return signature;
}

- (void)includeOAuthParams {
    NSTimeInterval timestamp = [self generateTimestamp];
    NSString *nonce = [self generateNonce:timestamp];
    
    [self.parameters setValue:[ENAPIRequest consumerKey] forKey:@"oauth_consumer_key"];
    [self.parameters setValue:[NSNumber numberWithInteger:(NSInteger)timestamp]  forKey:@"oauth_timestamp"];
    [self.parameters setValue:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
    [self.parameters setValue:nonce forKey:@"oauth_nonce"];
    [self.parameters setValue:@"1.0" forKey:@"oauth_version"];
    
    NSString *signature = [self constructBaseSignatureForOAuth];
    
    [self.parameters setValue: signature forKey:@"oauth_signature"];
}

- (void)cancelRequest {
    [self.connection cancel];
    [self executeCompletionBlock];
}

- (void)didSendCancelNotification:(NSNotification *)notification {
    [self cancelRequest];
}

- (void)executeCompletionBlock {
    if (_completionBlock != nil) {
        self.completionBlock(self);
    }
}

- (void)initiateGetRequest {
        
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?%@", ECHONEST_API_URL, self.endpoint, [ENAPI encodeDictionaryAsQueryString:self.parameters]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    
    [request setTimeoutInterval:requestTimeoutInterval];
    
    self.connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (self.connection == nil) {
        self.error = [NSError errorWithDomain:@"domain?" code:-1 userInfo:nil];
        [self executeCompletionBlock];
    } else {
    }
    
}


- (void)initiatePostRequest {
    
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ECHONEST_API_URL, self.endpoint]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    request.HTTPMethod = @"POST";
    
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    for (NSString *key in [self.parameters allKeys]) {
        NSObject *value = [self.parameters objectForKey:key];
        if ([value isKindOfClass:[NSData class]]) {
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Transfer-Encoding: binary\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:(NSData *)value];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSLog(@"ENAPIRequest: NSArray in a POST Request not implemented");
        } else {
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@", value] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    [body appendData:[[NSString stringWithFormat:@"--\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (body != nil) {
        [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:body];
    } else {
        NSLog(@"ENAPIRequest: post body is nil");
    }

    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (connection == nil) {
        self.error = [NSError errorWithDomain:@"domain?" code:-1 userInfo:nil];
        [self executeCompletionBlock];
    } else {
    }
}


#pragma mark - Class Methods

+ (void)cancelAllRequests {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ENAPIRequest.cancel" object:nil userInfo:nil];
}

+ (ENAPIRequest *)GETWithEndpoint:(NSString *)endpoint
                    andParameters:(NSDictionary *)parameters
               andCompletionBlock:(ENAPIRequestCompletionBlock)completionBlock {
    
    ENAPIRequest *request = [[ENAPIRequest alloc] initWithEndpoint:endpoint
                                                     andParameters:parameters
                                                andCompletionBlock:completionBlock];
    
    [request initiateGetRequest];
    return request;
}

+ (ENAPIRequest *)POSTWithEndpoint:(NSString *)endpoint
                     andParameters:(NSDictionary *)parameters
                andCompletionBlock:(ENAPIRequestCompletionBlock)completionBlock {
    
    ENAPIRequest *request = [[ENAPIRequest alloc] initWithEndpoint:endpoint
                                                     andParameters:parameters
                                                andCompletionBlock:completionBlock];
    [request initiatePostRequest];
    return request;
}

+ (void)setApiKey:(NSString *)apiKey {
    EN_API_KEY = apiKey;
}

+ (void)setApiKey:(NSString *)apiKey andConsumerKey:(NSString *)consumerKey
       andSharedSecret:(NSString *)secret {
    [ENAPIRequest setApiKey:apiKey];
    [ENAPIRequest addSecuredEndpoint:@"sandbox/access"];
    [ENAPIRequest setConsumerKey:consumerKey];
    [ENAPIRequest setSharedSecret:secret];
}

+ (NSString *)apiKey {
    return EN_API_KEY;
}

+ (NSString *)consumerKey {
    return EN_CONSUMER_KEY;
}

+ (void)setConsumerKey:(NSString *)key {
    if (EN_CONSUMER_KEY != key) {
        EN_CONSUMER_KEY = key;
    }
}

+ (NSString *)sharedSecret {
    return EN_SHARED_SECRET;
}

+ (void)setSharedSecret:(NSString *)secret {
    if (EN_SHARED_SECRET != secret) {
        // API is not using OAuth tokens in the signing process,
        // but the & suffix is still required for the secret.
        if ([secret hasSuffix:@"&"]) {
            EN_SHARED_SECRET = secret;
        } else {
            EN_SHARED_SECRET = [[NSString alloc] initWithFormat:@"%@&", secret];
        }
    }
}

+ (BOOL)isSecuredEndpoint:(NSString *)endpoint {
    return [EN_SECURED_ENDPOINTS containsObject:endpoint];
}

+ (void)addSecuredEndpoint:(NSString *)endpoint {
    if (nil == EN_SECURED_ENDPOINTS) {
        EN_SECURED_ENDPOINTS = [[NSMutableArray alloc] init];
    }
    [EN_SECURED_ENDPOINTS addObject:endpoint];
}

+ (NSArray *)securedEndpoints {
    return [EN_SECURED_ENDPOINTS copy];
}

#pragma mark - Properties

- (NSMutableDictionary *)parameters {
    if (_parameters == nil) {
        _parameters = [NSMutableDictionary new];
    }
    return _parameters;
}

- (NSDictionary *)response {
    if (_response == nil) {
        _response = [ENAPI parseJSONDataToDictionary:self.data];
    }
    return _response;
}

- (NSInteger)httpResponseCode {
    return self.urlResponse.statusCode;
}

- (NSInteger)echonestStatusCode {
    if (self.response == nil) {
        return -1;
    } else {
        return [[self.response valueForKeyPath:@"response.status.code"] intValue];
    }
}

- (NSString *)echonestStatusMessage {
    if (self.response == nil) {
        return @"Unknown Error";
    } else {
        return [self.response valueForKeyPath:@"response.status.message"];
    }
}

- (BOOL)completedSuccessfully {
    if (self.httpResponseCode == 200 && self.echonestStatusCode == 0) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (NSString *)errorMessage {
    NSString *result = nil;
    if (!self.completedSuccessfully) {
        if (self.error != nil) {
            result = self.error.localizedDescription;
        } else {
            result = self.echonestStatusMessage;
        }
    }
    return result;
}

#pragma NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [((NSMutableData *)self.data) appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.urlResponse = (NSHTTPURLResponse *)response;
    [((NSMutableData *)self.data) setLength:0];
}


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ENAPIRequest.didSendBodyData" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:bytesWritten], @"totalBytesWritten", [NSNumber numberWithInteger:totalBytesExpectedToWrite], @"totalBytesExpectedToWrite", nil]];
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request {
    NSLog(@"ENAPIRequest: unexpected needNewBodyStream");
    return nil;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self executeCompletionBlock];
}

#pragma NSURLConnectionDelegate
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    NSLog(@"ENAPIRequest: unexpected canAuthenticateAgainstProtectionSpace");
    return YES;
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"ENAPIRequest: unexpected didCancelAuthenticationChallenge");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.error = error;
    [self executeCompletionBlock];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"ENAPIRequest: unexpected didReceiveAuthenticationChallenge");
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"ENAPIRequest: unexpected willSendRequestForAuthenticationChallenge");
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    NSLog(@"ENAPIRequest: unexpected connectionShouldUseCredentialStorage");
    return YES;
}

@end
