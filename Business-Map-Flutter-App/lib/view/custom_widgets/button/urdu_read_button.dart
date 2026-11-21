import 'package:business_map/provider/tts/tts_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UrduReadButton extends StatelessWidget {
  final String text;
  final String? title;
  final String sectionId;

  const UrduReadButton({
    super.key,
    required this.text,
    required this.sectionId,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TTSProvider>(
      builder: (context, ttsProvider, child) {
        final isPlaying = ttsProvider.currentlyPlayingId == sectionId;
        final isLoading = ttsProvider.isLoading && isPlaying;

        return GestureDetector(
          onTap: () {
            final fullText = title != null ? "$title. $text" : text;
            ttsProvider.speakInUrdu(fullText, sectionId);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isPlaying ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPlaying ? Colors.green.withOpacity(0.3) : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.green)),
                  )
                else
                  Icon(
                    isPlaying ? Icons.stop_circle_rounded : Icons.translate_rounded,
                    size: 16,
                    color: isPlaying ? Colors.green : Colors.grey[700],
                  ),
                const SizedBox(width: 6),
                Text(
                  isPlaying ? "Stop" : "Read in Urdu",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isPlaying ? Colors.green : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
