const Modifier = require('./NativeModifier').default;

export function methodModifier(a: number, b: number): Promise<number> {
  return Modifier.methodModifier(a, b);
}
export function signInWithApple(): Promise<object> {
  return Modifier.signInWithApple();
}
export function configureAndroidAppleAuth(
  configuration: Object
): Promise<void> {
  return Modifier.configureSignin(configuration);
}
export { AppleSigninButton } from './NativeModifier';
