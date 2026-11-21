import 'dart:io';
import 'package:business_map/core/routes/route_args.dart';
import 'package:business_map/data/model/response/location_suggestion_response.dart';
import 'package:business_map/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class ARFeatureScreen extends StatefulWidget {
  const ARFeatureScreen({super.key});

  @override
  State<ARFeatureScreen> createState() => _ARFeatureScreenState();
}

class _ARFeatureScreenState extends State<ARFeatureScreen> {
  WebViewController? _controller;
  bool _webViewReady = false;

  HttpServer? _assetServer;
  int? _serverPort;

  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _downloadError;
  String? _localGlbPath;

  @override
  void dispose() {
    _assetServer?.close(force: true);
    super.dispose();
  }

  Future<void> _startAssetServer(String glbPath) async {
    _assetServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _serverPort = _assetServer!.port;

    final htmlBytes = await DefaultAssetBundle.of(
      context,
    ).load('assets/ar_map.html');
    final htmlString = String.fromCharCodes(htmlBytes.buffer.asUint8List());

    _assetServer!.listen((req) async {
      if (req.uri.path == '/ar_map.html' || req.uri.path == '/') {
        req.response
          ..headers.set('Content-Type', 'text/html; charset=utf-8')
          ..write(htmlString);
        await req.response.close();
      } else if (req.uri.path == '/model.glb') {
        final file = File(glbPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          req.response
            ..headers.set('Content-Type', 'model/gltf-binary')
            ..headers.set('Access-Control-Allow-Origin', '*')
            ..headers.set('Content-Length', bytes.length.toString())
            ..add(bytes);
          await req.response.close();
        } else {
          req.response.statusCode = 404;
          await req.response.close();
        }
      } else {
        req.response.statusCode = 404;
        await req.response.close();
      }
    });
  }

  Future<void> _init(TopLocation loc) async {
    if (_isDownloading || _controller != null) return;
    setState(() => _isDownloading = true);

    try {
      final dir = await getTemporaryDirectory();
      final glbPath = '${dir.path}/ar_${loc.id}.glb';

      if (!await File(glbPath).exists()) {
        await Dio().download(
          (loc.arConfig.externalUrl.isEmpty)
              ? loc.arConfig.internalUrl
              : loc.arConfig.externalUrl,
          glbPath,
          onReceiveProgress: (r, t) {
            if (t > 0 && mounted) {
              setState(() => _downloadProgress = r / t);
            }
          },
        );
      }
      _localGlbPath = glbPath;

      await _startAssetServer(glbPath);

      final googleMapsApiKey = AppConfigs.googleMapsApiKey;
      final modelUrl = Uri.encodeComponent(
        'http://127.0.0.1:$_serverPort/model.glb',
      );
      final locName = Uri.encodeComponent(loc.locationName);
      final url =
          'http://127.0.0.1:$_serverPort/ar_map.html'
          '?lat=${loc.coordinates.lat}'
          '&lng=${loc.coordinates.lng}'
          '&model=$modelUrl'
          '&key=$googleMapsApiKey'
          '&name=$locName';

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..loadRequest(Uri.parse(url));

      if (mounted) {
        setState(() {
          _controller = controller;
          _isDownloading = false;
          _webViewReady = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadError = e.toString();
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = RouteArgs.of<TopLocation>(context);
    if (loc == null) {
      return const Scaffold(
        body: Center(child: Text('Invalid or missing location data.')),
      );
    }

    if (_controller == null && !_isDownloading && _downloadError == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _init(loc));
    }

    return Scaffold(
      body: Stack(
        children: [
          if (_webViewReady && _controller != null)
            Positioned.fill(child: WebViewWidget(controller: _controller!)),

          if (_isDownloading)
            Container(
              color: Colors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: _downloadProgress > 0 ? _downloadProgress : null,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Preparing AR view… "
                        "${(_downloadProgress * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_downloadError != null)
            Container(
              color: Colors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    "Failed to load: $_downloadError",
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
