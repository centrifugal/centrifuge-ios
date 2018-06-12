//
//  CommonCryptoBridge.h
//  CentrifugeiOS

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CentrifugeCommonCryptoBridge : NSObject

+ (NSString*)hexHMACSHA256ForData:(NSString*)data withKey:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
