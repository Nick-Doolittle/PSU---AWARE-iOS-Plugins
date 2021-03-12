//
//  Garmin.h
//  This code is directly from Fitbit.h; however, the variable names are changed to reflect the fact that this is specifically Garmin.
//  In the end, once we start actually coding this, we are going to need to figure out what we need a
//  Created by John Smith V on 2/21/21.
//

#import "AWARESensor.h"

extern NSString * _Nonnull const AWARE_PREFERENCES_STATUS_GARMIN;

extern NSInteger const AWARE_ALERT_GARMIN_MOVE_TO_LOGIN_PAGE;

// The declaration of a class always needs to be preceded with @interface; it is then importing the AWARESensor class
@interface Garmin : AWARESensor <AWARESensorDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

NS_ASSUME_NONNULL_BEGIN

@property (nullable) UIViewController * viewController;

- (void) loginWithOAuth2WithClientId:(NSString *)clientId apiSecret:(NSString *)apiSecret;
- (void) refreshToken;
- (void) getData:(id)sender;
- (void) downloadTokensFromGarminServer;
- (BOOL) handleURL:(NSURL * _Nullable)url sourceApplication:(NSString * _Nullable)sourceApplication annotation:(id _Nullable)annotation;

typedef void (^GarminLoginCompletionHandler) (NSDictionary <NSString * , id > * _Nonnull tokens);
- (void) requestLoginWithUIViewController:(UIViewController * _Nullable) viewController completion:(GarminLoginCompletionHandler _Nullable)handler;
+ (bool) isNeedLogin;

+ (void) setGarminAccessToken:(NSString *)accessToken;
+ (void) setGarminRefreshToken:(NSString *)refreshToken;
+ (void) setGarminUserId:(NSString *)userId;
// + (void) setFibitTokenType:(NSString *)tokenType;
+ (void) setGarminCode:(NSString *)code;
+ (void) setGarminApiSecret:(NSString *) apiSecret;
+ (void) setGarminClientId:(NSString *) clientId;
    
+ (NSString *) getGarminAccessToken;
+ (NSString *) getGarminRefreshToken;
+ (NSString *) getGarminClientId;
+ (NSString *) getGarminApiSecret;
+ (NSString *) getGarminTokenType;
+ (NSString *) getGarminCode;
+ (NSString *) getGarminUserId;

+ (NSString *) getGarminApiSecretForUI:(bool)forUI;
+ (NSString *) getGarminClientIdForUI:(bool)forUI;

+ (void)clearAllSettings;

NS_ASSUME_NONNULL_END

@end
