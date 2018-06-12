//
//  CommonCryptoBridge.m
//  CentrifugeiOS

#import "CommonCryptoBridge.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation CentrifugeCommonCryptoBridge

+ (NSString*)hexHMACSHA256ForData:(NSString*)data withKey:(NSString*)key {
    const char *dataCharPtr = [data cStringUsingEncoding:NSASCIIStringEncoding];
    const char *keyCharPtr = [key cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char hmac[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, keyCharPtr, strlen(keyCharPtr), dataCharPtr, strlen(dataCharPtr), hmac);
    NSData *result = [[NSData alloc] initWithBytes:hmac length:sizeof(hmac)];

    NSUInteger resultLength = [result length];
    const unsigned char *resultBytes = (const unsigned char *)result.bytes;
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(resultLength * 2)];

    for (int i = 0; i < resultLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)resultBytes[i]]];

    return [NSString stringWithString:hexString];
}

@end
