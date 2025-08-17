import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/masjid_nearby_provider.dart';
import 'package:ramadhan_companion_app/secrets/api_keys.dart';
import 'package:ramadhan_companion_app/widgets/shimmer_loading.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:math';

import 'package:url_launcher/url_launcher.dart';

class MasjidNearbyScreen extends StatelessWidget {
  final String city;
  final String country;

  const MasjidNearbyScreen({
    super.key,
    required this.city,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MasjidNearbyProvider>();

    if (!provider.isLoading &&
        (provider.masjids.isEmpty ||
            provider.originCity != city ||
            provider.originCountry != country)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.fetchMasjidsFromAddress(city, country);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildAppBar(context),
              const SizedBox(height: 10),
              provider.isLoading
                  ? Expanded(child: Center(child: _buildShimmerLoading()))
                  : provider.errorMessage != null
                  ? Expanded(child: Center(child: Text(provider.errorMessage!)))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: provider.masjids.length,
                        itemBuilder: (context, index) {
                          final masjid = provider.masjids[index];
                          final distance = provider.calculateDistance(
                            provider.originLat!,
                            provider.originLng!,
                            masjid.latitude,
                            masjid.longitude,
                          );
                          return _buildMasjidCard(
                            context: context,
                            name: masjid.name,
                            photoReference: masjid.photoReference,
                            distanceKm: distance,
                            ratings: masjid.rating ?? 0,
                            latitude: masjid.latitude,
                            longitude: masjid.longitude,
                            provider: provider
                          );
                        },
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
        child: Icon(Icons.arrow_back),
      ),
      SizedBox(width: 10),
      Text(
        "Nearby Masjid",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    ],
  );
}

Widget _buildShimmerLoading() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ShimmerLoadingWidget(width: double.infinity, height: 220),
      SizedBox(height: 10),
      ShimmerLoadingWidget(width: 150, height: 20),
      SizedBox(height: 5),
      ShimmerLoadingWidget(width: 100, height: 20),
    ],
  );
}

Widget _buildMasjidCard({
  required BuildContext context,
  required String name,
  required List<String> photoReference,
  required double distanceKm,
  required double ratings,
  required double latitude,
  required double longitude,
  required MasjidNearbyProvider provider
}) {
  final pageController = PageController();

  return Padding(
    padding: const EdgeInsets.only(bottom: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (photoReference.isNotEmpty)
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: photoReference.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        "https://maps.googleapis.com/maps/api/place/photo"
                        "?maxwidth=1000"
                        "&photoreference=${photoReference[index]}"
                        "&key=${ApiKeys.masjidNearbyKey}",
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: pageController,
                      count: photoReference.length,
                      effect: const WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: Colors.white,
                        dotColor: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/icon/app_icon.jpg',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "${distanceKm.toStringAsFixed(2)} km away",
                  style: const TextStyle(color: Colors.grey),
                ),
                Row(
                  children: [
                    Text(ratings.toString()),
                    SizedBox(width: 5),
                    Image.asset(
                      'assets/icon/star_icon.png',
                      height: 13,
                      width: 13,
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                _showNavigationOptions(context, name, latitude, longitude, provider);
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.share, color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void _showNavigationOptions(
  BuildContext context,
  String name,
  double lat,
  double lng,
  MasjidNearbyProvider provider,
) {
  if (Platform.isIOS) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text(name),
        message: const Text('Open location in maps'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await provider.openMap(lat, lng);
            },
            child: const Text('Open in Maps'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                title: const Text("Open in Google Maps / Waze"),
                onTap: () async {
                  Navigator.pop(context);
                  await provider.openMap(lat, lng);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}