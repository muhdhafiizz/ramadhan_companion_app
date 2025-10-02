import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/notifications_provider.dart';
import 'package:ramadhan_companion_app/provider/sadaqah_provider.dart';
import 'package:ramadhan_companion_app/ui/details_notifications_view.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final role = context.watch<SadaqahProvider>().role ?? 'user';
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    provider.startListening(role, userId);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: provider.notifications.isEmpty
                  ? const Center(child: Text("No notifications"))
                  : ListView.builder(
                      itemCount: provider.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = provider.notifications[index];

                        // final ts = notification['timestamp'];
                        // if (ts != null && ts is Timestamp) {
                        //   final createdAt = ts.toDate();
                        //   final oneWeekAgo = DateTime.now().subtract(
                        //     const Duration(days: 7),
                        //   );

                        //   // if (createdAt.isBefore(oneWeekAgo)) {
                        //   //   FirebaseFirestore.instance
                        //   //       .collection('notifications')
                        //   //       .doc(
                        //   //         notification['id'],
                        //   //       )
                        //   //       .delete();

                        //   //   return const SizedBox();
                        //   // }
                        // }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailsNotificationsView(
                                  notification: notification,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification['timestamp'] != null
                                            ? (notification['timestamp']
                                                      as Timestamp)
                                                  .toDate()
                                                  .toLocal()
                                                  .toString()
                                            : 'No date',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification['title'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        notification['message'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Divider(),
                                    ],
                                  ),
                                ),
                                if (!(notification['read'] ?? false))
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Icons.circle,
                                      color: AppColors.violet.withOpacity(1),
                                      size: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
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
