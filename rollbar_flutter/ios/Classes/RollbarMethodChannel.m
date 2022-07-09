#import "RollbarMethodChannel.h"

@implementation RollbarMethodChannel

+ (instancetype)methodChannelWithName:(NSString*)name
                      binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
{
    return [[RollbarMethodChannel alloc] initWithName:name
                                      binaryMessenger:messenger
                                                codec:FlutterStandardMethodCodec.sharedInstance];
}

+ (instancetype)methodChannelWithName:(NSString*)name
                      binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
                                codec:(NSObject<FlutterMethodCodec>*)codec
{
    return [[RollbarMethodChannel alloc] initWithName:name
                                      binaryMessenger:messenger
                                                codec:codec];
}

- (instancetype)initWithName:(NSString*)name
             binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
                       codec:(NSObject<FlutterMethodCodec>*)codec
{
    self = [super initWithName:name binaryMessenger:messenger codec:codec];
    return self;
}

- (void)setMethodCallHandler:(FlutterMethodCallHandler _Nullable)handler {
    __strong FlutterMethodCallHandler realHandler = handler;
    [super setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if (realHandler != nil) {
            realHandler(call, result);
        }
    }];
}

@end
