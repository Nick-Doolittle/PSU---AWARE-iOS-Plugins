//
//  GarminDevice.m
//  Pods
//
//  Created by John Smith V on 2/21/21.
//


#import "GarminDevice.h"
#import "Garmin.h"
#import "EntityGarminDevice+CoreDataClass.h"

@implementation GarminDevice{
    NSString * identificationForGarminDevice;
    NSMutableData * responseData;
    GarminDeviceInfoCallback deviceInfoCallback;
}

- (instancetype)initWithAwareStudy:(AWAREStudy *)study
                            dbType:(AwareDBType)dbType{
    AWAREStorage * storage = nil;
    if (dbType == AwareDBTypeJSON) {
        storage = [[JSONStorage alloc] initWithStudy:study sensorName:@"garmin_device"];
    }else{
        storage = [[SQLiteStorage alloc] initWithStudy:study sensorName:@"garmin_device" entityName:NSStringFromClass([EntityGarminDevice class])
                                        insertCallBack:^(NSDictionary *data, NSManagedObjectContext *childContext, NSString *entity) {
                                            EntityGarminDevice* entityGarminDevice = (EntityGarminDevice *)[NSEntityDescription
                                                                                                            insertNewObjectForEntityForName:entity
                                                                                                            inManagedObjectContext:childContext];

                                            entityGarminDevice.timestamp = [data objectForKey:@"timestamp"];
                                            entityGarminDevice.device_id = [data objectForKey:@"device_id"];
                                            entityGarminDevice.garmin_id = [data objectForKey:@"garmin_id"];
                                            entityGarminDevice.garmin_version = [data objectForKey:@"garmin_version"];
                                            entityGarminDevice.garmin_battery = [data objectForKey:@"garmin_battery"];
                                            entityGarminDevice.garmin_mac = [data objectForKey:@"garmin_mac"];
                                            entityGarminDevice.garmin_last_sync = [data objectForKey:@"garmin_last_sync"];
                                        }];
    }

    self = [super initWithAwareStudy:study
                          sensorName:@"garmin_device"
                             storage:storage];
    if(self != nil){
        identificationForGarminDevice = @"";
        responseData = [[NSMutableData alloc] init];
    }
    return self;
}

//- (void)createTable{
//    TCQMaker * tcq = [[TCQMaker alloc] init];
//    [tcq addColumn:@"garmin_id" type:TCQTypeText default:@"''"];
//    [tcq addColumn:@"garmin_version" type:TCQTypeText default:@"''"];
//    [tcq addColumn:@"garmin_battery" type:TCQTypeText default:@"''"];
//    [tcq addColumn:@"garmin_mac" type:TCQTypeText default:@"''"];
//    [tcq addColumn:@"garmin_last_sync" type:TCQTypeText default:@"''"];
//    [self.storage createDBTableOnServerWithTCQMaker:tcq];
//    // [super createTable:tcq.getDefaudltTableCreateQuery];
//}
//
- (BOOL)startSensor{
    return YES;
}

- (BOOL)stopSensor{
    return YES;
}


/////////////////////////////////////////////////////////////////


//- (void) getDeviceInfoWithCallback:(GarminDeviceInfoCallback)callback{
//
//    deviceInfoCallback = callback;
//
//    NSString * userId = [Garmin getGarminUserId];
//    NSString* token = [Garmin getGarminAccessToken];
//
//
//    /////// create a Fitbit API query ///////////
//    //  /1/user/[user-id]/[resource-path]/date/[base-date]/[end-date].json
//    NSMutableString * urlStr = [[NSMutableString alloc] initWithString:@"https://api.garmin.com"];
//    [urlStr appendFormat:@"/1/user/%@/devices.json",userId];
//
//    NSURL*    url = [NSURL URLWithString:urlStr];
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
//    [request setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
//    [request setHTTPMethod:@"GET"];
//
//    if(token == nil || userId  == nil){
//        [self sendBroadcastNotification:@"[error][garmin_device] token and/or userId is null"];
//        return;
//    }
//    __weak NSURLSession *session = nil;
//    NSURLSessionConfiguration *sessionConfig = nil;
//    identificationForGarminDevice = [NSString stringWithFormat:@"garmin.query.device.%f", [[NSDate new] timeIntervalSince1970]];
//    // identificationForGarminDevice = [NSString stringWithFormat:@"garmin.query.device"];
//
//    sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identificationForGarminDevice];
//    sessionConfig.timeoutIntervalForRequest     = 60.0;
//    sessionConfig.timeoutIntervalForResource    = 60.0;
//    sessionConfig.HTTPMaximumConnectionsPerHost = 60;
//    sessionConfig.allowsCellularAccess          = YES;
//    session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:Nil];
//    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request];
//    [dataTask resume];
//}
//
//
//- (void) saveData:(NSData *) data response:(NSURLResponse *)response error:(NSError *)error{
//    NSString *responseString = [[NSString alloc] initWithData:data  encoding: NSUTF8StringEncoding];
//    if (self.isDebug) NSLog(@"Success: %@", responseString);
//
//    @try {
//        if(responseString != nil){
//            NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
//
//            NSError *error = nil;
//            NSArray *devices = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                               options:NSJSONReadingAllowFragments error:&error];
//            if (error != nil) {
//                NSString * message = [NSString stringWithFormat:@"[error][garmin_device] failed to parse JSON: %@",error.debugDescription];
//                if (self.isDebug) NSLog(@"%@",message);
//                [self sendBroadcastNotification:message];
//                if (responseString!=nil) {
//                    [self sendBroadcastNotification:responseString];
//                }
//                return;
//            }else{
//                [self sendBroadcastNotification:@"Garmin plugin got device data"];
//            }
//
//            if( devices != nil){
//                for (NSDictionary * device in devices) {
//                    NSString * garminId = @"";
//                    NSString * garminVersion = @"";
//                    NSString * garminBattery = @"";
//                    NSString * garminMac = @"";
//                    NSString * garminLastSync = @"";
//                    if([device objectForKey:@"id"] != nil) garminId = [device objectForKey:@"id"];
//                    if([device objectForKey:@"deviceVersion"] != nil) garminVersion = [device objectForKey:@"deviceVersion"];
//                    if([device objectForKey:@"battery"] != nil ) garminBattery = [device objectForKey:@"battery"] ;
//                    if([device objectForKey:@"mac"] != nil) garminMac = [device objectForKey:@"mac"];
//                    if([device objectForKey:@"lastSyncTime"] != nil) garminLastSync = [device objectForKey:@"lastSyncTime"];
//
//                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
//                    [dict setObject:[AWAREUtils getUnixTimestamp:[NSDate new]] forKey:@"timestamp"]; //timestamp
//                    [dict setObject:[self getDeviceId] forKey:@"device_id"];  //    device_id
//                    [dict setObject:garminId forKey:@"garmin_id"];
//                    [dict setObject:garminVersion forKey:@"garmin_version"];
//                    [dict setObject:garminBattery forKey:@"garmin_battery"];
//                    [dict setObject:garminMac forKey:@"garmin_mac"];
//                    [dict setObject:garminLastSync forKey:@"garmin_last_sync"];
//
//                    if(deviceInfoCallback){
//                        deviceInfoCallback(garminId, garminVersion, garminBattery, garminMac, garminLastSync);
//                    }
//
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.storage saveDataWithDictionary:dict buffer:NO saveInMainThread:YES];
//                    });
//                }
//            }
//        }
//    } @catch (NSException *exception) {
//        // [Fitbit refreshToken];
//    } @finally {
//
//    }
//}
//
//- (void)insertNewEntityWithData:(NSDictionary *)data
//           managedObjectContext:(NSManagedObjectContext *)childContext
//                     entityName:(NSString *)entity{
//    EntityGarminDevice* entityGarminDevice = (EntityGarminDevice *)[NSEntityDescription
//                                                               insertNewObjectForEntityForName:entity
//                                                               inManagedObjectContext:childContext];
//
//    entityGarminDevice.timestamp = [data objectForKey:@"timestamp"];
//    entityGarminDevice.device_id = [data objectForKey:@"device_id"];
//    entityGarminDevice.garmin_id = [data objectForKey:@"garmin_id"];
//    entityGarminDevice.garmin_version = [data objectForKey:@"garmin_version"];
//    entityGarminDevice.garmin_battery = [data objectForKey:@"garmin_battery"];
//    entityGarminDevice.garmin_mac = [data objectForKey:@"garmin_mac"];
//    entityGarminDevice.garmin_last_sync = [data objectForKey:@"garmin_last_sync"];
//}
//
///////////////////////////////////////////////////////////////////////
//
//
//- (void)URLSession:(NSURLSession *)session
//          dataTask:(NSURLSessionDataTask *)dataTask
//didReceiveResponse:(NSURLResponse *)response
// completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
//
//    completionHandler(NSURLSessionResponseAllow);
//
//    NSString * identifier = session.configuration.identifier;
//    if([identifier isEqualToString:identificationForGarminDevice]){
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//        int responseCode = (int)[httpResponse statusCode];
//        if (responseCode == 200) {
//            [session finishTasksAndInvalidate];
//            if (self.isDebug) NSLog(@"[%d] Success",responseCode);
//        }else{
//            // clear
//            [session invalidateAndCancel];
//            if (self.isDebug) NSLog(@"[%d] %@", responseCode, response.debugDescription);
//            responseData = [[NSMutableData alloc] init];
//        }
//
//    }
//    // [super URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
//}
//
//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
//    NSString * identifier = session.configuration.identifier;
//    if([identifier isEqualToString:identificationForGarminDevice]){
//        [responseData appendData:data];
//    }
//    // [super URLSession:session dataTask:dataTask didReceiveData:data];
//}
//
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
//    NSString * identifier = session.configuration.identifier;
//    if ([identifier isEqualToString:identificationForGarminDevice]) {
//        NSData * data = [responseData copy];
//        [self saveData:data response:nil error:error];
//        responseData = [[NSMutableData alloc] init];
//    }
//    // [super URLSession:session task:task didCompleteWithError:error];
//}
//
////////////////////////////////////////////////////////////////////////
//
//- (void) sendBroadcastNotification:(NSString *) message {
//    if ([NSThread isMainThread]){
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"aware.plugin.garmin.debug.event" object:self userInfo:@{@"message":message}];
//    }else{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self sendBroadcastNotification:message];
//        });
//    }
//}
//
@end
