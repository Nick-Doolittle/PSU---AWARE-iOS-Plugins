////
////  Garmin.m
////  Pods
////
////  Created by John Smith V on 2/21/21.
////
//

#import "Garmin.h"
#import "GarminData.h"
#import "GarminDevice.h"
#import "AWAREUtils.h"

NSString* const AWARE_PREFERENCES_STATUS_GARMIN = @"status_plugin_garmin";

NSInteger const AWARE_ALERT_GARMIN_MOVE_TO_LOGIN_PAGE = 2;

@implementation Garmin{
    GarminData * garminData;
    GarminDevice * garminDevice;
    NSString * baseOAuth2URL;
    NSString * redirectURI;
    NSNumber * expiresIn;
    NSTimer * updateTimer;
    
    NSMutableData * profileData;
    NSMutableData * refreshTokenData;
    NSMutableData * tokens;
    
    NSString * identificationForGarminProfile;
    NSString * identificationForGarminRefreshToken;
    NSString * identificationForGarminTokens;
    
    NSDateFormatter * hourFormat;
    
    GarminLoginCompletionHandler loginCompletionHandler;
    
    double intervalMin;
}

// Creation of an AWARE Study, which is going to request user login
- (instancetype)initWithAwareStudy:(AWAREStudy *)study
                            dbType:(AwareDBType)dbType{
    
    AWAREStorage * storage = [[JSONStorage alloc] initWithStudy:study sensorName:SENSOR_PLUGIN_GARMIN];
    
    self = [super initWithAwareStudy:study
                          sensorName:SENSOR_PLUGIN_GARMIN
                             storage:storage];
    if(self != nil){
        garminData = [[GarminData alloc] initWithAwareStudy:study dbType:dbType];
        garminDevice = [[GarminDevice alloc] initWithAwareStudy:study dbType:dbType];
        // It may be this: https://connectapi.garmin.com/oauth-service/oauth/request_token
        baseOAuth2URL = @"https://connectapi.garmin.com/oauth-service/oauth/request_token";
        print("")
        // Need the oath consumer key, which is provided by Garmin
        redirectURI = @"garmin://logincallback";
        // When the token is set to expire
        expiresIn = @( 1000L*60L*60L*24L); // 1day  //*365L ); // 1 Year
        
        profileData = [[NSMutableData alloc] init];
        refreshTokenData = [[NSMutableData alloc] init];
        tokens = [[NSMutableData alloc] init];
        
        identificationForGarminProfile = @"action.aware.plugin.garmin.api.get.profile";
        identificationForGarminRefreshToken = @"action.aware.plugin.garmin.api.get.refresh_token";
        identificationForGarminTokens = @"action.aware.plugin.garmin.api.get.tokens";
        
        hourFormat = [[NSDateFormatter alloc] init];
        [hourFormat setDateFormat:@"yyyy-MM-dd HH"];
        _viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        intervalMin = 15;
    }
    
    return self;
}

// Create a table for what? For the Context Cards?
- (void)createTable{
    [garminData createTable];
    [garminDevice createTable];
    [super createTable];
}

// Sync with the local data base? Or on a server?
- (void)startSyncDB{
    [garminData startSyncDB];
    [garminDevice startSyncDB];
    [super startSyncDB];
}

// Literally stop the syncing with the database, whether it's local or a server
- (void)stopSyncDB{
    [garminData stopSyncDB];
    [garminDevice stopSyncDB];
    [super stopSyncDB];
}

- (void)setParameters:(NSArray *)parameters{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:parameters forKey:@"aware.plugn.garmin.settings"];
    
    // Is this the interval that we're going to be querying the Garmin Server?
    double interval = [self getSensorSetting:parameters withKey:@"plugin_garmin_frequency"];
    if(interval>0){
        intervalMin = interval;
    }
}

// Starting the sensor when the boolean in the App UI is set to true
- (BOOL)startSensor{
    
    if([Garmin getGarminAccessToken] == nil || [[Garmin getGarminAccessToken] isEqualToString:@""]) {
        // The user needs to login to their Garmin account
        [self requestLoginWithUIViewController:self.viewController completion:nil];
    }
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:intervalMin*60
                                                   target:self
                                                 selector:@selector(getData:)
                                                 userInfo:[[NSDictionary alloc] initWithObjects:@[@"all"] forKeys:@[@"type"]]
                                                  repeats:YES];
    [updateTimer fire];
    [self setSensingState:YES];
    return YES;
}

// Stopping the sensor when the boolean in the App UI is set to False
- (BOOL)stopSensor{
    if(updateTimer != nil){
        [updateTimer invalidate];
        updateTimer = nil;
    }
    [self setSensingState:NO];
    return YES;
}


// Checked when the user turns the Garmin boolean to true and the user needs to login?
+ (bool)isNeedLogin {
    NSString * token = [Garmin getGarminAccessToken];
    if (token == nil || [token isEqualToString:@""]) {
        return YES;
    }else{
        return NO;
    }
}

// When the user hits True on the app ui, this method is then called and it shows an animation asking whether or not the user wants to login to their Garmin account
- (void)requestLoginWithUIViewController:(UIViewController *)viewController completion:(GarminLoginCompletionHandler)handler{
    loginCompletionHandler = handler;
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Garmin Login Required"
                                                                    message:@"Login to your Garmin Connect account to enable this sensor."
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * moveToLoginPage = [UIAlertAction actionWithTitle:@"Move to Login Page" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString * clientId = [Garmin getGarminClientIdForUI:NO];
        NSString * apiSecret = [Garmin getGarminApiSecretForUI:NO];
        [self loginWithOAuth2WithClientId:clientId apiSecret:apiSecret];
    }];
    
    [alert addAction:dismiss];
    [alert addAction:moveToLoginPage];
    
    _viewController = viewController;
    if (_viewController != nil) {
        [_viewController presentViewController:alert animated:YES completion:nil];
    }
}

// Need to remove all of these things when the user sets the boolean to false
- (BOOL)quitSensor{
    NSUserDefaults * userDefualt = [NSUserDefaults standardUserDefaults];
    [userDefualt removeObjectForKey:@"garmin.setting.access_token"];
    [userDefualt removeObjectForKey:@"garmin.setting.user_id"];
    [userDefualt removeObjectForKey:@"garmin.setting.token_type"];
    [userDefualt removeObjectForKey:@"api_key_plugin_garmin"];
    [userDefualt removeObjectForKey:@"api_secret_plugin_garmin"];
    [userDefualt synchronize];
    return YES;
}


- (void) sendBroadcastNotification:(NSString *) message {
    if ([NSThread isMainThread]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"aware.plugin.garmin.debug.event" object:self userInfo:@{@"message":message}];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendBroadcastNotification:message];
        });
    }
}

// This function is explicitly for getting the necessary data
- (void) getData:(id)sender{
    
    NSDictionary * userInfo = [sender userInfo] ;
    NSString * type = [userInfo objectForKey:@"type"];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * settings = [defaults objectForKey:@"aware.plugn.garmin.settings"];
    
    [self getProfile];
    
    [self sendBroadcastNotification:@"call -getData: method"];
    
    [garminDevice getDeviceInfoWithCallback:^(NSString *garminId, NSString *garminVersion, NSString *garminBattery, NSString *garminMac, NSString *garminLastSync) {
        // 2018-05-25T07:39:54.000
        [self sendBroadcastNotification:[NSString stringWithFormat:@"last sync: %@", garminLastSync]];
        
        
        /// granularity of garmin data =>  1d/15min/1min
        NSString * activityDetailLevel = [self getSettingAsStringFromSttings:settings withKey:@"garmin_granularity"];
        if([activityDetailLevel isEqualToString:@""] || activityDetailLevel == nil ){
            activityDetailLevel = @"1d";
        }
        
        /// granularity of hr data => 1min/1sec
        NSString * hrDetailLevel = [self getSettingAsStringFromSttings:settings withKey:@"garmin_hr_granularity"];
        if( [hrDetailLevel isEqualToString:@""] || hrDetailLevel == nil){
            hrDetailLevel = @"1min";
        }
        
        // 1d/15min/1min
        int granuTimeActivity = 60*60*24;
        if([activityDetailLevel isEqualToString:@"15min"]) {
            granuTimeActivity = 60*15;
        }else if([activityDetailLevel isEqualToString:@"1min"]){
            granuTimeActivity = 60;
        }
        
        // 1min/1sec
        int granuTimeHr = 60;
        if ([hrDetailLevel isEqualToString:@"1sec"]) {
            granuTimeHr = 1;
        }
        
        NSString * remoteLastSyncDate = [self extractDateFromDateTime:garminLastSync];
        if (remoteLastSyncDate==nil) return;
        
        ///////////////// Step/Cal /////////////////////
        if([type isEqualToString:@"all"] || [type isEqualToString:@"steps"]){
            [self getStepsWithEnd:remoteLastSyncDate period:nil detailLevel:activityDetailLevel];
        }
        
        if([type isEqualToString:@"all"] || [type isEqualToString:@"calories"]){
            [self getCaloriesWithEnd:remoteLastSyncDate period:nil detailLevel:activityDetailLevel];
        }
        
        ///////////////// Heartrate ////////////////////
        if([type isEqualToString:@"all"] || [type isEqualToString:@"heartrate"]){
            [self getHeartrateWithEnd:remoteLastSyncDate period:nil detailLevel:hrDetailLevel];
        }
        
        ///////////////// Sleep  /////////////////////
        if([type isEqualToString:@"all"] || [type isEqualToString:@"sleep"]){
            [self getSleepWithEnd:remoteLastSyncDate period:nil detailLevel:activityDetailLevel];
        }
//        ///////////////// Stress /////////////////////
//        if([type isEqualToString:@"all"] || [type isEqualToString:@"stress"]){
//            // We are going to need to add a function for stress
//            [self getSleepWithEnd:remoteLastSyncDate period:nil detailLevel:activityDetailLevel];
//        }
//
    }];
}


- (void) getStepsWithEnd:(NSString *) end period:(NSString *)period detailLevel:(NSString *)activityDetailLevel{
    NSString * lastLocalSyncDate = [self extractDateFromDateTime:[GarminData getLastSyncDateSteps]];
    if(lastLocalSyncDate != nil)
        [garminData getStepsWithStart:lastLocalSyncDate end:end period:nil detailLevel:activityDetailLevel callback:^(NSData * data, NSString * nextSyncDate){
            if (nextSyncDate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getStepsWithEnd:end period:period detailLevel:activityDetailLevel];
                });
            }
        }];
}

- (void) getCaloriesWithEnd:(NSString *) end period:(NSString *)period detailLevel:(NSString *)activityDetailLevel{
    NSString * lastLocalSyncDate = [self extractDateFromDateTime:[GarminData getLastSyncDateCalories]];
    if(lastLocalSyncDate != nil)
        [garminData getCaloriesWithStart:lastLocalSyncDate end:end period:nil detailLevel:activityDetailLevel callback:^(NSData * data, NSString * nextSyncDate){
            if (nextSyncDate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getCaloriesWithEnd:end period:period detailLevel:activityDetailLevel];
                });
            }
        }];
}

- (void) getHeartrateWithEnd:(NSString *) end period:(NSString *)period detailLevel:(NSString *)activityDetailLevel{
    NSString * lastLocalSyncDate = [self extractDateFromDateTime:[GarminData getLastSyncDateHeartrate]];
    GarminHeartrateRequestCallback hrCallback = ^(NSData * data, NSString * nextSyncDate){
        if (nextSyncDate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getHeartrateWithEnd:end period:period detailLevel:activityDetailLevel];
            });
        }
    };
    if(lastLocalSyncDate != nil){
        [garminData getHeartrateWithStart:lastLocalSyncDate end:end period:nil detailLevel:activityDetailLevel callback:hrCallback];
    }
}

- (void) getSleepWithEnd:(NSString *) end period:(NSString *)period detailLevel:(NSString *)activityDetailLevel{
    NSString * lastLocalSyncDate = [self extractDateFromDateTime:[GarminData getLastSyncDateSleep]];
    if(lastLocalSyncDate != nil)
        [garminData getSleepWithStart:lastLocalSyncDate end:end period:nil detailLevel:activityDetailLevel callback:^(NSData *result, NSString * _Nullable nextSyncDate) {
            if (nextSyncDate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getSleepWithEnd:end period:period detailLevel:activityDetailLevel];
                });
            }
        }];
}

//- (void) getStressWithEnd:(NSString *) end period:(NSString *)period detailLevel:(NSString *)activityDetailLevel{
//    NSString * lastLocalSyncDate = [self extractDateFromDateTime:[GarminData getLastSyncDateStress]];
//    if(lastLocalSyncDate != nil)
//        [garminData getStressWithStart:lastLocalSyncDate end:end period:nil detailLevel:activityDetailLevel callback:^(NSData *result, NSString * _Nullable nextSyncDate) {
//            if (nextSyncDate) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self getStressWithEnd:end period:period detailLevel:activityDetailLevel];
//                });
//            }
//        }];
//}

// yyyy/MM/dd'T'HH:mm:ss.SSS -> yyyy/MM/dd
- (NSString *) extractDateFromDateTime:(NSString*) datetime {
    if (datetime == nil) return nil;
    NSArray* values = [datetime componentsSeparatedByString:@"T"];
    if (values.count > 1) {
        return values[0];
    }
    return nil;
}


////////////////////////////////////////////////////////////////////////////////////////
// Logging in with the users information and
- (void) loginWithOAuth2WithClientId:(NSString *)clientId apiSecret:(NSString *)apiSecret {
    
    NSMutableString * url = [[NSMutableString alloc] initWithString:baseOAuth2URL];
    
    //[url appendFormat:@"?response_type=token&client_id=%@",clientId];
    [url appendFormat:@"?response_type=code&client_id=%@",clientId];
    // [url appendFormat:@"&redirect_uri=%@", [AWAREUtils stringByAddingPercentEncoding:@"aware-client://com.aware.ios.oauth2" unreserved:@"-."]];
    [url appendFormat:@"&redirect_uri=%@", [AWAREUtils stringByAddingPercentEncoding:redirectURI unreserved:@"-."]];
    [url appendFormat:@"&scope=%@", [AWAREUtils stringByAddingPercentEncoding:@"activity heartrate location nutrition profile settings sleep social weight"]];
    [url appendFormat:@"&expires_in=%@", expiresIn.stringValue];
    
    // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
        
    }];
}// message outputted trying to receive credentials:
// Message: Inadequate Oauth consumer credentials
// Description: The server cannot process the request due to something that is perceived to be a client error...

///////////////////////////////////////////////////////////////////
// Not sure what this is supposed to do....
- (NSDate *) smoothDateWithHour:(NSDate *) date{
    NSString * smoothedData = [hourFormat stringFromDate:date];
    return [hourFormat dateFromString:smoothedData];
}

///////////////////////////////////////////////////////////////////

- (void) saveProfileWithData:(NSData *) data{
    NSString *responseString = [[NSString alloc] initWithData: data  encoding: NSUTF8StringEncoding];
    if (self.isDebug) NSLog(@"Success: %@", responseString);
    
    @try {
        if(responseString != nil){
            NSError *error = nil;
            NSDictionary *values = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingAllowFragments error:&error];
            if (error != nil) {
                NSString * errorMsg = [NSString stringWithFormat:@"failed to parse JSON: %@", error.debugDescription];
                if (self.isDebug) NSLog(@"%@", errorMsg);
                [self sendBroadcastNotification:errorMsg];
                return;
            }else{
                // [self saveDebugEventWithText:@"success to parse JSON" type:DebugTypeError label:SENSOR_PLUGIN_FITBIT];
            }
            
            //{
            //"errors":[{
            //    "errorType":"expired_token",
            //    "message":"Access token expired: eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI1Q1JSQ1QiLCJhdWQiOiIyMjg3VDciLCJpc3MiOiJGaXRiaXQiLCJ0eXAiOiJhY2Nlc3NfdG9rZW4iLCJzY29wZXMiOiJyc29jIHJzZXQgcmFjdCBybG9jIHJ3ZWkgcmhyIHJudXQgcnBybyByc2xlIiwiZXhwIjoxNDg1Mjk4NDU2LCJpYXQiOjE0ODUyNjk2NTZ9.NTEcqo3wOFLAZ6jL-BcGhYrVENb8g3nps-LVpEv4UNQ. Visit https://dev.fitbit.com/docs/oauth2 for more information on the Fitbit Web API authorization process."}
            //    ],
            //"success":false
            // }
            
            //if(![values objectForKey:@"user"]){
            
            NSArray * errors = [values objectForKey:@"errors"];
            if(errors != nil){
                for (NSDictionary * errorDict in errors) {
                    NSString * errorType = [errorDict objectForKey:@"errorType"];
                    // When the token is invald, gonna ask to login again?
                    if([errorType isEqualToString:@"invalid_token"]){
                        [self loginWithOAuth2WithClientId:[Garmin getGarminClientId] apiSecret:[Garmin getGarminApiSecret]];
                    }else if([errorType isEqualToString:@"expired_token"]){
                        [self refreshToken];
                        [self sendBroadcastNotification:errorType];
                    }
                }
                NSString * errorMsg = [NSString stringWithFormat:@"[%@][error] %@", [self getSensorName], error.debugDescription ];
                [self sendBroadcastNotification:errorMsg];
            }else{

            }
            // invalid_token
            // expired_token
            // invalid_client
            // invalid_request
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Downloading the necessary tokens from the Garmin server so we are able to get access to the users data
- (void) downloadTokensFromGarminServer {
    NSString * code = [Garmin getGarminCode];
    if(code!= nil){
        // Need this URL: https://connectapi.garmin.com/oauth-service/oauth/request_token
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"https://connectapi.garmin.com/oauth-service/oauth/request_token"]];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
        NSString * baseAuth = [NSString stringWithFormat:@"%@:%@",[Garmin getGarminClientIdForUI:NO],[Garmin getGarminApiSecretForUI:NO]];
        NSData * nsdata = [baseAuth dataUsingEncoding:NSUTF8StringEncoding];
        // Get NSString from NSData object in Base64
        NSString * base64Encoded = [nsdata base64EncodedStringWithOptions:0];
        [request setValue:[NSString stringWithFormat:@"Basic %@", base64Encoded] forHTTPHeaderField:@"Authorization"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSMutableString * bodyStr = [[NSMutableString alloc] init];
        [bodyStr appendFormat:@"clientId=%@&",[Garmin getGarminClientIdForUI:NO]];
        [bodyStr appendFormat:@"grant_type=authorization_code&"];
        // By default, Garmin Connect will honor the oauth callback URL configured when creating the consumer
        // key through the Developer Portal. This pre-configured callback URL may be overridden using the URL parameter ‘oauth_callback’ if desired.
        [bodyStr appendFormat:@"redirect_uri=%@&",[AWAREUtils stringByAddingPercentEncoding:@"garmin://logincallback" unreserved:@"-."]];
        [bodyStr appendFormat:@"code=%@",code];
        
        [request setHTTPBody: [bodyStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] ];
        [request setHTTPMethod:@"POST"];
        
        NSURLSessionConfiguration *sessionConfig = nil;
        
        tokens = [[NSMutableData alloc] init];
        
        sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identificationForGarminTokens];
        sessionConfig.timeoutIntervalForRequest = 180.0;
        sessionConfig.timeoutIntervalForResource = 60.0;
        sessionConfig.HTTPMaximumConnectionsPerHost = 60;
        sessionConfig.allowsCellularAccess = YES;
        
        __weak NSURLSession *session = nil;
        session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:Nil];
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request];
        [dataTask resume];
        
    }else{
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Garmin Login Error"
                                                                        message:@"The Garmin code is Null." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * close = [UIAlertAction actionWithTitle:@"close" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:close];
        if (_viewController) {
            [_viewController presentViewController:alert animated:YES completion:nil];
        }
        if (self.isDebug) NSLog(@"Garmin Login Error: The Garmin code is Null");
    }
}

- (BOOL) handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    // aware-client://com.aware.ios.oauth2?code=35c0ec0d9b3873b270f0c1787ac33472e58176ec,_=_
    ////////////  Authorization Code Flow ////////////
    // NSString * userId = [Garmin getGarminUserId];
    // NSString * token = [Garmin getGarminAccessToken];
    
    NSArray *components = [url.absoluteString componentsSeparatedByString:@"?"];
    if(components!=nil && components.count > 1){
        NSMutableString * code = [NSMutableString stringWithString:[components objectAtIndex:1]];
        [code deleteCharactersInRange:NSMakeRange(code.length-4, 4)];
        [code deleteCharactersInRange:NSMakeRange(0, 5)];
        // Save the code
        if(code != nil){
            [Garmin setGarminCode:code];
            [self downloadTokensFromGarminServer];
        }
    }else{
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Garmin Login Error"
                                                                        message:url.absoluteString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * close = [UIAlertAction actionWithTitle:@"close" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:close];
        if (_viewController) {
            [_viewController presentViewController:alert animated:YES completion:nil];
        }
    }
    return YES;
}

// Do we need this function for Garmin?
- (void) getProfile{
    
    [self sendBroadcastNotification:@"call -getProfile method"];
    
    NSString * userId = [Garmin getGarminUserId];
    NSString* token = [Garmin getGarminAccessToken];
    
    NSURL*    url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.garmin.com/1/user/%@/profile.json",userId]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    
    if(token == nil) return;
    if(userId == nil) return;
    
    profileData = [[NSMutableData alloc] init];
    
    __weak NSURLSession *session = nil;
    NSURLSessionConfiguration *sessionConfig = nil;
    
    sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identificationForGarminProfile];
    sessionConfig.timeoutIntervalForRequest = 180.0;
    sessionConfig.timeoutIntervalForResource = 60.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 60;
    sessionConfig.allowsCellularAccess = YES;
    
    session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:Nil];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request];
    [dataTask resume];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// When the session expires, we are going to want to request a new token which is going to enable the app to continue to get user information
- (void) refreshToken {
    
    [self sendBroadcastNotification:@"call -refreshToken method"];
    
    if([Garmin getGarminClientIdForUI:NO] == nil) return;
    if([Garmin getGarminApiSecretForUI:NO] == nil) return;
    
    // Set URL
    NSURL*    url = [NSURL URLWithString:[NSString stringWithFormat:@"https://connectapi.garmin.com/oauth-service/oauth/request_token"]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    // Create NSData object
    NSString * baseAuth = [NSString stringWithFormat:@"%@:%@",[Garmin getGarminClientIdForUI:NO],[Garmin getGarminApiSecretForUI:NO]];
    NSData *nsdata = [baseAuth dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    
    [request setValue:[NSString stringWithFormat:@"Basic %@", base64Encoded] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableString * bodyStr = [[NSMutableString alloc] init];
    // [bodyStr appendFormat:@"clientId=%@&",[Garmin getGarminClientId]];
    [bodyStr appendFormat:@"grant_type=refresh_token&"];
    [bodyStr appendFormat:@"refresh_token=%@",[Garmin getGarminRefreshToken]];
    
    [request setHTTPBody: [bodyStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] ];
    [request setHTTPMethod:@"POST"];
    
    __weak NSURLSession *session = nil;
    // NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // sessionConfiguration.allowsCellularAccess = YES;
    // session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:Nil];
    
    refreshTokenData = [[NSMutableData alloc] init];
    
    NSURLSessionConfiguration *sessionConfig = nil;
    
    sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identificationForGarminRefreshToken];
    sessionConfig.timeoutIntervalForRequest = 180.0;
    sessionConfig.timeoutIntervalForResource = 60.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 60;
    sessionConfig.allowsCellularAccess = YES;
    
    session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:Nil];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request];
    
    [session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        if (dataTasks != nil){
            for (NSURLSessionDataTask * task in dataTasks) {
                if (self.isDebug) NSLog(@"[%tu] %@", task.taskIdentifier, sessionConfig.identifier);
            }
            [self sendBroadcastNotification:[NSString stringWithFormat:@"data tasks: %tu",dataTasks.count]];

        }
    }];
    
    [dataTask resume];
}



//////////////////////////////////////////////////////////////////

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    // NSString * identifier = session.configuration.identifier;
    // NSLog(@"[%@] session:dataTask:didReceiveResponse:completionHandler:",identifier);
    completionHandler(NSURLSessionResponseAllow);
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    int responseCode = (int)[httpResponse statusCode];
    if (responseCode == 200) {
        [session finishTasksAndInvalidate];
        if (self.isDebug) NSLog(@"[%d] Success",responseCode);
    }else{
        [session invalidateAndCancel];
    }
    // [super URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}




-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSString * identifier = session.configuration.identifier;
    if([identifier isEqualToString:identificationForGarminProfile]){
        [profileData appendData:data];
    }else if([identifier isEqualToString:identificationForGarminRefreshToken]){
        [refreshTokenData appendData:data];
    }else if([identifier isEqualToString:identificationForGarminTokens]){
        [tokens appendData:data];
    }
    // [super URLSession:session dataTask:dataTask didReceiveData:data];
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSString * identifier = session.configuration.identifier;
    if (error != nil) {
        if (self.isDebug) NSLog(@"%@", error);
        [self sendBroadcastNotification:[NSString stringWithFormat:@"URLSession:task:didCompleteWithError: %@",error.debugDescription]];
    }
    if([identifier isEqualToString:identificationForGarminProfile]){
        NSData * data = [profileData copy];
        [self saveProfileWithData:data];
        profileData = [[NSMutableData alloc] init];
    }else if([identifier isEqualToString:identificationForGarminRefreshToken]){
        NSData * data  = [refreshTokenData copy];
        [self saveRefreshToken:data];
        refreshTokenData = [[NSMutableData alloc] init];
    }else if([identifier isEqualToString:identificationForGarminTokens]) {
        NSData * data = [tokens copy];
        [self saveTokens:data];
        tokens = [[NSMutableData alloc] init];
    }
    // [super URLSession:session task:task didCompleteWithError:error];
}


- (void) saveRefreshToken:(NSData *) data{
    NSString *responseString = [[NSString alloc] initWithData: data  encoding: NSUTF8StringEncoding];
    if (self.isDebug) NSLog(@"Success: %@", responseString);
    
    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendBroadcastNotification:[NSString stringWithFormat:@"-saveRefreshToken:%@",responseString]];
            
            if(responseString != nil){
                NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
                
                NSError *error = nil;
                NSDictionary *values = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                       options:NSJSONReadingAllowFragments error:&error];
                if (error != nil) {
                    if (self.isDebug) NSLog(@"failed to parse JSON: %@", error.debugDescription);
                    [self sendDebugAlertWithTitle:@"[Garmin] Refresh Token: JSON Parsing Error"
                                          message:responseString
                                          buttons:@[@"close"]];
                    return;
                }
                
                if(values == nil){
                    [self sendDebugAlertWithTitle:@"[Garmin] Refresh Token: The value is empty"
                                          message:responseString
                                          buttons:@[@"close"]];
                    return;
                }
                
                // if([self isDebug]){
                if([values objectForKey:@"access_token"] == nil){
                    if([AWAREUtils isForeground]){
                        [self sendDebugAlertWithTitle:@"[Garmin] Refresh Token ERROR: access_tokne is empty"
                                              message:responseString
                                              buttons:@[@"close"]];
                    }else{
                        [self sendBroadcastNotification:@"[Garmin] Refresh Token: access_tokne is empty" ];
                    }
                    return;
                }else{
                    if([AWAREUtils isForeground]){
                        [self sendDebugAlertWithTitle:@"[Garmin] Refresh Token: Success"
                                              message:@"Garmin Plugin updates its access token using a refresh token."
                                              buttons:@[@"close"]];
                    }else{
                        [self sendBroadcastNotification:@"[Garmin] Refresh Token: Success to update tokens"];
                    }
                }
                
                NSString * accessToken = [values objectForKey:@"access_token"];
                if(accessToken != nil){
                    [Garmin setGarminAccessToken:accessToken];
                }
                
                NSString * userId = [values objectForKey:@"user_id"];
                if(userId != nil){
                    [Garmin setGarminUserId:userId];
                }
                
                NSString * refreshToken = [values objectForKey:@"refresh_token"];
                if(refreshToken != nil){
                    [Garmin setGarminRefreshToken:refreshToken];
                }
                
                NSString * tokenType = [values objectForKey:@"token_type"];
                if(tokenType != nil){
                    [Garmin setGarminTokenType:tokenType];
                }
                
                
            }else{
                [self sendDebugAlertWithTitle:@"[Garmin] Refresh Token: Garmin Login Error"
                                      message:@"No access token and user_id"
                                      buttons:@[@"close"]];
            }
        });
        
    } @catch (NSException *exception) {
        if (self.isDebug) NSLog(@"%@",exception.debugDescription);
        [self sendDebugAlertWithTitle:@"[Garmin] Refresh Token: Unknown Error occured"
                              message:exception.debugDescription
                              buttons:@[@"close"]];
    } @finally {
        
    }
}




- (void) saveTokens:(NSData *) data{
    if (self.isDebug) NSLog(@"A Garmin login query is called !!");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *responseString = [[NSString alloc] initWithData: data  encoding: NSUTF8StringEncoding];
        if (self.isDebug) NSLog(@"Success: %@", responseString);
        
        [self sendBroadcastNotification:[NSString stringWithFormat:@"-saveTokens:%@",responseString]];
        
        if(responseString != nil){
            NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError *error = nil;
            NSDictionary *values = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:NSJSONReadingAllowFragments error:&error];
            if (error != nil) {
                if (self.isDebug) NSLog(@"failed to parse JSON: %@", error.debugDescription);
                [self sendDebugAlertWithTitle:@"[Garmin Login] Error: JSON parsing error"
                                      message:[NSString stringWithFormat:@"failed to parse JSON: %@",error.debugDescription]
                                      buttons:@[@"close"]];
                return;
            }
            
            if(values == nil){
                [self sendDebugAlertWithTitle:@"[Garmin Login] Error: value is empty"
                                      message:@"The value is null..."
                                      buttons:@[@"close"]];
                return;
            }
            
            
            if(![values objectForKey:@"access_token"]){
                [self sendDebugAlertWithTitle:@"[Garmin Login] Error: access_token is empty"
                                      message:responseString
                                      buttons:@[@"close"]];
                if (self.isDebug) NSLog(@"Garmin Login Error: %@", responseString);
                return;
            }else{
                [self sendDebugAlertWithTitle:@"[Garmin Login] Success"
                                      message:@"Garmin Plugin obtained an access token, refresh token, and user_id from Garmin API."
                                      buttons:@[@"close"]];
            }
            
            NSString * accessToken = [values objectForKey:@"access_token"];
            if(accessToken != nil){
                [Garmin setGarminAccessToken:accessToken];
            }
            
            NSString * userId = [values objectForKey:@"user_id"];
            if(userId != nil){
                [Garmin setGarminUserId:userId];
            }
            
            NSString * refreshToken = [values objectForKey:@"refresh_token"];
            if(refreshToken != nil){
                [Garmin setGarminRefreshToken:refreshToken];
            }
            
            NSString * tokenType = [values objectForKey:@"token_type"];
            if(tokenType != nil){
                [Garmin setGarminTokenType:tokenType];
            }
            
            
            if (self->loginCompletionHandler != nil) {
                self->loginCompletionHandler(values);
            }
            
        }else{
            [self sendDebugAlertWithTitle:@"[Garmin Login] Error: Unknown error occured"
                                  message:@"The response from Garmin server is Null."
                                  buttons:@[@"close"]];
            if (self.isDebug) NSLog(@"Garmin Login Error: %@", @"The response from Garmin server is Null");
        }
        
    });
}

//////////////////////////////////////////////////////////////////////////////

+ (void) setGarminAccessToken:(NSString * )accessToken{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:accessToken forKey:@"garmin.setting.access_token"];
    [userDefault synchronize];
}

+ (void) setGarminRefreshToken:(NSString *) refreshToken{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:refreshToken forKey:@"garmin.setting.refresh_token"];
    [userDefault synchronize];
}

+ (void) setGarminUserId:(NSString *)userId{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:userId forKey:@"garmin.setting.user_id"];
    [userDefault synchronize];
}

+ (void) setGarminTokenType:(NSString *) tokenType{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:tokenType forKey:@"garmin.setting.token_type"];
    [userDefault synchronize];
}

//clientId
+ (void) setGarminClientId:(NSString *) clientId{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:clientId forKey:@"garmin.setting.client_id"];
    [userDefault synchronize];
}

//apiSecret
+ (void) setGarminApiSecret:(NSString *) apiSecret{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:apiSecret forKey:@"garmin.setting.api_secret"];
    [userDefault synchronize];
}

+ (void) setGarminCode:(NSString *) code {
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:code forKey:@"garmin.setting.code"];
}

//////////////////////////////////////////////////////////////////////////////

+ (NSString *)getGarminAccessToken{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault objectForKey:@"garmin.setting.access_token"];
}

+ (NSString *) getGarminRefreshToken{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault objectForKey:@"garmin.setting.refresh_token"];
}

+ (NSString *) getGarminClientId{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault objectForKey:@"garmin.setting.client_id"];
}

+ (NSString *)getGarminUserId{
    NSUserDefaults * userDefault  = [NSUserDefaults standardUserDefaults];
    NSString * userId = [userDefault objectForKey:@"garmin.setting.user_id"];
    return userId;
}

+ (NSString *)getGarminTokenType{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault objectForKey:@"garmin.setting.token_type"];
}

+ (NSString *) getGarminCode{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault objectForKey:@"garmin.setting.code"];
}

+ (NSString *) getGarminApiSecret {
    NSUserDefaults * userDefualt = [NSUserDefaults standardUserDefaults];
    return [userDefualt objectForKey:@"garmin.setting.api_secret"];
}



//clientId

+ (NSString *) getGarminClientIdForUI:(bool)forUI{
    // NSUserDefaults * userDefualt = [NSUserDefaults standardUserDefaults];
    // NSString * clientId = [userDefualt objectForKey:@"fitbit.setting.client_id"];
    NSString * clientId = [Garmin getGarminClientId];
    // TODO: This may need to change
    if(clientId == nil || [clientId isEqualToString:@""]){
        if(forUI){
            return @"";
        }else{
            return @"227YG3";
        }
    }else{
        return clientId;
    }
}

//apiSecret: this is going to be important so we are able to get the user data | this is going to need to be stored on a server with security measures in place
+ (NSString *) getGarminApiSecretForUI:(bool)forUI{
    // NSUserDefaults * userDefualt = [NSUserDefaults standardUserDefaults];
    // NSString * apiSecret = [userDefualt objectForKey:@"garmin.setting.api_secret"];
    NSString * apiSecret = [Garmin getGarminApiSecret];
    // TODO: This may need to also change
    if(apiSecret == nil || [apiSecret isEqualToString:@""]){
        if(forUI){
            return @"";
        }else{
            return @"033ed2a3710c0cde04343d073c09e378";
        }
    }else{
        return apiSecret;
    }
}


//////////////////////////////////////////////////////////////////////////////////////

// Clears all of the different keys for the user when the boolean is set to false?
+ (void)clearAllSettings{
    NSUserDefaults * userDefualt = [NSUserDefaults standardUserDefaults];
    [userDefualt removeObjectForKey:@"garmin.setting.access_token"];
    [userDefualt removeObjectForKey:@"garmin.setting.refresh_token"];
    [userDefualt removeObjectForKey:@"garmin.setting.user_id"];
    [userDefualt removeObjectForKey:@"garmin.setting.token_type"];
    [userDefualt removeObjectForKey:@"garmin.setting.client_id"];
    [userDefualt removeObjectForKey:@"garmin.setting.api_secret"];
    [userDefualt synchronize];
}

- (void) sendDebugAlertWithTitle:(NSString *) title message:(NSString *)message buttons:(NSArray<NSString *> *)buttons{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:message
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    if (buttons!=nil) {
        for (NSString * buttonName in buttons) {
            UIAlertAction * close = [UIAlertAction actionWithTitle:buttonName style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:close];
        }
    }
    if (_viewController) {
        [_viewController presentViewController:alert animated:YES completion:nil];
    }
}

@end


