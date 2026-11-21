import 'package:flutter/material.dart';

/// Compact top strip shown while the device has no internet access.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF424242),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "You're offline. Some features may not work until you reconnect.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
