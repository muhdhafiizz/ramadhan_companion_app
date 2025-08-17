import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/qibla_finder_provider.dart';

class QiblaCompassScreen extends StatelessWidget {
  final String city;
  final String country;

  const QiblaCompassScreen({
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
              ChangeNotifierProvider(
                create: (_) => QiblaProvider()..fetchQibla(city, country),
                child: Consumer<QiblaProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.error != null) {
                      return Center(child: Text("Error: ${provider.error}"));
                    }
                    if (provider.bearing == null) {
                      return const Center(child: Text("No Qibla data"));
                    }

                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${provider.bearing!.toStringAsFixed(2)}°",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Image.asset("assets/icon/kaaba_icon.png", width: 100, height: 100,),
                          Transform.rotate(
                            angle: provider.bearing! * (3.14159 / 180),
                            child: Icon(
                              Icons.navigation,
                              size: 150,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
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
        "Qibla Finder",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    ],
  );
}
