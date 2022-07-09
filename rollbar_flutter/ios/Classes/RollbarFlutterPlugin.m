@import SystemConfiguration;
#import "RollbarFlutterPlugin.h"
#import <Rollbar/Rollbar.h>

@implementation RollbarFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"com.rollbar.flutter"
                                     binaryMessenger:[registrar messenger]];
    RollbarFlutterPlugin* instance = [[RollbarFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result
{
    if ([@"initialize" isEqualToString:call.method]) {
        NSDictionary* arguments = call.arguments;
        NSString* endpoint = (NSString*)arguments[@"endpoint"];
        NSString* accessToken = (NSString*)arguments[@"accessToken"];
        NSString* environment = (NSString*)arguments[@"environment"];
        NSString* codeVersion = (NSString*)arguments[@"codeVersion"];
        BOOL handleUncaughtErrors = ((NSNumber*)arguments[@"handleUncaughtErrors"]).boolValue;
        BOOL includePlatformLogs = ((NSNumber*)arguments[@"includePlatformLogs"]).boolValue;

        [self initializeWithEndpoint:endpoint
                         accessToken:accessToken
                         environment:environment
                         codeVersion:codeVersion
                handleUncaughtErrors:handleUncaughtErrors
                 includePlatformLogs:includePlatformLogs];

        result(nil);
    } else if ([@"close" isEqualToString:call.method]) {
        // No closing necessary
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)initializeWithEndpoint:(NSString*)endpoint
                   accessToken:(NSString*)accessToken
                   environment:(NSString*)environment
                   codeVersion:(NSString*)codeVersion
          handleUncaughtErrors:(BOOL)handleUncaughtErrors
           includePlatformLogs:(BOOL)includePlatformLogs
{
    RollbarConfiguration* config = [RollbarConfiguration configuration];
    config.endpoint = endpoint;
    config.environment = environment;
    config.codeVersion = codeVersion;
    [Rollbar initWithAccessToken:accessToken
                   configuration:config
             enableCrashReporter:handleUncaughtErrors];
    [Rollbar.currentConfiguration setCaptureLogAsTelemetryData:includePlatformLogs];
}

@end
