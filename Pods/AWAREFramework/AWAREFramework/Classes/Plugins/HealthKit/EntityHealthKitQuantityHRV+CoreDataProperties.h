//
//  EntityHealthKitQuantityHRV+CoreDataProperties.h
//  
//
//  Created by Nick Doolittle on 3/25/21.
//
//

#import "EntityHealthKitQuantityHRV+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface EntityHealthKitQuantityHRV (CoreDataProperties)

+ (NSFetchRequest<EntityHealthKitQuantityHRV *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *device;
@property (nullable, nonatomic, copy) NSString *device_id;
@property (nullable, nonatomic, copy) NSString *label;
@property (nullable, nonatomic, copy) NSString *metadata;
@property (nullable, nonatomic, copy) NSString *source;
@property (nullable, nonatomic, copy) NSNumber *timestamp;
@property (nullable, nonatomic, copy) NSNumber *timestamp_end;
@property (nonatomic) double timestamp_start;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *unit;
@property (nullable, nonatomic, copy) NSNumber *value;

@end

NS_ASSUME_NONNULL_END
