//
//  ENAPI.m
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
#import "Base64Transcoder.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

NSString * const ENLicenseEchoSource = @"echo-source";
NSString * const ENLicenseAllRightsReserved = @"all-rights-reserved";
NSString * const ENLicenseCreativeCommonsBy_SA = @"cc-by-sa";
NSString * const ENLicenseCreativeCommonsBy_NC = @"cc-by-nc";
NSString * const ENLicenseCreativeCommonsBy_NC_ND = @"cc-by-nc-nd";
NSString * const ENLicenseCreativeCommonsBy_NC_SA = @"cc-by-nc-sa";
NSString * const ENLicenseCreativeCommonsBy_ND = @"cc-by-nd";
NSString * const ENLicenseCreativeCommonsBy = @"cc-by";
NSString * const ENLicensePublicDomain = @"public-domain";
NSString * const ENLicenseUnknown = @"unknown";

NSString * const ENSortFamiliarityAscending = @"familiarity-asc";
NSString * const ENSortFamiliarityDescending = @"familiarity-desc";
NSString * const ENSortHotttnesssAscending = @"hotttnesss-asc";
NSString * const ENSortHotttnesssDescending = @"hotttnesss-desc";
NSString * const ENSortWeight = @"weight";
NSString * const ENSortFrequency = @"frequency";

NSString *ENGetStringRepresentationForObject(NSObject *obj) {
    if ([obj isKindOfClass:[NSNumber class]]) {
        // NSNumber returns `1` and `0` for BOOL string representation
        // instead of `true` and `false`
        NSNumber *number = (NSNumber *)obj;
        if (0 == strcmp([number objCType], @encode(BOOL))) {
            return ([number boolValue])?@"true":@"false";
        }
    }
    return [NSString stringWithFormat:@"%@", obj];
}

NSString *ENEscapeStringForURL (NSString *str) {
    //
    // rfc 3986
    // @see http://code.google.com/p/google-toolbox-for-mac/source/browse/trunk/Foundation/GTMNSString%2BURLArguments.m
    //
    NSString *returnString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                   (__bridge CFStringRef)str,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                   kCFStringEncodingUTF8));
    return returnString;
}

@implementation ENAPI

+ (NSString *)encodeObjectAsJSON:(NSObject *)object {
    NSString *result = nil;
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if (error != nil) {
        NSLog(@"ENAPI error encoding JSON object %@", error);;
    } else if (json == nil || json.length == 0) {
        NSLog(@"ENAPI error encoding JSON data, data is nil");
    } else {
        result = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    }
    
    return result;
}

+ (NSString *)encodeDataAsJSON:(NSData *)data {
    return [ENAPI encodeObjectAsJSON:data];
}

+ (NSString *)encodeArrayAsJSON:(NSArray *)array {
    return [ENAPI encodeObjectAsJSON:array];
}

+ (NSDictionary *)parseJSONDataToDictionary:(NSData *)data {
    NSDictionary *result = nil;
    NSError *error = nil;
    NSObject *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error != nil) {
        NSLog(@"ENAPI error parsing JSON data %@", error);;
    } else if (![jsonObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"ENAPI parsed JSON data is not a NSDictionary");
    } else {
        result = (NSDictionary *)jsonObject;
    }
    return result;
}

+ (NSString *)encodeDictionaryAsQueryString:(NSDictionary *)dictionary {
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:[dictionary count]];
    for (NSString *key in [dictionary allKeys]) {
        NSObject *value = [dictionary objectForKey:key];
        if ([value isKindOfClass:[NSArray class]]) {
            // we use arrays for multiple values of the same key, e.g., licenses
            for (NSString *multValue in ((NSArray *)value)) {
                [params addObject:[NSString stringWithFormat:@"%@=%@", ENEscapeStringForURL(key), ENEscapeStringForURL(ENGetStringRepresentationForObject(multValue))]];
            }
            
        } else {
            [params addObject:[NSString stringWithFormat:@"%@=%@", ENEscapeStringForURL(key),
                               ENEscapeStringForURL(ENGetStringRepresentationForObject(value))]];
        }
    }
    [params sortUsingSelector:@selector(caseInsensitiveCompare:)];
    return [params componentsJoinedByString:@"&"];
}

+ (NSString *)calculateMD5DigestFromData:(NSData *)data {
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(data.bytes, data.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+ (NSString *)signString:(NSString *)string andEncodeWithSecret:(NSString *)secret {
    const char *cKey  = [secret cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cText = [string cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHmacResult[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cText, strlen(cText), cHmacResult);
    
    char base64Result[32];
    size_t base64ResultLen = 32;
    Base64EncodeData(cHmacResult, CC_SHA1_DIGEST_LENGTH, base64Result, &base64ResultLen);
    
    NSData *encodedData = [NSData dataWithBytes:base64Result length:base64ResultLen];
    
    return [[NSString alloc] initWithData:encodedData encoding:NSASCIIStringEncoding];
}


@end

