//
//  EntityGarminData+CoreDataProperties.m
//  Pods
//
//  Created by John Smith V on 3/2/21.
//

#import "EntityGarminData+CoreDataProperties.h"

@implementation EntityGarminData (CoreDataProperties)

+ (NSFetchRequest<EntityGarminData *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"EntityGarminData"];
}

@dynamic timestamp;
@dynamic device_id;
@dynamic garmin_id;
@dynamic garmin_data_type;
@dynamic garmin_data;

@end
