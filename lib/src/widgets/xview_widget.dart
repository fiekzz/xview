import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xview_flutter/xview_flutter.dart';

class XViewWidget extends StatefulWidget {
  const XViewWidget({
    super.key,
    this.initialUrl,
    this.controller,
    this.onWebViewCreated,
    this.onPageStarted,
    this.onPageFinished,
    this.onNavigationRequest,
    this.onError,
    this.backgroundColor,
    required this.showLoadingIndicator,
    this.loadingWidget,
  });

  final String? initialUrl;
  final XViewController? controller;
  final Function(XViewController)? onWebViewCreated;
  final Function(String)? onPageStarted;
  final Function(String)? onPageFinished;
  final Function(String)? onNavigationRequest;
  final Function(String)? onError;
  final Color? backgroundColor;
  final bool showLoadingIndicator;
  final Widget? loadingWidget;

  @override
  State<XViewWidget> createState() => _XViewWidgetState();
}

class _XViewWidgetState extends State<XViewWidget> {
  late XViewController _controller;

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),

        // Loading indicator
        if (widget.showLoadingIndicator)
          ValueListenableBuilder<bool>(
            valueListenable: _LoadingNotifier(_controller),
            builder: (context, isLoading, child) {
              if (!isLoading) return const SizedBox.shrink();

              return widget.loadingWidget ??
                  Container(
                    color: widget.backgroundColor ??
                        Colors.white.withValues(alpha: 0.8),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
            },
          ),
      ],
    );
  }
}

/// Helper class to create a ValueNotifier for loading state
class _LoadingNotifier extends ValueNotifier<bool> {
  final XViewController controller;

  _LoadingNotifier(this.controller) : super(controller.isLoading) {
    // Listen to loading state changes
    _startListening();
  }

  void _startListening() {
    // This is a simplified approach - in a real implementation,
    // you'd want to properly listen to the controller's loading state
    // For now, we'll update based on navigation events
  }
}
