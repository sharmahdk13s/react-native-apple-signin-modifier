import { useCallback, useEffect, useState } from 'react';
import {
  NativeEventEmitter,
  NativeModules,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import {
  methodModifier,
  signInWithApple,
  configureAndroidAppleAuth,
  AppleSigninButton,
} from 'react-native-modifier';
const { CustomEventEmitter } = NativeModules;
const eventEmitter = new NativeEventEmitter(CustomEventEmitter);

export default function App() {
  const [number, setNumber] = useState(0);

  async function calculate() {
    const result = await methodModifier(5, 2);
    setNumber(result);
  }

  const onAppleSigning = useCallback(async () => {
    try {
      if (Platform.OS == 'android') {
        await configureAndroidAppleAuth({
          // The Service ID you registered with Apple
          clientId: '{your Apple service Id}',
          // Return URL added to your Apple dev console. We intercept this redirect, but it must still match
          // the URL you provided to Apple. It can be an empty route on your backend as it's never called.
          redirectUri: '{your app service call back url}',
        });
      }

      let result = await signInWithApple();
      console.log('result....', result);
    } catch (error) {
      console.log('error....', error);
    }
  }, []);

  useEffect(() => {
    calculate();
    eventEmitter.addListener('onSigninComplete', (event) => {
      console.log('Event Success received from Swift:', event);
    });
    eventEmitter.addListener('onSigninFail', (event) => {
      console.log('Event Error received from Swift:', event);
    });

    return () => {
      eventEmitter.removeAllListeners('onSigninComplete');
      eventEmitter.removeAllListeners('onSigninFail');
    };
  }, []);

  return (
    <View>
      <Pressable style={styles.container} onPress={onAppleSigning}>
        <Text>Apple Signing: {number}</Text>
      </Pressable>
      {Platform.OS == 'ios' && (
        <AppleSigninButton style={styles.appleButtonStyle} />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginTop: 200,
    width: 300,
    height: 50,
    alignSelf: 'center',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 5,
    borderWidth: 2,
    borderColor: 'red',
  },
  appleButtonStyle: {
    marginTop: 100,
    width: 300,
    height: 50,
    alignSelf: 'center',
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
