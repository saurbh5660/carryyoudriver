import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeConnectScreen extends StatefulWidget {
  final String url;

  const StripeConnectScreen({super.key, required this.url});

  @override
  State<StripeConnectScreen> createState() => _StripeConnectScreenState();
}

class _StripeConnectScreenState extends State<StripeConnectScreen> {

  late final WebViewController controller;

  final String returnUrl = "http://52.66.122.106:4005/users/stripeConnectUrl"; // same as backend

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.startsWith(returnUrl)) {
              Get.back(); // close stripe page
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stripe Connect")),
      body: WebViewWidget(controller: controller),
    );
  }
}