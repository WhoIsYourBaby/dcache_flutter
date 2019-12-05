#import "DcacheFlutterPlugin.h"
#import <dcache_flutter/dcache_flutter-Swift.h>

@implementation DcacheFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDcacheFlutterPlugin registerWithRegistrar:registrar];
}
@end
