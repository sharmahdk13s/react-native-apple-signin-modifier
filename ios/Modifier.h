#ifdef RCT_NEW_ARCH_ENABLED
#import "RNModifierSpec.h"
#import <react_native_modifier/react_native_modifier-Swift.h>
//#import "react_native_modifier-Swift.h"
NS_ASSUME_NONNULL_BEGIN
@interface Modifier : NSObject <NativeModifierSpec>
@end
NS_ASSUME_NONNULL_END
#else
#import <React/RCTBridgeModule.h>

@interface Modifier : NSObject <RCTBridgeModule>
@end

#endif
