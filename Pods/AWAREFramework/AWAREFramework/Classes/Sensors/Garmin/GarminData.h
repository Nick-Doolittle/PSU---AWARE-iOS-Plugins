//
//  GarminData.h
//  Pods
//
//  Created by John Smith V on 2/21/21.
//

#import "AWARESensor.h"

@interface GarminData : AWARESensor <AWARESensorDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

NS_ASSUME_NONNULL_BEGIN

typedef void (^GarminCaloriesRequestCallback) (NSData * _Nullable result,  NSString * __nullable nextSyncDate);
typedef void (^GarminStepsRequestCallback)    (NSData * _Nullable result,  NSString * __nullable nextSyncDate);
typedef void (^GarminHeartrateRequestCallback)(NSData * _Nullable result,  NSString * __nullable nextSyncDate);
typedef void (^GarminSleepRequestCallback)    (NSData * _Nullable result,  NSString * __nullable nextSyncDate);
//typedef void (^GarminStressRequestCallback)   (NSData * _Nullable result,  NSString * __nullable nextSyncDate);


- (void) getCaloriesWithStart:(NSString * _Nonnull)start
                          end:(NSString * _Nonnull)end
                       period:(NSString * _Nullable)period
                  detailLevel:(NSString * _Nonnull)detailLevel
                     callback:(GarminCaloriesRequestCallback _Nullable) callback;

- (void) getStepsWithStart:(NSString * _Nonnull)start
                       end:(NSString * _Nonnull)end
                    period:(NSString * _Nullable)period
               detailLevel:(NSString * _Nonnull)detailLevel
                  callback:(GarminStepsRequestCallback _Nullable)callback;

- (void) getHeartrateWithStart:(NSString * _Nonnull)start
                           end:(NSString * _Nonnull)end
                        period:(NSString * _Nullable)period
                   detailLevel:(NSString * _Nonnull)detailLevel
                      callback:(GarminHeartrateRequestCallback _Nullable)callback;

- (void) getSleepWithStart:(NSString * _Nonnull)start
                       end:(NSString * _Nonnull)end
                    period:(NSString * _Nullable)period
               detailLevel:(NSString * _Nonnull)detailLevel
                  callback:(GarminSleepRequestCallback _Nullable)callback;

//- (void) getStressWithStart:(NSString * _Nonnull)start
//                        end:(NSString * _Nonnull)end
//                     period:(NSString * _Nullable)period
//                detailLevel:(NSString * _Nonnull)detailLevel
//                   callback:(GarminStressRequestCallback _Nullable)callback;

+ (NSString * _Nullable) getLastSyncDateSteps;
+ (NSString * _Nullable) getLastSyncDateCalories;
+ (NSString * _Nullable) getLastSyncDateHeartrate;
+ (NSString * _Nullable) getLastSyncDateSleep;
//+ (NSString * _Nullable) getLastSyncDateStress;

+ (void) setLastSyncDateSteps:(NSString * _Nonnull)date;
+ (void) setLastSyncDateCalories:(NSString * _Nonnull)date;
+ (void) setLastSyncDateHeartrate:(NSString * _Nonnull)date;
+ (void) setLastSyncDateSleep:(NSString * _Nonnull)date;
//+ (void) setLastSyncDateStress:(NSString * _Nonnull)date;

+ (void) setLastSyncDate:(NSString * _Nonnull)date withKey:(NSString * _Nonnull)key;

NS_ASSUME_NONNULL_END

@end
