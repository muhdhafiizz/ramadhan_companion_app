import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/login_provider.dart';
import 'package:ramadhan_companion_app/provider/masjid_programme_provider.dart';
import 'package:ramadhan_companion_app/provider/prayer_times_provider.dart';
import 'package:ramadhan_companion_app/provider/sadaqah_provider.dart';
import 'package:ramadhan_companion_app/ui/login_view.dart';
import 'package:ramadhan_companion_app/ui/notifications_settings_view.dart';
import 'package:ramadhan_companion_app/ui/prayer_times_view.dart';
import 'package:ramadhan_companion_app/ui/sadaqah_view.dart';
import 'package:ramadhan_companion_app/ui/submission_status_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerTimesProvider = context.watch<PrayerTimesProvider>();
    final sadaqahProvider = context.watch<SadaqahProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopNav(context),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    _buildEmailandRole(sadaqahProvider),
                    SizedBox(height: 10),
                    _buildListTile(
                      context,
                      title: 'List your organization',
                      icon: Icons.business_outlined,
                      onTap: () {
                        showSadaqahField(context, sadaqahProvider);
                      },
                    ),
                    _buildListTile(
                      context,
                      title: 'Add nearby masjid programme',
                      icon: Icons.event_outlined,
                      onTap: () {
                        final programmeProvider =
                            Provider.of<MasjidProgrammeProvider>(
                              context,
                              listen: false,
                            );
                        showProgrammeField(context, programmeProvider);
                      },
                    ),
                    _buildListTile(
                      context,
                      title: 'Submission status',
                      icon: Icons.assignment_turned_in_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MySubmissionsPage(),
                          ),
                        );
                      },
                    ),
                    _buildListTile(
                      context,
                      title: 'Notifications',
                      icon: Icons.notifications_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsSettingsView(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () =>
                    _showLogoutConfirmation(context, prayerTimesProvider),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: const Text(
                    'Log out',
                    style: TextStyle(decoration: TextDecoration.underline),
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

Widget _buildTopNav(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
      const SizedBox(height: 20),
      const Text(
        "Settings",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    ],
  );
}

Widget _buildEmailandRole(SadaqahProvider sadaqahProvider) {
  final role = sadaqahProvider.role ?? 'user';
  final user = FirebaseAuth.instance.currentUser;

  final isSuperAdmin = role == 'super_admin';

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          user?.displayName ?? "--",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user?.email ?? "No email",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: isSuperAdmin
                ? Colors.orange.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            border: Border.all(
              color: isSuperAdmin ? Colors.orange : Colors.green,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role,
            style: TextStyle(
              color: isSuperAdmin ? Colors.orange : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildListTile(
  BuildContext context, {
  required String title,
  required VoidCallback onTap,
  required IconData icon,
}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
    onTap: onTap,
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
              context.read<SadaqahProvider>().resetRole();
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
                  context.read<SadaqahProvider>().resetRole();
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
