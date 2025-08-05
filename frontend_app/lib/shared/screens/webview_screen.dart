import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String initialUrl;
  final String title;

  const WebViewScreen({
    super.key,
    required this.initialUrl,
    this.title = "Thanh toán", // Tiêu đề mặc định
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

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Cập nhật thanh loading
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            debugPrint('WebView: Trang bắt đầu tải: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            debugPrint('WebView: Trang tải xong: $url');

            // KIỂM TRA URL TRẢ VỀ TỪ VNPAY
            // Đây là phần quan trọng để tự động đóng WebView
            if (url.contains('vnp_ResponseCode=00')) {
              // Giao dịch thành công
              debugPrint('WebView: Giao dịch VNPay thành công!');
              // Chờ 2 giây để người dùng đọc thông báo rồi tự động đóng
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.of(context).pop('success'); // Trả về 'success'
                }
              });
            } else if (url.contains('vnp_ResponseCode') && url.contains('vnp_ResponseCode=00') == false) {
              // Giao dịch thất bại hoặc bị hủy
              debugPrint('WebView: Giao dịch VNPay thất bại hoặc bị hủy.');
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.of(context).pop('failed'); // Trả về 'failed'
                }
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
              child: CircularProgressIndicator(
                color: Colors.deepOrange,
              ),
            ),
        ],
      ),
    );
  }
}