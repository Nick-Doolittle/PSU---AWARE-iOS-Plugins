//
//  EntityHealthKitQuantityHRV+CoreDataProperties.m
//  
//
//  Created by Nick Doolittle on 3/25/21.
//
//

#import "EntityHealthKitQuantityHRV+CoreDataProperties.h"

@implementation EntityHealthKitQuantityHRV (CoreDataProperties)

+ (NSFetchRequest<EntityHealthKitQuantityHRV *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"EntityHealthKitQuantityHRV"];
}

@dynamic device;
@dynamic device_id;
@dynamic label;
@dynamic metadata;
@dynamic source;
@dynamic timestamp;
@dynamic timestamp_end;
@dynamic timestamp_start;
@dynamic type;
@dynamic unit;
@dynamic value;

@end
