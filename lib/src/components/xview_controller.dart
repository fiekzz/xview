import 'package:crypt/crypt.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xview_flutter/src/components/xview_page_control_enum.dart';
import 'package:xview_flutter/xview_flutter.dart';

class XViewController extends WebViewController {
  // Custom Callbacks
  Function(String)? onPageStarted;
  Function(String)? onPageFinished;
  Function(String)? onWebResourceError;
  Function(String)? onNavigationRequest;
  Function(int)? onProgress;
  Widget? loadingWidget;

  // Custom State
  String? _currentTheme;
  final Map<String, String> _customHeaders = {};
  final List<XViewNavigationHistory> _navigationHistory = [];
  bool _isLoading = false;
  String? _lastError;
  final Map<String, dynamic> _userPreferences = {};

  // XViewAPI state
  final List<XViewAPI> _xviewapiList = [];

  // XViewScript state
  final Map<String, String> _xviewscriptmap = {};

  // Constructor
  XViewController({
    this.onPageStarted,
    this.onPageFinished,
    this.onWebResourceError,
    this.onNavigationRequest,
    this.onProgress,
  }) : super() {
    _initializeController();
  }

  // Initialize the controller with custom settings
  void _initializeController() {
    // Set up navigation delegate
    setNavigationDelegate(NavigationDelegate(
      onPageStarted: (String url) {
        _isLoading = true;
        _addToHistory(url);
        onPageStarted?.call(url);
      },
      onPageFinished: (String url) {
        _isLoading = false;
        onPageFinished?.call(url);
      },
      onNavigationRequest: (NavigationRequest request) {
        onNavigationRequest?.call(request.url);
        return NavigationDecision.navigate;
      },
      onWebResourceError: (WebResourceError error) {
        _lastError = error.description;
        onWebResourceError?.call(error.description);
      },
    ));

    // Enable JavaScript by default
    setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  // Custom Getters
  String? get currentTheme => _currentTheme;
  Map<String, String> get customHeaders => Map.unmodifiable(_customHeaders);
  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  Map<String, dynamic> get userPreferences =>
      Map.unmodifiable(_userPreferences);
  List<XViewAPI> get xviewapiList => List.unmodifiable(_xviewapiList);
  Map<String, String> get xviewjsscript => Map.unmodifiable(_xviewscriptmap);
  int get historyCount => _navigationHistory.length;

  /// Check if can go back in custom history
  bool get canGoBackInHistory => _navigationHistory.length > 1;

  // Add custom headers for requests
  void addCustomHeader(String key, String value) {
    _customHeaders[key] = value;
    // Apply headers to future requests
    setUserAgent('$value; ${_customHeaders.toString()}');
  }

  // Remove a custom header
  void removeCustomHeader(String key) {
    _customHeaders.remove(key);
  }

  // Clear all custom headers
  void clearCustomHeaders() {
    _customHeaders.clear();
  }

  // Append new headers with the custom headers
  // Load url with headers
  Future<void> loadUrlWithHeaders(
    String url, {
    Map<String, String>? headers,
  }) async {
    final combinedHeaders = <String, String>{
      ...customHeaders,
      if (headers != null) ...headers,
    };

    await loadRequest(Uri.parse(url), headers: combinedHeaders);
  }

  // Clear navigation history
  void clearHistory() {
    _navigationHistory.clear();
  }

  // Add URL to navigation history
  void _addToHistory(String url) {
    // Generate hash from url
    final urlHash = _urlHashGenerator(url);
    // Comparing the hash for the url
    if (_navigationHistory.isEmpty || _navigationHistory.last.hash != urlHash) {
      _navigationHistory.add(XViewNavigationHistory(hash: urlHash, url: url));

      if (_navigationHistory.length > 50) {
        _navigationHistory.removeAt(0);
      }
    }
  }

  // Generate hash based on the url
  String _urlHashGenerator(String url) {
    final hash = Crypt.sha256(url);
    return hash.toString();
  }

  // Clear all data within the xview controller
  Future<void> clearAllData() async {
    await clearLocalStorage();
    await clearCache();
    _userPreferences.clear();
    _lastError = null;
  }

  // add xview api
  // upon call from the website, the js script channel will trigger automatically
  void addXViewAPI(String apiName, Function(JavaScriptMessage) completion) {
    if (_xviewapiList.any((api) => api.apiName == apiName)) {
      removeXViewAPI(apiName);
    }

    _xviewapiList.add(XViewAPI(apiName: apiName, completion: completion));
    addJavaScriptChannel(apiName, onMessageReceived: completion);
  }

  // clear xview api
  void clearXViewAPI() {
    for (final xviewapi in _xviewapiList) {
      removeJavaScriptChannel(xviewapi.apiName);
    }
    _xviewapiList.clear();
  }

  // remove xview api
  void removeXViewAPI(String apiName) {
    removeJavaScriptChannel(apiName);
    _xviewapiList.removeWhere((api) => api.apiName == apiName);
  }

  // add custom javascript / typescript
  // preferbly typescript
  void addCustomScript(
    String scriptName,
    String scriptCode,
  ) {
    _xviewscriptmap[scriptName] = scriptCode;
  }

  // remove custom script
  void removeCustomScript(String scriptName) {
    _xviewscriptmap.remove(scriptName);
  }

  // clear custom script
  void clearCustomScript() {
    _xviewscriptmap.clear();
  }

  // Execute custom script from the added resources
  Future<Object?> executeCustomScript(String scriptName) async {
    try {
      final script = _xviewscriptmap[scriptName];
      if (script == null) {
        throw "must add script first before execute";
      }
      final result = await runJavaScriptReturningResult(script);
      return result;
    } catch (e) {
      _lastError = e.toString();
      return null;
    }
  }

  Future<dynamic> executeRawScript(String rawScript) async {
    try {
      return await runJavaScriptReturningResult(rawScript);
    } catch (e) {
      _lastError = e.toString();
      return null;
    }
  }

  Future<String?> getPageTitle() async {
    return await executeRawScript(XViewPageControlEnum.title.script);
  }

  Future<String?> getCurrentUrl() async {
    return await executeRawScript(XViewPageControlEnum.currenturl.script);
  }

  Future<void> scrollToTop() async {
    await runJavaScript(XViewPageControlEnum.scrollToTop.script);
  }

  Future<void> scrollToBottom() async {
    await runJavaScript(XViewPageControlEnum.scrollToBottom.script);
  }

  Future<bool> setUserPreference(String key, dynamic value) async {
    _userPreferences[key] = value;
    final script =
        XViewPageControlEnum.setLocalStorage.scriptLocalStorage(key, value);
    if (script.isNotEmpty) {
      await runJavaScript(script);
      return true;
    }
    return false;
  }

  Future<void> goBackInHistory() async {
    if (canGoBackInHistory) {
      _navigationHistory.removeLast();
      final previousPage = _navigationHistory.last;
      await loadRequest(Uri.parse(previousPage.url));
    }
  }

  Future<bool> setZoomEnabled(bool enabled) async {
    final script = XViewPageControlEnum.setZoomEnabled.setZoomEnabled(enabled);
    if (script.isNotEmpty) {
      await runJavaScript(script);
      return true;
    }
    return false;
  }

  /// Set a custom theme for the webview
  void setTheme(String theme) {
    _currentTheme = theme;
    // Inject CSS for theme
    runJavaScript('''
      document.documentElement.setAttribute('data-theme', '$theme');
      if (!document.getElementById('mate-theme-style')) {
        var style = document.createElement('style');
        style.id = 'mate-theme-style';
        style.innerHTML = `
          [data-theme="dark"] { 
            filter: invert(1) hue-rotate(180deg); 
          }
        `;
        document.head.appendChild(style);
      }
    ''');
  }
}
