@import SystemConfiguration;
#import "RollbarFlutterPlugin.h"
#import <Rollbar/Rollbar.h>

@implementation RollbarFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"rollbar_flutter"
                                     binaryMessenger:[registrar messenger]];
    RollbarFlutterPlugin* instance = [[RollbarFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"initialize" isEqualToString:call.method]) {
        NSDictionary* arguments = call.arguments;
        NSString* instanceId = (NSString*)arguments[@"instanceId"];
        BOOL isGlobalInstance = ((NSNumber*)arguments[@"isGlobalInstance"]).boolValue;
        NSString* endpoint = (NSString*)arguments[@"endpoint"];
        NSString* accessToken = (NSString*)arguments[@"accessToken"];
        NSString* environment = (NSString*)arguments[@"environment"];
        NSString* codeVersion = (NSString*)arguments[@"codeVersion"];
        BOOL handleUncaughtErrors = ((NSNumber*)arguments[@"handleUncaughtErrors"]).boolValue;
        BOOL includePlatformLogs = ((NSNumber*)arguments[@"includePlatformLogs"]).boolValue;
        
        [self initialize:instanceId isGlobalInstance:isGlobalInstance
                endpoint:endpoint accessToken:accessToken
             environment:environment codeVersion:codeVersion
    handleUncaughtErrors:handleUncaughtErrors includePlatformLogs:includePlatformLogs];
        result(nil);
    } else if ([@"close" isEqualToString:call.method]) {
        // No closing necessary
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)initialize:(NSString*)instanceId
  isGlobalInstance:(BOOL)isGlobalInstance
          endpoint:(NSString*)endpoint
       accessToken:(NSString*)accessToken
       environment:(NSString*)environment
       codeVersion:(NSString*)codeVersion
handleUncaughtErrors:(BOOL)handleUncaughtErrors
includePlatformLogs:(BOOL)includePlatformLogs {
    if (!isGlobalInstance) {
        NSLog(@"Only global Rollbar instances are supported on iOS");
        return;
    }
    
    RollbarConfiguration* config = [RollbarConfiguration configuration];
    config.endpoint = endpoint;
    config.environment = environment;
    config.codeVersion = codeVersion;
    [Rollbar initWithAccessToken:accessToken configuration:config enableCrashReporter:handleUncaughtErrors];
    [Rollbar.currentConfiguration setCaptureLogAsTelemetryData:includePlatformLogs];
}

@end
