import type { TurboModule, ViewStyle } from 'react-native';
import { TurboModuleRegistry, requireNativeComponent } from 'react-native';

export interface Spec extends TurboModule {
  methodModifier(a: number, b: number): Promise<number>;
  signInWithApple(): Promise<object>;
  configureSignin(configObject: Object): Promise<void>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('Modifier');

export interface AppleButtonProps {
  style: ViewStyle;
}

export const AppleSigninButton = requireNativeComponent(
  'AppleSigninButton'
) as unknown as React.FC<AppleButtonProps>;
