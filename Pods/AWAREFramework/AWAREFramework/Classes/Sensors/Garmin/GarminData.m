//
//  GarminData.m
//  Pods
//
//  Created by John Smith V on 2/21/21.
//

#import "GarminData.h"
#import "Garmin.h"
#import "EntityGarminData+CoreDataClass.h"

@implementation GarminData{
    NSString * identificationForGarminData;
    NSDateFormatter *dateFormat;
    NSDateFormatter *timeFormat;
    NSMutableData * sleepResponse;
    NSMutableData * stepsResponse;
    NSMutableData * caloriesResponse;
    NSMutableData * heartResponse;

    NSString * sleepStartDate;
    NSString * stepsStartDate;
    NSString * caloriesStartDate;
    NSString * heartrateStartDate;

    NSString * sleepEndDate;
    NSString * stepsEndDate;
    NSString * caloriesEndDate;
    NSString * heartrateEndDate;

    GarminCaloriesRequestCallback calCallback;
    GarminStepsRequestCallback stepCallback;
    GarminHeartrateRequestCallback heartrateCallback;
    GarminSleepRequestCallback sleepCallback;
}

- (instancetype)initWithAwareStudy:(AWAREStudy *)study dbType:(AwareDBType)dbType{
    AWAREStorage * storage = nil;
    if (dbType == AwareDBTypeJSON) {
        storage = [[JSONStorage alloc] initWithStudy:study sensorName:@"garmin_data"];
    }else{
        storage = [[SQLiteStorage alloc] initWithStudy:study sensorName:@"garmin_data" entityName:NSStringFromClass([EntityGarminData class])
                                        insertCallBack:^(NSDictionary *data, NSManagedObjectContext *childContext, NSString *entity) {
                                            EntityGarminData * entityGarminData = (EntityGarminData *)[NSEntityDescription
                                                                                                       insertNewObjectForEntityForName:entity
                                                                                                       inManagedObjectContext:childContext];
                                            entityGarminData.device_id = [self getDeviceId];
                                            entityGarminData.timestamp = [data objectForKey:@"timestamp"];
                                            entityGarminData.device_id = [data objectForKey:@"device_id"];
                                            entityGarminData.garmin_data = [data objectForKey:@"garmin_data"];
                                            entityGarminData.garmin_data_type = [data objectForKey:@"garmin_data_type"];
                                            entityGarminData.garmin_id = [data objectForKey:@"garmin_id"];
                                        }];//probably an error here. Not sure what exactly is leading to non-connected variables above.
    }
    self = [super initWithAwareStudy:study
                          sensorName:@"garmin_data"
                             storage:storage];
    if(self != nil){
        identificationForGarminData = @"";

        dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];

        timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat:@"HH:mm"];

        sleepResponse = [[NSMutableData alloc] init];
        stepsResponse = [[NSMutableData alloc] init];
        caloriesResponse = [[NSMutableData alloc] init];
        heartResponse = [[NSMutableData alloc] init];
    }
    return self;
}


//- (void)createTable{
//
//    TCQMaker * tcq = [[TCQMaker alloc] init];
//    [tcq addColumn:@"garmin_id" type:TCQTypeText default:@"''"];
//    [tcq addColumn:@"garmin_data_type" type:TCQTypeText default:@"''"];
//    [tcq addColumn:@"garmin_data" type:TCQTypeText default:@"''"];
//    [self.storage createDBTableOnServerWithTCQMaker:tcq];
//}



- (BOOL)startSensor{
    return YES;
}

- (BOOL)stopSensor{
    return YES;
}


//////////////////////////////////////////////////////

//+ (NSString *) getLastSyncDateSteps{
//    return [GarminData getLastSyncDateWithKey:@"steps"];
//}
//
//+ (NSString *) getLastSyncDateCalories{
//    return [GarminData getLastSyncDateWithKey:@"calories"];
//}
//
//+ (NSString *) getLastSyncDateHeartrate{
//    return [GarminData getLastSyncDateWithKey:@"heartrate"];
//}
//
//+ (NSString *) getLastSyncDateSleep{
//    return [GarminData getLastSyncDateWithKey:@"sleep"];
//}
//
//////////////////////////////////////////////////////
//+ (void) setLastSyncDateSteps:(NSString *)date{
//    [GarminData setLastSyncDate:date withKey:@"steps"];
//}
//
//+ (void) setLastSyncDateCalories:(NSString *)date{
//    [GarminData setLastSyncDate:date withKey:@"calories"];
//}
//
//+ (void) setLastSyncDateHeartrate:(NSString *)date{
//    [GarminData setLastSyncDate:date withKey:@"heartrate"];
//}
//
//+ (void) setLastSyncDateSleep:(NSString *)date{
//    [GarminData setLastSyncDate:date withKey:@"sleep"];
//}
//
////////////////////////////////////////////////////
//
//- (void) getCaloriesWithStart:(NSString *)start
//                           end:(NSString *)end
//                        period:(NSString *)period
//                   detailLevel:(NSString *)detailLevel
//                     callback:(GarminCaloriesRequestCallback)callback{
//    caloriesStartDate = start;
//    caloriesEndDate = end;
//    calCallback = callback;
//    // start = [self getLastQueryDateWithKey:@"calories"];
//    [self getActivityWithDataType:@"calories"
//                     ResourcePath:@"activities/calories"
//                            start:start
//                              end:end
//                           period:nil
//                      detailLevel:detailLevel];
//}
//
//- (void) getStepsWithStart:(NSString *)start
//                       end:(NSString *)end
//                    period:(NSString *)period
//               detailLevel:(NSString *)detailLevel
//                  callback:(GarminStepsRequestCallback)callback{
//
//    stepsStartDate = start;
//    stepsEndDate = end;
//    stepCallback = callback;
//
//    // activities-steps, activities-calories, activities-heartrate,sleep-efficie
//    // start = [self getLastQueryDateWithKey:@"steps"];
//    [self getActivityWithDataType:@"steps"
//                     ResourcePath:@"activities/steps"
//                            start:start
//                              end:end
//                           period:nil
//                      detailLevel:detailLevel];
//}
//
//- (void) getHeartrateWithStart:(NSString *)start
//                           end:(NSString *)end
//                        period:(NSString *)period
//                   detailLevel:(NSString *)detailLevel
//                      callback:(GarminHeartrateRequestCallback)callback{
//    ///////////////////////////////////////////////
//    heartrateStartDate = start;
//    heartrateEndDate = end;
//    heartrateCallback = callback;
//
//    // start = [self getLastQueryDateWithKey:@"heartrate"];
//    [self getActivityWithDataType:@"heartrate"
//                     ResourcePath:@"activities/heart"
//                            start:start
//                              end:end
//                           period:nil //@"15min"
//                      detailLevel:detailLevel];
//}
//
//- (void) getSleepWithStart:(NSString *)start
//                       end:(NSString *)end
//                    period:(NSString *)period
//               detailLevel:(NSString *)detailLevel
//                  callback:(GarminSleepRequestCallback)callback{
//    sleepStartDate = start;
//    sleepEndDate = end;
//    sleepCallback = callback;
////    start = [self getLastQueryDateWithKey:@"sleep"];
//    [self getActivityWithDataType:@"sleep"
//                     ResourcePath:@"sleep/efficiency"
//                            start:start
//                              end:end
//                           period:nil
//                      detailLevel:nil];
//}
//
//
///**
// * Get Activities Data from Fitbit Developer API
// *
// * @discussion Example URL is "https://api.fitbit.com/1/user/[user-id]/activities/date/[date].json". Please read a document of Fitbit ("https://dev.fitbit.com/docs/activity/".)
// *
// GET /1/user/[user-id]/[resource-path]/date/[date]/[period].json
// GET /1/user/[user-id]/[resource-path]/date/[base-date]/[end-date].json
// GET /1/user/[user-id]/[resource-path]/date/[date]/[date]/[detail-level]/time/[start-time]/[end-time].json
//
// */
//
//- (BOOL) getActivityWithDataType:(NSString *)type
//                    ResourcePath:(NSString *)resourcePath
//                           start:(NSString *)start
//                             end:(NSString *)end
//                          period:(NSString *)period
//                     detailLevel:(NSString *)detailLevel{
//    NSString * userId = [Garmin getGarminUserId];
//    NSString* token = [Garmin getGarminAccessToken];
//
//    if (userId == nil || token == nil) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString * msg = [NSString stringWithFormat:@"[Error: %@] User ID and Access Token do not exist. Please **login** again to get these.", [self getSensorName]];
//            NSLog(@"%@",msg);
//        });
//        return NO;
//    }
//
//    /////// create a Fitbit API query ///////////
//    // "https://api.fitbit.com/" + FITBIT_API_LEVEL + "/user/-/activities/steps/date/" + localSyncDate + "/" + serverSyncDate + "/" + Aware.getSetting(getApplicationContext(), Settings.FITBIT_GRANULARITY) + ".json");
//    NSMutableString * urlStr = [[NSMutableString alloc] initWithString:@"https://api.garmin.com"];
//    if ([type isEqualToString:@"heartrate"]){
//        [urlStr appendFormat:@"/1/user/-/%@/date/%@/%@/%@.json", resourcePath, start, start, detailLevel];
//        [self sendBroadcastNotification:urlStr];
//    }else if([type isEqualToString:@"sleep"]){
//        // GET https://api.fitbit.com/1.2/user/[user-id]/sleep/date/[startDate]/[endDate].json
//        [urlStr appendFormat:@"/1.2/user/-/sleep/date/%@/%@.json", start, start];
//        [self sendBroadcastNotification:urlStr];
//    }else if( start!=nil && end!=nil && detailLevel!=nil){
//        // https://dev.fitbit.com/build/reference/web-api/activity/
//        // [urlStr appendFormat:@"/1/user/-/%@/date/%@/%@/%@.json", resourcePath, start, end, detailLevel];
//        [urlStr appendFormat:@"/1/user/-/%@/date/%@/%@.json", resourcePath, start, detailLevel];
//        [self sendBroadcastNotification:urlStr];
//        NSLog(@"%@",urlStr);
//    } else {
//        NSString * message = [NSString stringWithFormat:@"[error][%@]URL format Error: %@", type, urlStr];
//        NSLog(@"%@", message);
//        [self sendBroadcastNotification:message];
//        return NO;
//    }
//
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
//    if(token == nil) return NO;
//    if(userId == nil) return NO;
//
//    [request setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
//    [request setHTTPMethod:@"GET"];
//
//    __weak NSURLSession *session = nil;
//    // NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSessionConfiguration *sessionConfig = nil;
//    identificationForGarminData = type;
//
//    sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identificationForGarminData];
//    sessionConfig.timeoutIntervalForRequest = 60.0;
//    sessionConfig.timeoutIntervalForResource = 60.0;
//    sessionConfig.HTTPMaximumConnectionsPerHost = 60;
//    sessionConfig.allowsCellularAccess = YES;
//    session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:Nil];
//    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request];
//    [dataTask resume];
//    return YES;
//}
//
//
//- (void) saveData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error type:(NSString *)type{
//
//    @try {
//        if(error != nil){
//            // NSString *errorStr = [[NSString alloc] initWithData:data  encoding: NSUTF8StringEncoding];
//            NSLog(@"%@",error.debugDescription);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSString * msg =[NSString stringWithFormat:@"[error][%@]-saveData:response:error:type %@", type, error.debugDescription];
//                NSLog(@"%@",msg);
//            });
//            return;
//        }
//
//        if(data != nil){
//            // NSData *jsonData = data; // [responseString dataUsingEncoding:NSUTF8StringEncoding];
//            NSError *e = nil;
//            NSDictionary *activities = [NSJSONSerialization JSONObjectWithData:data
//                                                                       options:NSJSONReadingAllowFragments
//                                                                         error:&e];
//            if (e != nil) {
//                NSLog(@"failed to parse JSON: %@", error.debugDescription);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSString * message = [NSString stringWithFormat:@"[error][%@] failed to parse JSON: %@", type, e.debugDescription];
//                    [self sendBroadcastNotification:message];
//                });
//                return;
//            }
//
//            if([activities objectForKey:@"errors"]!=nil){
//                NSLog(@"%@",activities.debugDescription);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSString * message = [NSString stringWithFormat:@"[error][%@] failed to parse JSON: %@", type, e.debugDescription];
//                    [self sendBroadcastNotification:message];
//                });
//                return;
//            }
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSString * msg = [NSString stringWithFormat:@"Garmin plugin got %@ data (%ld bytes)", type, data.length];
//                [self sendBroadcastNotification:msg];
//            });
//
//            NSString *responseString = [[NSString alloc] initWithData:data  encoding: NSUTF8StringEncoding];
//            NSLog(@"Success: %@", responseString);
//
//            NSDate * now = [NSDate new];
//
//            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
//            [dict setObject:[AWAREUtils getUnixTimestamp:now] forKey:@"timestamp"]; //timestamp
//            [dict setObject:[self getDeviceId] forKey:@"device_id"];  //    device_id
//            [dict setObject:responseString forKey:@"garmin_data"];    //    fitbit_data
//            [dict setObject:type forKey:@"garmin_data_type"];  //    fitbit_data_type
//            [dict setObject:[Garmin getGarminUserId] forKey:@"garmin_id"];          //    fitbit_id
//
//            if([type isEqualToString:@"steps"]){
//                [GarminData setLastSyncDate:[NSString stringWithFormat:@"%@T00:00:00",stepsEndDate] withKey:type];
//                if (stepCallback) {
//                    if ([self getDaysBetweenLocalSyncDate:stepsStartDate andRemoteSyncDate:stepsEndDate] > 0) {
//                        NSString * nextDate = [self getNextDateFromDate:stepsStartDate];
//                        [GarminData setLastSyncDateSteps:nextDate];
//                        stepCallback(data, nextDate);
//                    }else{
//                        [GarminData setLastSyncDateSteps:[NSString stringWithFormat:@"%@T00:00:00",stepsEndDate]];
//                        stepCallback(data, nil);
//                    }
//                }
//            }else if([type isEqualToString:@"calories"]){
//                [GarminData setLastSyncDate:[NSString stringWithFormat:@"%@T00:00:00",caloriesEndDate]  withKey:type];
//                if (calCallback) {
//                    if ([self getDaysBetweenLocalSyncDate:caloriesStartDate andRemoteSyncDate:caloriesEndDate] > 0) {
//                        NSString * nextDate = [self getNextDateFromDate:caloriesStartDate];
//                        [GarminData setLastSyncDateCalories:nextDate];
//                        calCallback(data, nextDate);
//                    }else{
//                        [GarminData setLastSyncDateCalories:[NSString stringWithFormat:@"%@T00:00:00", caloriesEndDate]];
//                        calCallback(data, nil);
//                    }
//                }
//            }else if([type isEqualToString:@"heartrate"]){
//                if (heartrateCallback){
//                    if ([self getDaysBetweenLocalSyncDate:heartrateStartDate andRemoteSyncDate:heartrateEndDate] > 0) {
//                        NSString * nextDate = [self getNextDateFromDate:heartrateStartDate];
//                        [GarminData setLastSyncDateHeartrate:nextDate];
//                        heartrateCallback(data, nextDate);
//                    }else{
//                        [GarminData setLastSyncDateHeartrate:[NSString stringWithFormat:@"%@T00:00:00",heartrateEndDate]];
//                        heartrateCallback(data, nil);
//                    }
//                }
//            }else if([type isEqualToString:@"sleep"]){
//                if (sleepCallback) {
//                    if([self getDaysBetweenLocalSyncDate:sleepStartDate andRemoteSyncDate:sleepEndDate] > 0){
//                        NSString * nextDate = [self getNextDateFromDate:sleepStartDate];
//                        [GarminData setLastSyncDateSleep:nextDate];
//                        sleepCallback(data, nextDate);
//                    }else{
//                        [GarminData setLastSyncDateSleep:[NSString stringWithFormat:@"%@T00:00:00",sleepEndDate]];
//                        sleepCallback(data, nil);
//                    }
//                }
//            }
//
//            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:dict
//                                                                 forKey:EXTRA_DATA];
//            [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"action.aware.plugin.garmin.get.activity.%@",type]
//                                                                object:nil
//                                                              userInfo:userInfo];
//            NSLog(@"%@",[NSString stringWithFormat:@"action.aware.plugin.garmin.get.activity.%@",type]);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.storage saveDataWithDictionary:dict buffer:NO saveInMainThread:YES];
//            });
//        }else{
//            [self sendBroadcastNotification:[NSString stringWithFormat:@"[%@] received data is null ", type]];
//            //            NSDictionary * debugMsg = @{@"debug":@"no response", @"type":type};
//            //            if([responseString isEqualToString:@""]){
//            //                debugMsg = @{@"debug":@"no response", @"type":type};
//            //            }else if(responseString != nil){
//            //                debugMsg = @{@"debug":responseString, @"type":type};
//            //            }
//            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"action.aware.plugin.fitbit.get.activity.debug"
//            //                                                                object:nil
//            //                                                              userInfo:debugMsg];
//        }
//    } @catch (NSException *exception) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString * msg = [NSString stringWithFormat:@"[exception][%@] -saveData:response:error:type %@", type, exception.debugDescription];
//            [self sendBroadcastNotification:msg];
//        });
//    } @finally {
//    }
//}
//
//
//- (void)insertNewEntityWithData:(NSDictionary *)data managedObjectContext:(NSManagedObjectContext *)childContext entityName:(NSString *)entity{
//    EntityGarminData * entityGarminData = (EntityGarminData *)[NSEntityDescription
//                                                               insertNewObjectForEntityForName:entity
//                                                               inManagedObjectContext:childContext];
//    entityGarminData.device_id = [self getDeviceId];
//    entityGarminData.timestamp = [data objectForKey:@"timestamp"];
//    entityGarminData.device_id = [data objectForKey:@"device_id"];
//    entityGarminData.garmin_data = [data objectForKey:@"garmin_data"];
//    entityGarminData.garmin_data_type = [data objectForKey:@"garmin_data_type"];
//    entityGarminData.garmin_id = [data objectForKey:@"garmin_id"];
//}
//
//
//
//- (void)URLSession:(NSURLSession *)session
//          dataTask:(NSURLSessionDataTask *)dataTask
//didReceiveResponse:(NSURLResponse *)response
// completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
//
//    NSString * identifier = session.configuration.identifier;
//    // NSLog(@"[%@] session:dataTask:didReceiveResponse:completionHandler:",identifier);
//
//    completionHandler(NSURLSessionResponseAllow);
//
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//    int responseCode = (int)[httpResponse statusCode];
//    if (responseCode == 200) {
//        NSLog(@"[%d] Success",responseCode);
//        [session finishTasksAndInvalidate];
//    }else{
//        [session invalidateAndCancel];
//        // clear
//        NSLog(@"[%d] %@", responseCode, response.debugDescription);
//        if([identifier isEqualToString:@"steps"]){
//            stepsResponse = [[NSMutableData alloc] init];
//        }else if([identifier isEqualToString:@"calories"]){
//            caloriesResponse = [[NSMutableData alloc] init];
//        }else if([identifier isEqualToString:@"heartrate"]){
//            heartResponse = [[NSMutableData alloc] init];
//        }else if([identifier isEqualToString:@"sleep"]){
//            sleepResponse = [[NSMutableData alloc] init];
//        }
//    }
//    // [super URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
//}
//
//
//
//
//-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
//    // @"steps"@"calories"
//    // @"heartrate"@"sleep"
//    NSString * identifier = session.configuration.identifier;
//    if([identifier isEqualToString:@"steps"]){
//        [stepsResponse appendData:data];
//    }else if([identifier isEqualToString:@"calories"]){
//        [caloriesResponse appendData:data];
//    }else if([identifier isEqualToString:@"heartrate"]){
//        [heartResponse appendData:data];
//    }else if([identifier isEqualToString:@"sleep"]){
//        [sleepResponse appendData:data];
//    }
//    // [super URLSession:session dataTask:dataTask didReceiveData:data];
//}
//
//
//-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
//
//    NSString * identifier = session.configuration.identifier;
//
//    if (error != nil) {
//        [self sendBroadcastNotification:[NSString stringWithFormat:@"[%@] Error:%@ ",identifier,error.debugDescription]];
//    }
//
//    // NSLog(@"[%@]URLSession:task:didCompleteWithError",identifier);
//    NSData * data = nil;
//    if([identifier isEqualToString:@"steps"]){
//        data = stepsResponse;
//    }else if([identifier isEqualToString:@"calories"]){
//        data = caloriesResponse;
//    }else if([identifier isEqualToString:@"heartrate"]){
//        data = heartResponse;
//    }else if([identifier isEqualToString:@"sleep"]){
//        data = sleepResponse;
//    }
//    ////////////////////////////////////////////////////
//
//    if(data != nil){
//        ////// save data ///////
//        [self saveData:data response:nil error:error type:identifier];
//    }else{
//        NSLog(@"data is nil @ GarminData plugin");
//        [self sendBroadcastNotification:[NSString stringWithFormat:@"[%@] data is nil",identifier]];
//    }
//
//    // clear
//    if([identifier isEqualToString:@"steps"]){
//        stepsResponse = [[NSMutableData alloc] init];
//    }else if([identifier isEqualToString:@"calories"]){
//        caloriesResponse = [[NSMutableData alloc] init];
//    }else if([identifier isEqualToString:@"heartrate"]){
//        heartResponse = [[NSMutableData alloc] init];
//    }else if([identifier isEqualToString:@"sleep"]){
//        sleepResponse = [[NSMutableData alloc] init];
//    }
//
//    // [super URLSession:session task:task didCompleteWithError:error];
//
//}
//
//
////////////////////////////////////////////////////////////////
//
//
//+ (void) setLastSyncDate:(NSString *)date withKey:(NSString *)key{
//    NSUserDefaults * userDefualts = [NSUserDefaults standardUserDefaults];
//    [userDefualts setObject:date forKey:[NSString stringWithFormat:@"garmin.last.local.sync.date.%@",key]];
//}
//
//+ (NSString *) getLastSyncDateWithKey:(NSString *)key{
//    NSUserDefaults * userDefualts = [NSUserDefaults standardUserDefaults];
//    NSString * date = [userDefualts objectForKey:[NSString stringWithFormat:@"garmin.last.local.sync.date.%@",key]];
//    if (date==nil || [date isEqualToString:@""]) {
//        NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
//        date = [dateFormat stringFromDate:[NSDate new]];
//
//        [GarminData setLastSyncDate:date withKey:key];
//    }
//    return date;
//}
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
//
//////////////////////////////////////////////////////////////
//// is this sync variable a way of getting to instantaneous data transfer and rapid EMI to user?
//- (int) getDaysBetweenLocalSyncDate:(NSString *)localSyncDate andRemoteSyncDate:(NSString *)remoteSyncDate {
//    NSString * format = @"YYYY-MM-dd";
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    [dateFormatter setDateFormat:format];
//    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
//
//    NSDate * localDate = [dateFormatter dateFromString:localSyncDate];
//    NSLog(@"%@", localDate);
//
//    NSDate * remoteDate = [dateFormatter dateFromString:remoteSyncDate];
//
//    NSTimeInterval interval = [remoteDate timeIntervalSinceDate:localDate];
//    // NSLog(@"%ld",(long)interval/60/60/24);
//    return interval;
//}
//
//- (NSString *) getNextDateFromDate:(NSString *)date{
//    NSString * format = @"YYYY-MM-dd";
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    [dateFormatter setDateFormat:format];
//    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
//    NSDate * targetDate = [dateFormatter dateFromString:date];
//
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear|
//                                   NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|
//                                   NSCalendarUnitMinute|NSCalendarUnitSecond
//                                              fromDate:targetDate];
//    [dateComps setDay:(dateComps.day + 1)];
//    [dateComps setHour:0];
//    [dateComps setMinute:0];
//    [dateComps setSecond:0];
//
//    NSDate * nextDate = [calendar dateFromComponents:dateComps];
//
//    format = @"YYYY-MM-dd'T'HH:mm:ss";
//    NSDateFormatter *fullDateFormatter = [NSDateFormatter new];
//    [fullDateFormatter setDateFormat:format];
//    [fullDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
//    NSString * finalDateStr = [fullDateFormatter stringFromDate:nextDate];
//
//    return finalDateStr;
//}
//
//
@end
