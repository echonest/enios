//
//  ENAPIRequestQueue.h
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

#import <Foundation/Foundation.h>
#import "ENAPIRequest.h"

/**
 * This class implements a serial queue to manage multiple ENAPI requests with the API rate limits.
 * Requests are queued and executed within the constraints of the rate limits for the API Key being used. When the limit is reached, the queue will block further requests for one minute, to let the limit refresh.
 */
@interface ENAPIRequestQueue : NSObject

/**
 * Like the ENAPIRequest method, but puts the request on the queue.
 */
- (void)GETWithEndpoint:(NSString *)endpoint
          andParameters:(NSDictionary *)parameters
     andCompletionBlock:(ENAPIRequestCompletionBlock)completionBlock;

@end
