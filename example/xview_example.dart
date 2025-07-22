import 'package:flutter/material.dart';
import 'package:xview/src/widgets/xview_widget.dart';
import 'package:xview/xview.dart';

void main() {
  runApp(XViewAppTest(
    currentUrl: 'https://flutter.dev',
  ));
}

class XViewAppTest extends StatelessWidget {
  const XViewAppTest({
    super.key,
    required this.currentUrl,
  });

  final String currentUrl;

  @override
  Widget build(BuildContext context) {
    return XViewExample(currentUrl: currentUrl);
  }
}

class XViewExample extends StatefulWidget {
  const XViewExample({
    super.key,
    required this.currentUrl,
  });

  final String currentUrl;

  @override
  State<XViewExample> createState() => _XViewExampleState();
}

class _XViewExampleState extends State<XViewExample> {
  late XViewController xviewController;

  String _currentUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('XView Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.dark_mode),
            onPressed: () => xviewController.setTheme('dark'),
          ),
          IconButton(
            icon: Icon(Icons.light_mode),
            onPressed: () => xviewController.setTheme('light'),
          ),
          // IconButton(
          //   icon: Icon(Icons.screenshot),
          //   onPressed: _takeScreenshot,
          // ),
        ],
      ),
      body: Column(
        children: [
          // URL display
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              'Current URL: $_currentUrl',
              style: TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => xviewController.scrollToTop(),
                child: Text('Top'),
              ),
              ElevatedButton(
                onPressed: () => xviewController.scrollToBottom(),
                child: Text('Bottom'),
              ),
              // ElevatedButton(
              //   onPressed: _injectCustomCSS,
              //   child: Text('CSS'),
              // ),
              ElevatedButton(
                onPressed: _addCustomHeaders,
                child: Text('Headers'),
              ),
            ],
          ),

          // WebView
          Expanded(
            child: XViewWidget(
              initialUrl: widget.currentUrl,
              onWebViewCreated: (controller) {
                xviewController = controller;

                // Set up custom headers
                controller.addCustomHeader('X-Custom-App', 'XView');

                // Set user preferences
                controller.setUserPreference('theme', 'light');
                controller.setUserPreference('zoom', 1.0);
              },
              onPageStarted: (String url) {
                setState(() {
                  _currentUrl = url;
                });
                debugPrint('Page started loading: $url');
              },
              onPageFinished: (String url) {
                setState(() {
                  _currentUrl = url;
                });
                debugPrint('Page finished loading: $url');

                // Auto-inject some custom functionality
                // xviewController.addJavaScriptInterface('xviewAlert',
                //     'function(message) { alert("XView: " + message); }');
              },
              onError: (String error) {
                debugPrint('WebView error: $error');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
              },
              showLoadingIndicator: true,
              backgroundColor: Colors.grey[100],
            ),
          ),

          // Bottom controls
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => xviewController.goBack(),
                  child: Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () => xviewController.goForward(),
                  child: Text('Forward'),
                ),
                ElevatedButton(
                  onPressed: () => xviewController.reload(),
                  child: Text('Reload'),
                ),
                ElevatedButton(
                  onPressed: _showHistory,
                  child: Text('History (${xviewController.historyCount})'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // void _takeScreenshot() async {
  //   final screenshot = await xviewController.takeScreenshot();
  //   if (screenshot != null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Screenshot taken!')),
  //     );
  //   }
  // }

  // void _injectCustomCSS() {
  //   xviewController.injectCSS('''
  //     body {
  //       background: linear-gradient(45deg, #ff6b6b, #4ecdc4) !important;
  //       color: white !important;
  //     }
  //     a { color: yellow !important; }
  //   ''');
  // }

  void _addCustomHeaders() {
    xviewController.addCustomHeader('X-Device-Type', 'Mobile');
    xviewController.addCustomHeader('X-App-Version', '1.0.0');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Custom headers added')),
    );
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Navigation History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: xviewController.navigationHistory.length,
            itemBuilder: (context, index) {
              final url = xviewController.navigationHistory[index];
              return ListTile(
                dense: true,
                title: Text(
                  url,
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                leading: Text('${index + 1}'),
                onTap: () {
                  xviewController.loadRequest(Uri.parse(url));
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              xviewController.clearHistory();
              Navigator.pop(context);
            },
            child: Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
