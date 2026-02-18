import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Thêm import cho PlatformWebViewControllerCreationParams
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';


class WebViewScreen extends StatefulWidget {
  final String initialUrl;
  final String title;

  const WebViewScreen({
    super.key,
    required this.initialUrl,
    this.title = "Thanh toán",
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // --- BẮT ĐẦU SỬA ĐỔI ---
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            debugPrint('Page finished loading: $url');

            if (url.contains('vnp_ResponseCode=00')) {
              debugPrint('WebView: Giao dịch VNPay thành công!');
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) Navigator.of(context).pop('success');
              });
            } else if (url.contains('vnp_ResponseCode') && !url.contains('vnp_ResponseCode=00')) {
              debugPrint('WebView: Giao dịch VNPay thất bại hoặc bị hủy.');
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) Navigator.of(context).pop('failed');
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));

    // Thêm các cài đặt bổ sung cho Android
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
    // --- KẾT THÚC SỬA ĐỔI ---
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            ),
        ],
      ),
    );
  }
}