#import "Modifier.h"
#import "React/RCTBridgeModule.h"

@implementation Modifier
RCT_EXPORT_MODULE()

// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
RCT_EXPORT_METHOD(methodModifier:(double)a
                  b:(double)b resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{ 
    ModifierMultiply *swiftClass = [[ModifierMultiply alloc] init];
    NSNumber *result = [NSNumber numberWithDouble: [swiftClass methodModifierWithA:a b:b]];
    resolve(result);
}
// - (void)methodModifier:(double)a b:(double)b resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
//      NSNumber *result = @(a * b);
//     resolve(result);
// }

RCT_EXPORT_METHOD(signInWithApple:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    AppleSignin *swiftClass = [[AppleSignin alloc] init];
    [swiftClass signInWithApple:resolve reject: reject];
}

- (void)configureSignin:(NSDictionary *)configObject resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject { 
}


RCT_EXTERN_METHOD(supportedEvents)

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeModifierSpecJSI>(params);
}
#endif


@end


