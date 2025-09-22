import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/firebase_options.dart';
import 'package:ramadhan_companion_app/provider/bookmark_provider.dart';
import 'package:ramadhan_companion_app/provider/calendar_provider.dart';
import 'package:ramadhan_companion_app/provider/carousel_provider.dart';
import 'package:ramadhan_companion_app/provider/hadith_chapters_provider.dart';
import 'package:ramadhan_companion_app/provider/hadith_books_provider.dart';
import 'package:ramadhan_companion_app/provider/hadith_provider.dart';
import 'package:ramadhan_companion_app/provider/islamic_calendar_provider.dart';
import 'package:ramadhan_companion_app/provider/location_input_provider.dart';
import 'package:ramadhan_companion_app/provider/login_provider.dart';
import 'package:ramadhan_companion_app/provider/masjid_nearby_provider.dart';
import 'package:ramadhan_companion_app/provider/notifications_provider.dart';
import 'package:ramadhan_companion_app/provider/prayer_times_provider.dart';
import 'package:ramadhan_companion_app/provider/qibla_finder_provider.dart';
import 'package:ramadhan_companion_app/provider/quran_provider.dart';
import 'package:ramadhan_companion_app/provider/sadaqah_provider.dart';
import 'package:ramadhan_companion_app/provider/signup_provider.dart';
import 'package:ramadhan_companion_app/provider/webview_provider.dart';
import 'package:ramadhan_companion_app/ui/login_view.dart';
import 'package:ramadhan_companion_app/ui/prayer_times_view.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_loading_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HomeWidget.setAppGroupId('group.com.ramadhan_companion_app.pr');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => PrayerTimesProvider()),
        ChangeNotifierProvider(create: (_) => LocationInputProvider()),
        ChangeNotifierProvider(create: (_) => CarouselProvider()),
        ChangeNotifierProvider(create: (_) => MasjidNearbyProvider()),
        ChangeNotifierProvider(create: (_) => QiblaProvider()),
        ChangeNotifierProvider(create: (_) => IslamicCalendarProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final sadaqahProvider = SadaqahProvider();
            sadaqahProvider.fetchUserRole();
            return sadaqahProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => DateProvider()),
        ChangeNotifierProvider(create: (_) => HadithBooksProvider()),
        ChangeNotifierProvider(create: (_) => HadithChaptersProvider()),
        ChangeNotifierProvider(create: (_) => HadithProvider()),
        ChangeNotifierProvider(create: (_) => PaymentWebViewProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final role = context.read<SadaqahProvider>().role ?? 'user';
            final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
            return NotificationsProvider(role, userId);
          },
        ),
      ],
      child: const MainApp(),
    ),
  );

  tz.initializeTimeZones();

  const AndroidInitializationSettings initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  const InitializationSettings initSettings = InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
  final prayerProvider = PrayerTimesProvider();
  await prayerProvider.initialize();
  await schedulePrayerNotifications(prayerProvider);
  await scheduleSadaqahReminder();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Liter',
        scaffoldBackgroundColor: AppColors.lightGray.withOpacity(1),
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
        ),
      ),
      home: StreamBuilder<List<ConnectivityResult>>(
        stream: Connectivity().onConnectivityChanged,
        builder: (context, snapshot) {
          final hasInternet =
              snapshot.hasData &&
              !snapshot.data!.contains(ConnectivityResult.none);

          if (!hasInternet) {
            return _buildNoInternet(context);
          }

          return const AuthWrapper();
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingDialog());
        }
        if (snapshot.hasData) {
          return PrayerTimesView();
        }
        return LoginView();
      },
    );
  }
}

Widget _buildNoInternet(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: Center(
        child: Column(
          children: [
            Lottie.asset('assets/lottie/no_internet_lottie.json'),
            Text("No internet connection"),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => PrayerTimesView()),
                );
              },
              child: Text(
                "Go offline →",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
