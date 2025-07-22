import 'package:webview_flutter/webview_flutter.dart';

class XViewAPI {
  String apiName;
  Function(JavaScriptMessage) completion;

  XViewAPI({
    required this.apiName,
    required this.completion,
  });
}
