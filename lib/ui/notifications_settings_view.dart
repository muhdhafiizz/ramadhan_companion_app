import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/notifications_settings_provider.dart';
import 'package:ramadhan_companion_app/provider/prayer_times_provider.dart';

class NotificationsSettingsView extends StatelessWidget {
  const NotificationsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotificationSettingsProvider, PrayerTimesProvider>(
      builder: (context, notifProvider, prayerProvider, _) {
        if (!notifProvider.initialized) {
          notifProvider.loadSettings();
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(6),
                    children: [
                      // SwitchListTile(
                      //   title: const Text("Prayer Notifications"),
                      //   subtitle: const Text("Reminders for upcoming prayers"),
                      //   value: notifProvider.prayerNotificationsEnabled,
                      //   onChanged: (val) {
                      //     notifProvider.togglePrayerNotifications(val, prayerProvider);
                      //   },
                      // ),
                      // const Divider(),
                      SwitchListTile(
                        title: const Text("Sadaqah Notifications"),
                        subtitle: const Text(
                          "Weekly Friday reminder for charity",
                        ),
                        value: notifProvider.sadaqahNotificationsEnabled,
                        onChanged: notifProvider.toggleSadaqahNotifications,
                      ),
                    ],
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

Widget _buildAppBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Align(
            alignment: Alignment.centerLeft,
            child: const Icon(Icons.arrow_back),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ],
    ),
  );
}
