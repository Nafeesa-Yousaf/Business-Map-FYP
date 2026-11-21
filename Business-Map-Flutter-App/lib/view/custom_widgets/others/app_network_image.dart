import 'package:business_map/utils/media_url.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// [CachedNetworkImage] that resolves relative media-proxy URLs and attaches
/// Vercel protection bypass headers when needed.
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = MediaUrl.resolve(imageUrl);
    if (resolved.isEmpty) {
      return errorWidget?.call(context, imageUrl, Exception('empty url')) ??
          const SizedBox.shrink();
    }

    return CachedNetworkImage(
      imageUrl: resolved,
      fit: fit,
      width: width,
      height: height,
      httpHeaders: MediaUrl.headersFor(resolved),
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
