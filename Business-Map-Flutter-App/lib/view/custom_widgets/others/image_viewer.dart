import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/others/app_network_image.dart';
import 'package:flutter/material.dart';

class ImageViewer {
  static void show(BuildContext context, String imageUrl) {
    var width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black.withOpacity(0.8),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            
            SizedBox(
              width: width * 0.9,
              height: width * 0.9,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SizeConfig.radius(15)),
                  child: AppNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
