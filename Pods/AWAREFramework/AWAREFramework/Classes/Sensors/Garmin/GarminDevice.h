//
//  GarminDevice.h
//  Pods
//
//  Created by John Smith V on 2/21/21.
//

#import "AWARESensor.h"

@interface GarminDevice : AWARESensor <NSURLSessionDelegate>

typedef void (^GarminDeviceInfoCallback)( NSString * garminId, NSString * garminVersion, NSString * garminBattery, NSString * garminMac, NSString * garminLastSync);

- (void) getDeviceInfoWithCallback:(GarminDeviceInfoCallback)callback;

@end

