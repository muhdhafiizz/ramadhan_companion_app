import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/qibla_finder_provider.dart';
import 'package:ramadhan_companion_app/widgets/shimmer_loading.dart';

class QiblaCompassView extends StatelessWidget {
  final String city;
  final String country;

  const QiblaCompassView({
    super.key,
    required this.city,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: ChangeNotifierProvider(
                  create: (_) => QiblaProvider()..fetchQibla(city, country),
                  child: Consumer<QiblaProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return Center(child: _buildShimmerLoading());
                      }
                      if (provider.error != null) {
                        return Center(child: Text("Error: ${provider.error}"));
                      }
                      if (provider.qiblaBearing == null) {
                        return const Center(child: Text("No Qibla data"));
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBlendColor(provider),
                          const SizedBox(height: 20),
                          _buildDeviceHeadingText(provider),
                          _buildQiblaHeadingText(provider),
                          const SizedBox(height: 40),
                          _buildCompass(provider),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildAppBar(BuildContext context) {
  return Row(
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
      const SizedBox(width: 10),
      const Text(
        "Qibla Finder",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    ],
  );
}

Widget _buildBlendColor(QiblaProvider provider) {
  return ColorFiltered(
    colorFilter: provider.isAligned
        ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
        : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
    child: Image.asset("assets/icon/kaaba_icon.png", width: 100, height: 100),
  );
}

Widget _buildDeviceHeadingText(QiblaProvider provider) {
  return Text(
    "${(provider.deviceHeading ?? 0).toStringAsFixed(2)}°",
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
  );
}

Widget _buildQiblaHeadingText(QiblaProvider provider) {
  return Text(
    "Qibla: ${provider.qiblaBearing!.toStringAsFixed(2)}°",
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  );
}

Widget _buildCompass(QiblaProvider provider) {
  return SizedBox(
    width: 250,
    height: 250,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400, width: 3),
          ),
        ),

        Transform.rotate(
          angle:
              ((provider.qiblaBearing ?? 0) - (provider.deviceHeading ?? 0)) *
              (3.14159 / 180),
          child: Icon(Icons.navigation, size: 100, color: Colors.green),
        ),
      ],
    ),
  );
}

Widget _buildShimmerLoading() {
  return Column(
    children: [
      ShimmerLoadingWidget(width: 50, height: 50, isCircle: false,),
      const SizedBox(height: 20),
      ShimmerLoadingWidget(width: 50, height: 100, isCircle: false,),
      ShimmerLoadingWidget(width: 80, height: 50, isCircle: false,),
      const SizedBox(height: 40),
      ShimmerLoadingWidget(width: 100, height: 100, isCircle: false,),
    ],
  );
}
