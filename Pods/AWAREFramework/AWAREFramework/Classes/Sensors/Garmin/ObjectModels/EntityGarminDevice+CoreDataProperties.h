//
//  EntityGarminDevice+CoreDataProperties.h
//  Pods
//
//  Created by John Smith V on 3/2/21.
//
//issues with this one only. Need to check garmin files themselves


#import "EntityGarminDevice+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityGarminDevice (CoreDataProperties)

+ (NSFetchRequest<EntityGarminDevice *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *timestamp;
@property (nullable, nonatomic, copy) NSString *device_id;
@property (nullable, nonatomic, copy) NSString *garmin_id;
@property (nullable, nonatomic, copy) NSString *garmin_version;
@property (nullable, nonatomic, copy) NSString *garmin_battery;
@property (nullable, nonatomic, copy) NSString *garmin_mac;
@property (nullable, nonatomic, copy) NSString *garmin_last_sync;

@end

NS_ASSUME_NONNULL_END

