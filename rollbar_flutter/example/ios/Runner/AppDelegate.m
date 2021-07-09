#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <RollbarMethodChannel.h>

static NSInteger const kErrorCodeBatteryError = -1;
static NSString* const kErrorReasonBatteryError = @"battery_error";

static NSInteger const kErrorCodeFaultyMethod = -2;
static NSString* const kErrorReasonFaultyMethod = @"faulty_method";

static FlutterError* getFlutterError(NSError* error) {
  NSString* errorCode;
  if (error.code == kErrorCodeFaultyMethod) {
      errorCode = kErrorReasonFaultyMethod;
  } else if (error.code == kErrorCodeBatteryError) {
      errorCode = kErrorReasonBatteryError;
  }
  
  return [FlutterError errorWithCode:errorCode
                       message:error.domain
                       details:error.localizedDescription];
}

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
  self.counter = 0;
  FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

  RollbarMethodChannel* batteryChannel = [RollbarMethodChannel
                                          methodChannelWithName:@"com.rollbar.flutter.example/activity"
                                          binaryMessenger:controller.binaryMessenger];

  __weak typeof(self) weakSelf = self;
  [batteryChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"getBatteryLevel" isEqualToString:call.method]) {
      NSError* error = nil;
      int batteryLevel = [weakSelf getBatteryLevel:&error];

      if (batteryLevel == -1) {
        result([FlutterError errorWithCode:@"UNAVAILABLE"
                                   message:@"Battery info unavailable"
                                   details:nil]);
      } else if (error != nil) {
        result(getFlutterError(error));
      } else {
        result(@(batteryLevel));
      }
    } else if ([@"faultyMethod" isEqualToString:call.method]) {
      NSError* error = nil;
      NSString* faultyResult = [weakSelf faultyMethod:&error];

      if (error != nil) {
        result(getFlutterError(error));
      } else {
        result(faultyResult);
      }
    } else if ([@"crash" isEqualToString:call.method]) {
        @throw NSInternalInconsistencyException;
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];

  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (int) getBatteryLevel:(NSError**)error {
  NSInteger current = [self counter];
  [self setCounter:(current + 1)];
  if (current % 2 == 1) {
      NSString* domain = @"com.rollbar.flutter.example.BatteryError";
      
      NSString* desc = [NSString stringWithFormat:@"Invalid counter state: %ld", (long)current];
      NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : desc };
      *error = [NSError errorWithDomain:domain code:kErrorCodeBatteryError userInfo:userInfo];
      return -1;
  }
  
  UIDevice* device = UIDevice.currentDevice;
  device.batteryMonitoringEnabled = YES;
  if (device.batteryState == UIDeviceBatteryStateUnknown) {
    return -1;
  } else {
    return (int)(device.batteryLevel * 100);
  }
}

- (NSString *) faultyMethod:(NSError**)error {
    NSString* domain = @"com.rollbar.flutter.example.FaultyError";
    NSString* desc = @"You called a method called 'faultyMethod', what did you expect";
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : desc };
    *error = [NSError errorWithDomain:domain code:kErrorCodeFaultyMethod userInfo:userInfo];
    return nil;
}

@end
