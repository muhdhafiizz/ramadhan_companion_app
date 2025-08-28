import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/quran_detail_provider.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';

class AudioPillWidget extends StatelessWidget {
  const AudioPillWidget({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranDetailProvider>();

    if (provider.duration == Duration.zero && !provider.isPlaying) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.violet.withOpacity(1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              provider.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              if (provider.playingVerse != null) {
                if (provider.isPlaying) {
                  provider.pauseVerseAudio();
                } else {
                  provider.playAudioVerse(verse: provider.playingVerse!);
                }
              } else {
                if (provider.isPlaying) {
                  provider.pauseAudio();
                } else {
                  provider.playAudio();
                }
              }
            },
          ),

          Text(
            "${_formatDuration(provider.position)} / ${_formatDuration(provider.duration)}",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            provider.reciter.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
