//
//  EntityGarminData+CoreDataProperties.h
//  Pods
//
//  Created by John Smith V on 3/2/21.
//

#import "EntityGarminData+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityGarminData (CoreDataProperties)

+ (NSFetchRequest<EntityGarminData *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *timestamp;
@property (nullable, nonatomic, copy) NSString *device_id;
@property (nullable, nonatomic, copy) NSString *garmin_id;
@property (nullable, nonatomic, copy) NSString *garmin_data_type;
@property (nullable, nonatomic, copy) NSString *garmin_data;

@end

NS_ASSUME_NONNULL_END
