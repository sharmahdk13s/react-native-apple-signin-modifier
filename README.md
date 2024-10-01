# react-native-modifier

React-Native custom package modifier,
React-Native custom library which provides short discovery about how to integrate Turbo modules using react-native code with iOS and Android native code.

## Installation

```sh
yarn install

**For run example workspace directly:**
yarn example android
yarn example ios

**For Android example run:**
yarn android

**For iOS example run:**
cd ios
pod install
cd ..
yarn ios
```

## **For iOS manually swift file linking**
- After done **pod install**.
- Open example -> ios -> ModifierExample.xcworkspace file.
- Expand **Pods** xcode project at left side panel in Xcode.
- Expand **Development Pods** folder, scroll down and exapand **react-native-modifier** library pod files.
- Now drag and drop all .swift files **AppleSignin.swift, AppleSigninButtonManager.swift, AppleSignInManager.swift, CustomEventEmitter.swift and ModifierMultiply.swift** in that folder (react-native-modifier).
- Click on **Create Bridging header file** blue button from the popup after drag and drop swift files.
- Now you can build (cmd+B) and run the project successfully.

## Usage


```js
import { NativeModules } from 'react-native';
import { multiply } from 'react-native-modifier';
**OR**
import { methodModifier, signInWithApple, configureAndroidAppleAuth, AppleSigninButton } from 'react-native-modifier';
// ...

const result = multiply(3, 7);

// Configure and run Apple signin and get the signin response
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

  **Apple signin failure or success response from native iOS side using event listener**
  const { CustomEventEmitter } = NativeModules;
  const eventEmitter = new NativeEventEmitter(CustomEventEmitter);

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

  // Render AppleSigninButton UI directly from native iOS swift code
 {Platform.OS == 'ios' && (<AppleSigninButton style={styles.appleButtonStyle} />)}
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
