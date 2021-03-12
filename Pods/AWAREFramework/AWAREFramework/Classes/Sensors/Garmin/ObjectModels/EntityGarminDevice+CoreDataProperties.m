//
//  EntityGarminDevice+CoreDataProperties.m
//  Pods
//
//  Created by John Smith V on 3/2/21.
//


#import "EntityGarminDevice+CoreDataProperties.h"

@implementation EntityGarminDevice (CoreDataProperties)

+ (NSFetchRequest<EntityGarminDevice *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"EntityGarminDevice"];
}

@dynamic timestamp;
@dynamic device_id;
@dynamic garmin_id;
@dynamic garmin_version;
@dynamic garmin_battery;
@dynamic garmin_mac;
@dynamic garmin_last_sync;

@end
