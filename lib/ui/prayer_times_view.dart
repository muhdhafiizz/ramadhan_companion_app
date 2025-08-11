import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/location_input_provider.dart';
import 'package:ramadhan_companion_app/provider/login_provider.dart';
import 'package:ramadhan_companion_app/provider/prayer_times_provider.dart';
import 'package:ramadhan_companion_app/ui/login_view.dart';
import 'package:ramadhan_companion_app/widgets/custom_button.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';
import 'package:ramadhan_companion_app/widgets/shimmer_loading.dart';

class PrayerTimesView extends StatelessWidget {
  const PrayerTimesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<PrayerTimesProvider>(
          builder: (context, provider, _) {
            if (provider.shouldAskLocation) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showLocationBottomSheet(context, provider);
                provider.setLocationAsked();
              });
            }
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildWelcomeText(context, provider),
                  const SizedBox(height: 10),
                  _buildHijriAndGregorianDate(provider, context),
                  const SizedBox(height: 20),
                  _buildCountdown(provider),
                  const SizedBox(height: 20),
                  _buildErrorText(provider),
                  _buildPrayerTimesSection(provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _buildWelcomeText(BuildContext context, PrayerTimesProvider provider) {
  final user = FirebaseAuth.instance.currentUser;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Assalamualaikum,"),
          Text(
            user?.displayName ?? "User",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      InkWell(
        onTap: () => _showLogoutConfirmation(context, provider),
        child: const Icon(Icons.logout),
      ),
    ],
  );
}

Widget _buildHijriAndGregorianDate(
  PrayerTimesProvider provider,
  BuildContext context,
) {
  return provider.hijriDateModel != null
      ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${provider.hijriDateModel!.hijriDay} ${provider.hijriDateModel!.hijriMonth} ${provider.hijriDateModel!.hijriYear} ",
                ),
                Row(
                  children: [
                    Text(
                      "${provider.hijriDateModel!.gregorianDay}, ${provider.hijriDateModel!.gregorianDayDate} ${provider.hijriDateModel!.gregorianMonth} ${provider.hijriDateModel!.gregorianYear} ",
                    ),
                  ],
                ),
              ],
            ),
            _buildLocationText(provider, context),
          ],
        )
      : const SizedBox.shrink();
}

Widget _buildLocationText(PrayerTimesProvider provider, BuildContext context) {
  return (provider.city != null && provider.country != null)
      ? Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: InkWell(
            onTap: () => _showLocationBottomSheet(context, provider),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("📍"),
                Text(
                  "${provider.city}, ${provider.country}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        )
      : const SizedBox.shrink();
}

Widget _buildCountdown(PrayerTimesProvider provider) {
  if (provider.isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        ShimmerLoadingWidget(width: 120, height: 24), // countdown text
        SizedBox(height: 8),
        ShimmerLoadingWidget(width: 220, height: 18), // subtitle
      ],
    );
  }

  if (provider.countdownText.isNotEmpty) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.countdownText,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                const TextSpan(text: "Countdown to the next prayer: "),
                TextSpan(
                  text: provider.nextPrayerText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  return const SizedBox.shrink();
}

Widget _buildPrayerTimesSection(PrayerTimesProvider provider) {
  if (provider.times == null && !provider.isLoading) {
    return const SizedBox.shrink();
  }

  return Column(
    children: [
      _buildPrayerTimesRow("Fajr", provider.times?.fajr, provider.isLoading),
      _buildPrayerTimesRow("Dhuhr", provider.times?.dhuhr, provider.isLoading),
      _buildPrayerTimesRow("Asr", provider.times?.asr, provider.isLoading),
      _buildPrayerTimesRow(
        "Maghrib",
        provider.times?.maghrib,
        provider.isLoading,
      ),
      _buildPrayerTimesRow("Isha", provider.times?.isha, provider.isLoading),
    ],
  );
}

Widget _buildErrorText(PrayerTimesProvider provider) {
  return provider.error != null
      ? Text(provider.error!, style: const TextStyle(color: Colors.red))
      : const SizedBox.shrink();
}

Widget _buildPrayerTimesRow(
  String prayerName,
  String? prayerTime,
  bool isLoading,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(prayerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        isLoading
            ? const ShimmerLoadingWidget(width: 60, height: 16)
            : Text(prayerTime ?? "-"),
      ],
    ),
  );
}

Widget _buildInsertText() {
  return Text(
    "Please insert your city and country to determine prayer times.",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  );
}

void _showLocationBottomSheet(
  BuildContext context,
  PrayerTimesProvider provider,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: provider.times != null,
    enableDrag: provider.times != null,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return ChangeNotifierProvider(
        create: (_) => LocationInputProvider(),
        child: Consumer<LocationInputProvider>(
          builder: (context, locationProvider, _) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInsertText(),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: "City",
                    onChanged: locationProvider.setCity,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: "Country",
                    onChanged: locationProvider.setCountry,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: "Find your prayer times",
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    onTap: locationProvider.isButtonEnabled
                        ? () {
                            Navigator.pop(context);
                            provider.fetchPrayerTimes(
                              locationProvider.city,
                              locationProvider.country,
                            );
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

void _showLogoutConfirmation(
  BuildContext context,
  PrayerTimesProvider provider,
) {
  if (Platform.isIOS) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Log out'),
        message: const Text('Are you sure you want to log out?'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              provider.logout();
              context.read<LoginProvider>().resetLoginState();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginView()),
              );
            },
            isDestructiveAction: true,
            child: const Text('Log out'),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              const ListTile(
                title: Text(
                  'Log out',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text('Are you sure you want to log out?'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log out'),
                onTap: () {
                  Navigator.pop(context);
                  provider.logout();
                  context.read<LoginProvider>().resetLoginState();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginView()),
                  );
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
