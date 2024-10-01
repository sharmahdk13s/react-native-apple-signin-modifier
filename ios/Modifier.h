#ifdef RCT_NEW_ARCH_ENABLED
#import "RNModifierSpec.h"

@interface Modifier : NSObject <NativeModifierSpec>
#else
#import <React/RCTBridgeModule.h>

@interface Modifier : NSObject <RCTBridgeModule>
#endif

@end
