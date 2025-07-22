<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

## XViewFlutter

XViewFlutter is a custom webview for the flutter developers to have dynamic webview page which uses the core of `flutter_webview` package from flutter. The mission for this project is to have the advantage of webview and implement within the flutter package. This includes the custom page handling, routes, dynamic design, and fast delivery.

Not only that, those that has experience in web development can work together with existing flutter developers creating wonderful and feature rich applications. The vision for this project is to create an environment that will be less hassle and reduce time taken for MVP and maintenance in the future.

**Important Note**
- By adding XView to your application, it is important to note that XView only support for HTML5 and at least flutter version >3 for smooth operation.

## Getting started

<h6>Adding direct into pubspec.yml</h6>
To get started with the XViewFlutter, we need to add package dependency into the `pubspec.yml` file.

```dart
xview_flutter: ^0.0.1
```

And run

```bash
flutter pub get
```
<h6>Using pub get</h6>

```bash
flutter pub get xview_flutter
```

**Typescript**

Add this into your `app.d.ts` file for easy API execution.
```typescript
declare global {
	namespace App {
		// Other code
	}
	// Other code
	interface Window {
		XViewAPI: {
			createMessage: (message: string) => void;
		}
	}
	// Other code
}
export {};
```

**Flutter**

Declare controller
```dart
late XViewController controller;
```

Initialize controller
```dart
@override
void initState() {
    super.initState();
    initializeController();
}

void initializeController() {
    // Use provided controller or create new one
    _controller = widget.controller ??
        XViewController(
            onPageStarted: widget.onPageStarted,
            onPageFinished: widget.onPageFinished,
            onNavigationRequest: widget.onNavigationRequest,
            onWebResourceError: widget.onError,
        );

    // Load initial URL if provided
    if (widget.initialUrl != null) {
        _controller.loadRequest(Uri.parse(widget.initialUrl!));
    }

    // Notify parent that WebView is created
    widget.onWebViewCreated?.call(_controller);
}
```

## Core Features


### XViewAPI
XViewAPI is a bridge for the javascript and typescript to call and invoke flutter code execution. The XViewAPI will call flutter native code using XViewAPI and flutter side can continue the native code execution. This include the execution for biometric (faceid and fingerprint), file management, and more that will be easier to setup and handle in native side.

<h5>Getting started with XViewAPI</h5>

To get started with XViewAPI, you can just directly add the javascript api by following this dart code below.
```dart
// message: JavaScriptMessage
controller.addXViewAPI('YourAPIName', (message) {
    try {

        final data = jsonDecode(message.message)
        // continue with your action

    } catch (e) {
        debugPrint(e.toString())
    }
})
```

After add the api, your api will be ready to be invoked from HTML5 javascript. Typescript code below is one of the function example that can be put into button to be called. This is just an example, you are free to continue with your usecase.
```typescript
function callFlutterBridge(action: string, payload: string) {
    if (window.FlutterBridge?.postMessage) {
        window.FlutterBridge.postMessage(
            JSON.stringify({
                action: action,
                params: payload
            })
        );
    }
}
```

Furthermore, it is also possible to remove the existing custom script according to your needs. This will result in invalid code execution from frontent HTML5 as the native side is null.
```dart
controller.removeXViewAPI('YourAPIName')
```

To remove all the existing api, you can clear the api by calling `clear()` method.
```dart
controller.clearXViewAPI()
```

### XViewCustomScript
XViewCustomScript is the custom javascript / typescript code execution that can be execution from flutter side. This can be used to directly manipulate the content or design within the frontend HTML5.

<h5>Getting started with XViewCustomScript</h5>

To get started with the XViewCustomScript, use `addCustomScript` api that will need `scriptName` (String) and `scriptCode` (String) as parameter. The name is being used to track the code execution which can be invoked multiple times.

```dart
controller.addCustomScript('YourScriptName', 'console.log("Calling from HTML5!")')
```

The script will not be invoked directly after added. Instead, it will be kept first to be called later.

To call the added script, we can call the `executeCustomScript` api and provide the name that we have put earlier.
```dart
controller.executeCustomScript('YourScriptName')
```

Just as the `XViewAPI` earlier, it is also possible to remove and clear the added script.

Remove certain script
```dart
controller.removeCustomScript('YourScriptName')
```

Clear all scripts
```dart
controller.clearCustomScript()
```

### XViewRawScript
However, if you would like to self handle or customize to your needs, it is possible to execute raw script using this api.
```dart
controller.executeRawScript('console.log("Calling from HTML5!")')
```

### Non-essential API
<h6>Get current page title</h6>

```dart
final pageTitle = controller.getPageTitle(); // String?
```

<h6>Get current page URL</h6>

```dart
final pageUrl = controller.getCurrentUrl(); // String?
```

<h6>Scroll to top of webview page</h6>

```dart
controller.scrollToTop();
```

<h6>Scroll to top of webview page</h6>

```dart
controller.scrollToBottom();
```

## Future improvements
- XViewWrapper (webview npm library)
- Static webview page (server and local)
- Dynamic webview page

## License
The MIT License (MIT)

Copyright (c) <year> fiekzz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.