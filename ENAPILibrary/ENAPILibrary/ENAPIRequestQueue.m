//
//  ENAPIRequestQueue.m
//  ENAPILibrary
//
//  Created by Andrew Goodale (andrew@seaviewsoftware.com)
//  Copyright (c) 2014, Echo Nest Corporation
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

#import "ENAPIRequestQueue.h"
#import "ENAPIRequest.h"

const long kMaxSimultaneousRequests = 4;

static NSString *const kHeaderLimit = @"X-RateLimit-Limit";             // the current rate limit for this API key
static NSString *const kHeaderLimitUsed = @"X-RateLimit-Used";          // the number of method calls used on this API key this minute
static NSString *const kHeaderLimitRemaining= @"X-RateLimit-Remaining"; // the estimated number of remaining calls allowed by this API key this minute


@implementation ENAPIRequestQueue
{
    dispatch_queue_t     _requestQueue;
    dispatch_semaphore_t _netSemaphore;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _requestQueue = dispatch_queue_create("ENAPIRequestQueue", DISPATCH_QUEUE_SERIAL);
        _netSemaphore = dispatch_semaphore_create(kMaxSimultaneousRequests);
    }
    
    return self;
}

- (void)GETWithEndpoint:(NSString *)endpoint
          andParameters:(NSDictionary *)parameters
     andCompletionBlock:(ENAPIRequestCompletionBlock)completionBlock
{
    dispatch_semaphore_t netSemaphore = _netSemaphore;
    
    dispatch_async(_requestQueue, ^{
        // Wait for the semaphore to get our access to the network
        dispatch_semaphore_wait(netSemaphore, DISPATCH_TIME_FOREVER);
        
        // Initiate the request on the main thread, because NSURLConnection prefers that
        dispatch_async(dispatch_get_main_queue(), ^{
            [ENAPIRequest GETWithEndpoint:endpoint andParameters:parameters andCompletionBlock:^(ENAPIRequest *request) {
                NSDictionary *headers = request.httpResponseHeaders;
                NSString *limitRemaining = [headers objectForKey:kHeaderLimitRemaining];
#if DEBUG
                NSLog(@"ENAPIRequestQueue: Limit Used %@, Remaining %@", [headers objectForKey:kHeaderLimitUsed], limitRemaining);
#endif
                // If the API limit is being reached, don't signal the semaphore for a minute. That will block tasks until the
                // remaining limit goes back up
                if ([limitRemaining intValue] < kMaxSimultaneousRequests) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        dispatch_semaphore_signal(netSemaphore);
                    });
                } else {
                    dispatch_semaphore_signal(netSemaphore);
                }
                
                // Call the completion block after we signal the semaphore since this block may take time to finish.
                completionBlock(request);
            }];
        });
    });
}

@end
