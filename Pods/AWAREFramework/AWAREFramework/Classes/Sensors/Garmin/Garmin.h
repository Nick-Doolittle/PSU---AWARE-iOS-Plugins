//
//  Garmin.h
//  This code is directly from Fitbit.h; however, the variable names are changed to reflect the fact that this is specifically Garmin.
//  In the end, once we start actually coding this, we are going to need to figure out what we need a
//  Created by John Smith V on 2/21/21.
//

#import "AWARESensor.h"

//FOUNDATION_EXPORT NSString * const BDBGarminErrorDomain;

FOUNDATION_EXPORT NSString * const BDBGarminDidLogInNotification;
FOUNDATION_EXPORT NSString * const BDBGarminDidLogOutNotification;

extern NSString * _Nonnull const AWARE_PREFERENCES_STATUS_GARMIN;

extern NSInteger const AWARE_ALERT_GARMIN_MOVE_TO_LOGIN_PAGE;

#pragma mark -
@interface Garmin : AWARESensor <AWARESensorDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

NS_ASSUME_NONNULL_BEGIN

@property (nullable) UIViewController * viewController;

//@end

//@interface Garmin : NSObject

//@property (nonatomic, assign, readonly, getter = isAuthorized) BOOL authorized;

#pragma mark Initialization
+ (instancetype)createWithConsumerKey:(NSString *)apiKey secret:(NSString *)secret;
+ (instancetype)sharedClient;

- (void) loginWithOAuth1WithConsumerKey:(NSString *)key consumerSecret:(NSString *)secret;

- (BOOL) handleURL:(NSURL * _Nullable)url sourceApplication:(NSString * _Nullable)sourceApplication annotation:(id _Nullable)annotation;

typedef void (^GarminLoginCompletionHandler) (NSDictionary <NSString * , id > * _Nonnull tokens);
- (void) requestLoginWithUIViewController:(UIViewController * _Nullable) viewController completion:(GarminLoginCompletionHandler _Nullable)handler;

#pragma mark Authorization
- (BOOL)isAuthorized;
+ (BOOL)isAuthorizationCallbackURL:(NSURL *)url;
- (void)authorize;
- (BOOL)handleAuthorizationCallbackURL:(NSURL *)url;
- (void)deauthorize;

+ (void) setGarminConsumerSecret:(NSString *) secret;
+ (void) setGarminConsumerKey:(NSString *) key;

+ (NSString *) getGarminAccessToken;
//+ (NSString *) getGarminRequestToken;
+ (NSString *) getGarminConsumerKey;
+ (NSString *) getGarminConsumerSecret;

+ (NSString *) getGarminConsumerKeyForUI:(bool)forUI;
+ (NSString *) getGarminConsumerSecretForUI:(bool)forUI;

NS_ASSUME_NONNULL_END

@end













//extern NSString * _Nonnull const AWARE_PREFERENCES_STATUS_GARMIN;
//
//extern NSInteger const AWARE_ALERT_GARMIN_MOVE_TO_LOGIN_PAGE;
//
//// The declaration of a class always needs to be preceded with @interface; it is then importing the AWARESensor class
//@interface Garmin : AWARESensor <AWARESensorDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
//
//NS_ASSUME_NONNULL_BEGIN
//
//@property (nullable) UIViewController * viewController;
//
//- (void) loginWithOAuth1WithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;
//- (void) refreshToken;
//- (void) getData:(id)sender;
//- (void) authorizationFromGarminServer;
//- (BOOL) handleURL:(NSURL * _Nullable)url sourceApplication:(NSString * _Nullable)sourceApplication annotation:(id _Nullable)annotation;
//
//typedef void (^GarminLoginCompletionHandler) (NSDictionary <NSString * , id > * _Nonnull tokens);
//- (void) requestLoginWithUIViewController:(UIViewController * _Nullable) viewController completion:(GarminLoginCompletionHandler _Nullable)handler;
//+ (bool) isNeedLogin;
//
//+ (void) setGarminRequestToken:(NSString *)requestToken;
//+ (void) setGarminAccessToken:(NSString *)accessToken;
//+ (void) setGarminRefreshToken:(NSString *)refreshToken;
//+ (void) setGarminUserId:(NSString *)userId;
//// + (void) setFibitTokenType:(NSString *)tokenType;
//+ (void) setGarminCode:(NSString *)code;
//+ (void) setGarminConsumerSecret:(NSString *) consumerSecret;
//+ (void) setGarminConsumerKey:(NSString *) consumerKey;
//
//+ (NSString *) getGarminRequestToken;
//+ (NSString *) getGarminAccessToken;
//+ (NSString *) getGarminRefreshToken;
//+ (NSString *) getGarminConsumerKey;
//+ (NSString *) getGarminConsumerSecret;
//+ (NSString *) getGarminTokenType;
//+ (NSString *) getGarminCode;
//+ (NSString *) getGarminUserId;
//
//+ (NSString *) getGarminConsumerSecretForUI:(bool)forUI;
//+ (NSString *) getGarminConsumerKeyForUI:(bool)forUI;
//
//+ (void)clearAllSettings;
//
//NS_ASSUME_NONNULL_END
//
//@end
