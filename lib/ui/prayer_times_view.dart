import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadhan_companion_app/helper/distance_calculation.dart';
import 'package:ramadhan_companion_app/helper/local_notifications.dart';
import 'package:ramadhan_companion_app/main.dart';
import 'package:ramadhan_companion_app/provider/bookmark_provider.dart';
import 'package:ramadhan_companion_app/provider/carousel_provider.dart';
import 'package:ramadhan_companion_app/provider/location_input_provider.dart';
import 'package:ramadhan_companion_app/provider/notifications_provider.dart';
import 'package:ramadhan_companion_app/provider/prayer_times_provider.dart';
import 'package:ramadhan_companion_app/ui/details_verse_view.dart';
import 'package:ramadhan_companion_app/ui/hadith_books_view.dart';
import 'package:ramadhan_companion_app/ui/islamic_calendar_view.dart';
import 'package:ramadhan_companion_app/ui/masjid_nearby_view.dart';
import 'package:ramadhan_companion_app/ui/notifications_view.dart';
import 'package:ramadhan_companion_app/ui/qibla_finder_view.dart';
import 'package:ramadhan_companion_app/ui/quran_detail_view.dart';
import 'package:ramadhan_companion_app/ui/quran_view.dart';
import 'package:ramadhan_companion_app/ui/sadaqah_view.dart';
import 'package:ramadhan_companion_app/ui/settings_view.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_button.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';
import 'package:ramadhan_companion_app/widgets/shimmer_loading.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:convert';
import 'dart:math';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

class PrayerTimesView extends StatelessWidget {
  const PrayerTimesView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimesProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!provider.shouldAskLocation) provider.initialize();
      updatePrayerWidget(provider);
      // schedulePrayerNotifications(provider);
    });

    Future<void> refreshData() async {
      final provider = context.read<PrayerTimesProvider>();

      if (provider.city != null && provider.country != null) {
        await provider.fetchPrayerTimes(provider.city!, provider.country!);
        await updatePrayerWidget(provider);
      }

      // await provider.refreshDailyContent();
    }

    return Scaffold(
      body: SafeArea(
        child: Consumer2<PrayerTimesProvider, CarouselProvider>(
          builder: (context, provider, carouselProvider, _) {
            if (provider.shouldAskLocation) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showLocationBottomSheet(context, provider);
                provider.setLocationAsked();
              });
            }

            return RefreshIndicator(
              backgroundColor: Colors.white,
              color: AppColors.violet.withOpacity(1),
              onRefresh: refreshData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _HeaderDelegate(
                      minExtent: 50,
                      maxExtent: 90,
                      builder: (context, shrinkOffset, overlapsContent) {
                        final progress = (shrinkOffset / (90 - 40)).clamp(
                          0.0,
                          1.0,
                        );
                        return Container(
                          color: AppColors.lightGray.withOpacity(1),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 12 - (progress * 40),
                                left: 1,
                                right: 1,
                                child: Opacity(
                                  opacity: 1 - progress,
                                  child: _buildWelcomeText(context, provider),
                                ),
                              ),
                              Positioned(
                                left: 1,
                                right: 1,
                                bottom: 8,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - progress)),
                                  child: _buildHijriAndGregorianDate(
                                    provider,
                                    context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        _buildIconsGrid(context, provider),
                        _buildBookmark(context),
                        _buildSadaqahReminder(context),
                        const SizedBox(height: 20),
                        _buildCountdown(provider),
                        const SizedBox(height: 20),
                        _buildErrorText(provider),
                        _buildPrayerTimesSection(provider),
                        const SizedBox(height: 10),
                        _dailyVerseCarousel(
                          provider,
                          carouselProvider,
                          context,
                        ),
                      ],
                    ),
                  ),
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

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
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
        const Spacer(),
        Consumer<NotificationsProvider>(
          builder: (context, notificationsProvider, _) {
            final unreadCount = notificationsProvider.notifications
                .where((n) => !(n['read'] ?? false))
                .length;

            return Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NotificationsView()),
                    );
                  },
                  child: const Icon(Icons.notifications_outlined, size: 25),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsView()),
            );
          },
          child: const Icon(Icons.settings_outlined, size: 25),
        ),
      ],
    ),
  );
}

Widget _buildHijriAndGregorianDate(
  PrayerTimesProvider provider,
  BuildContext context,
) {
  if (provider.isHijriDateLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerLoadingWidget(width: 120, height: 24, isCircle: false),
          SizedBox(height: 8),
          ShimmerLoadingWidget(width: 220, height: 18, isCircle: false),
        ],
      ),
    );
  }
  return provider.activeHijriDateModel != null
      ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () => _showPrayerTimesDate(context, provider),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${provider.activeHijriDateModel!.hijriDay} "
                        "${provider.activeHijriDateModel!.hijriMonth} "
                        "${provider.activeHijriDateModel!.hijriYear}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${provider.activeHijriDateModel!.gregorianDay}, "
                        "${provider.activeHijriDateModel!.gregorianDayDate} "
                        "${provider.activeHijriDateModel!.gregorianMonth} "
                        "${provider.activeHijriDateModel!.gregorianYear}",
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(child: _buildLocationText(provider, context)),
            ],
          ),
        )
      : const SizedBox.shrink();
}

Widget _buildLocationText(PrayerTimesProvider provider, BuildContext context) {
  if (provider.city == null || provider.country == null) {
    return const SizedBox.shrink();
  }

  return InkWell(
    onTap: () => _showLocationBottomSheet(context, provider),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text("📍"),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            "${provider.city}, ${provider.country}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

Widget _buildCountdown(PrayerTimesProvider provider) {
  if ((provider.times == null || provider.error != null) &&
      !provider.isPrayerTimesLoading) {
    return const SizedBox.shrink();
  }
  if (provider.isPrayerTimesLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerLoadingWidget(width: 120, height: 24, isCircle: false),
          SizedBox(height: 8),
          ShimmerLoadingWidget(width: 220, height: 18, isCircle: false),
        ],
      ),
    );
  }

  if (provider.countdownText.isNotEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(
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
      ),
    );
  }

  return const SizedBox.shrink();
}

Widget _buildPrayerTimesSection(PrayerTimesProvider provider) {
  if ((provider.times == null || provider.error != null) &&
      !provider.isPrayerTimesLoading) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Column(
      children: [
        _buildPrayerRowWithHighlight("Fajr", provider.times?.fajr, provider),
        _buildPrayerRowWithHighlight("Dhuhr", provider.times?.dhuhr, provider),
        _buildPrayerRowWithHighlight("Asr", provider.times?.asr, provider),
        _buildPrayerRowWithHighlight(
          "Maghrib",
          provider.times?.maghrib,
          provider,
        ),
        _buildPrayerRowWithHighlight("Isha", provider.times?.isha, provider),
      ],
    ),
  );
}

Widget _buildPrayerRowWithHighlight(
  String prayer,
  String? time,
  PrayerTimesProvider provider,
) {
  bool isNext = provider.nextPrayerText.toLowerCase() == prayer.toLowerCase();

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 3),
    decoration: BoxDecoration(
      color: isNext ? AppColors.lightViolet.withOpacity(0.9) : null,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8),
      child: _buildPrayerTimesRow(
        prayer,
        time,
        provider.isPrayerTimesLoading,
        isNext: isNext,
      ),
    ),
  );
}

Widget _dailyVerseCarousel(
  PrayerTimesProvider provider,
  CarouselProvider carouselProvider,
  BuildContext context,
) {
  return Column(
    children: [
      _buildTitleText("Random Verse"),
      SizedBox(
        height: 250,
        child: PageView(
          controller: carouselProvider.pageController,
          onPageChanged: (index) {
            carouselProvider.onPageChanged(index);
          },
          children: [
            _buildDailyQuranVerse(provider, context),
            _buildHadithVerse(provider, context),
          ],
        ),
      ),
      const SizedBox(height: 8),
      SmoothPageIndicator(
        controller: carouselProvider.pageController,
        count: 2,
        effect: WormEffect(
          dotHeight: 13,
          dotWidth: 13,
          activeDotColor: AppColors.lightViolet.withOpacity(1),
        ),
      ),
    ],
  );
}

Widget _buildDailyQuranVerse(
  PrayerTimesProvider provider,
  BuildContext context,
) {
  return Padding(
    padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 20),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VerseDetailView(type: "quran", verse: provider.quranDaily!),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: provider.isQuranVerseLoading
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerLoadingWidget(
                      width: 120,
                      height: 24,
                      isCircle: false,
                    ),
                    SizedBox(height: 20),
                    ShimmerLoadingWidget(
                      width: 220,
                      height: 18,
                      isCircle: false,
                    ),
                    SizedBox(height: 8),
                    ShimmerLoadingWidget(
                      width: 100,
                      height: 16,
                      isCircle: false,
                    ),
                  ],
                )
              : provider.quranDaily != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      provider.quranDaily!.arabic,
                      style: const TextStyle(
                        fontFamily: 'AmiriQuran',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 2.5,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Text(
                      provider.quranDaily!.english,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          provider.quranDaily!.surahName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 2),
                        Text(": ${provider.quranDaily!.ayahNo}"),
                      ],
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    ),
  );
}

Widget _buildHadithVerse(PrayerTimesProvider provider, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 20),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VerseDetailView(type: "hadith", verse: provider.hadithDaily!),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: provider.hadithDaily == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerLoadingWidget(
                      width: 120,
                      height: 24,
                      isCircle: false,
                    ),
                    SizedBox(height: 20),
                    ShimmerLoadingWidget(
                      width: 220,
                      height: 18,
                      isCircle: false,
                    ),
                    SizedBox(height: 8),
                    ShimmerLoadingWidget(
                      width: 100,
                      height: 16,
                      isCircle: false,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.hadithDaily!.hadithArabic,
                      style: const TextStyle(
                        fontFamily: 'AmiriQuran',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 2.5,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.hadithDaily!.hadithEnglish,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          provider.hadithDaily!.bookSlug,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 2),
                        Text(": ${provider.hadithDaily!.volume}"),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}

Widget _buildTitleText(String name) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        name,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    ),
  );
}

Widget _buildErrorText(PrayerTimesProvider provider) {
  return provider.error != null
      ? Center(
          child: Text(
            provider.error!,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      : const SizedBox.shrink();
}

Widget _buildPrayerTimesRow(
  String prayerName,
  String? prayerTime,
  bool isLoading, {
  bool isNext = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          prayerName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isNext ? Colors.white : null,
          ),
        ),
        isLoading
            ? const ShimmerLoadingWidget(width: 60, height: 16, isCircle: false)
            : Text(
                prayerTime ?? "--:--",
                style: TextStyle(
                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                  color: isNext ? Colors.white : null,
                ),
              ),
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

Widget _buildIconsGrid(BuildContext context, PrayerTimesProvider provider) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 20,
      children: [
        _buildQuran(context),
        _buildQiblaFinder(context, provider),
        _buildLocateMasjidNearby(context, provider),
        _buildSedekah(context),
        _buildHadith(context),
        _buildIslamicCalendar(context, provider),
      ],
    ),
  );
}

Widget _buildSedekah(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SadaqahListView()),
      );
    },
    child: Column(
      children: [
        Image.asset('assets/icon/donation_icon.png', height: 50, width: 50),
        const SizedBox(height: 5),
        const Text("Sadaqah", style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget _buildSadaqahReminder(BuildContext context) {
  if (DateTime.now().weekday != DateTime.friday) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SadaqahListView()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.violet.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.violet.withOpacity(1)),
        ),
        child: const Text(
          'Sadaqah today ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
}

Widget _buildQuran(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (_) => QuranView()));
    },
    child: Column(
      children: [
        Image.asset('assets/icon/quran_icon.png', height: 50, width: 50),
        const SizedBox(height: 5),
        const Text("Quran", style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget _buildHadith(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HadithBooksView()),
      );
    },
    child: Column(
      children: [
        Image.asset('assets/icon/hadith_icon.png', height: 50, width: 50),
        const SizedBox(height: 5),
        const Text("Hadith", style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget _buildLocateMasjidNearby(
  BuildContext context,
  PrayerTimesProvider provider,
) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MasjidNearbyScreen(
            city: provider.city ?? "",
            country: provider.country ?? "",
          ),
        ),
      );
    },
    child: Column(
      children: [
        Image.asset('assets/icon/masjid_icon.png', height: 50, width: 50),
        const SizedBox(height: 5),
        const Text(
          "Masjid Nearby",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Widget _buildQiblaFinder(BuildContext context, PrayerTimesProvider provider) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QiblaCompassView(
            city: provider.city ?? "",
            country: provider.country ?? "",
          ),
        ),
      );
    },
    child: Column(
      children: [
        Image.asset('assets/icon/kaaba_icon.png', height: 50, width: 50),
        SizedBox(height: 5),
        Text("Qibla Finder", style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget _buildIslamicCalendar(
  BuildContext context,
  PrayerTimesProvider provider,
) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => IslamicCalendarView()),
      );
    },
    child: Column(
      children: [
        Image.asset(
          'assets/icon/islamic_calendar_icon.png',
          height: 50,
          width: 50,
        ),
        SizedBox(height: 5),
        Text("Islamic Calendar", style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget _buildLocateMe(BuildContext context, PrayerTimesProvider provider) {
  return GestureDetector(
    onTap: () async {
      Navigator.pop(context);
      await provider.locateMe();
    },
    child: const Text(
      'Locate me instead',
      style: TextStyle(decoration: TextDecoration.underline),
    ),
  );
}

Widget _buildBookmark(BuildContext context) {
  final provider = Provider.of<BookmarkProvider>(context);

  if (provider.bookmarks.isEmpty) return const SizedBox.shrink();

  return Column(
    children: [
      _buildTitleText("Your Bookmark"),
      SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: provider.bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = provider.bookmarks[index];
            final parts = bookmark.split(":");

            if (parts.length < 2) return const SizedBox.shrink();

            final surahNum = int.tryParse(parts[0]) ?? 0;
            final verseNum = int.tryParse(parts[1]) ?? 0;

            if (surahNum == 0 || verseNum == 0) return const SizedBox.shrink();

            final surahName = quran.getSurahName(surahNum);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SurahDetailView(
                      surahNumber: surahNum,
                      initialVerse: verseNum,
                    ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(
                  left: index == 0 ? 20 : 0,
                  right: index == provider.bookmarks.length - 1 ? 20 : 10,
                  top: 10,
                  bottom: 20,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          surahName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        Text(": $verseNum"),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

void _showLocationBottomSheet(
  BuildContext context,
  PrayerTimesProvider provider,
) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
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
                    backgroundColor: AppColors.lightGray.withOpacity(1),
                    label: "City",
                    onChanged: locationProvider.setCity,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: "Country",
                    onChanged: locationProvider.setCountry,
                    backgroundColor: AppColors.lightGray.withOpacity(1),
                  ),
                  const SizedBox(height: 20),
                  _buildLocateMe(context, provider),
                  const SizedBox(height: 10),
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

void _showPrayerTimesDate(BuildContext context, PrayerTimesProvider provider) {
  final content = AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark,
    child: Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Consumer<PrayerTimesProvider>(
          builder: (context, provider, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        provider.setSelectedDate(
                          provider.selectedDate.subtract(
                            const Duration(days: 1),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: _buildCustomCalendar(context),
                              );
                            },
                          );
                        },
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                "${provider.hijriDateModel!.gregorianDay}, ${provider.hijriDateModel!.gregorianDayDate} ${provider.hijriDateModel!.gregorianMonth} ${provider.hijriDateModel!.gregorianYear} ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              Text(
                                " ${provider.hijriDateModel!.hijriDay} ${provider.hijriDateModel!.hijriMonth} ${provider.hijriDateModel!.hijriYear} ",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        provider.setSelectedDate(
                          provider.selectedDate.add(const Duration(days: 1)),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (provider.isPrayerTimesLoading)
                  Center(
                    child: Column(
                      children: [
                        _buildPrayerTimesRow(
                          "Fajr",
                          provider.times!.fajr,
                          true,
                        ),
                        _buildPrayerTimesRow(
                          "Dhuhr",
                          provider.times!.dhuhr,
                          true,
                        ),
                        _buildPrayerTimesRow("Asr", provider.times!.asr, true),
                        _buildPrayerTimesRow(
                          "Maghrib",
                          provider.times!.maghrib,
                          true,
                        ),
                        _buildPrayerTimesRow(
                          "Isha",
                          provider.times!.isha,
                          true,
                        ),
                      ],
                    ),
                  )
                else if (provider.times != null)
                  Column(
                    children: [
                      _buildPrayerTimesRow("Fajr", provider.times!.fajr, false),
                      _buildPrayerTimesRow(
                        "Dhuhr",
                        provider.times!.dhuhr,
                        false,
                      ),
                      _buildPrayerTimesRow("Asr", provider.times!.asr, false),
                      _buildPrayerTimesRow(
                        "Maghrib",
                        provider.times!.maghrib,
                        false,
                      ),
                      _buildPrayerTimesRow("Isha", provider.times!.isha, false),
                    ],
                  )
                else if (provider.error != null)
                  Text(provider.error!)
                else
                  const Text("No data"),
              ],
            );
          },
        ),
      ),
    ),
  );

  if (Theme.of(context).platform == TargetPlatform.iOS) {
    showCupertinoSheet(
      context: context,
      pageBuilder: (context) => Material(child: content),
    ).whenComplete(() {
      provider.setSelectedDate(provider.activeDate);

      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    });
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => content,
    ).whenComplete(() {
      provider.setSelectedDate(provider.activeDate);

      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    });
  }
}

Widget _buildCustomCalendar(BuildContext context) {
  return Consumer<PrayerTimesProvider>(
    builder: (context, provider, _) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.7), // brighter
                  Colors.white.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 1.5,
              ),
            ),
            child: TableCalendar(
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: provider.selectedDate,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarFormat: CalendarFormat.month,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                rightChevronIcon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.black,
                ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.lightGray.withOpacity(1),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.violet.withOpacity(1),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(color: Colors.white),
                todayTextStyle: const TextStyle(color: Colors.black),
                weekendTextStyle: const TextStyle(color: Colors.black87),
                defaultTextStyle: const TextStyle(color: Colors.black),
                outsideDaysVisible: false,
              ),
              selectedDayPredicate: (day) =>
                  isSameDay(provider.selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                provider.setSelectedDate(selectedDay);
              },
            ),
          ),
        ),
      );
    },
  );
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  final Widget Function(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  )
  builder;

  _HeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.builder,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => builder(context, shrinkOffset, overlapsContent);

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) => true;
}

Future<void> updatePrayerWidget(PrayerTimesProvider provider) async {
  if (provider.times == null || provider.nextPrayerDate == null) return;

  await HomeWidget.saveWidgetData('fajr', provider.times?.fajr ?? "--");
  await HomeWidget.saveWidgetData('dhuhr', provider.times?.dhuhr ?? "--");
  await HomeWidget.saveWidgetData('asr', provider.times?.asr ?? "--");
  await HomeWidget.saveWidgetData('maghrib', provider.times?.maghrib ?? "--");
  await HomeWidget.saveWidgetData('isha', provider.times?.isha ?? "--");

  await HomeWidget.saveWidgetData('next_prayer', provider.nextPrayerText);
  await HomeWidget.saveWidgetData(
    'next_prayer_timestamp',
    provider.nextPrayerDate!.millisecondsSinceEpoch,
  );

  await HomeWidget.updateWidget(
    iOSName: 'PrayerTimeWidget',
    androidName: 'PrayerTimeWidget',
  );
}

Future<void> schedulePrayerNotifications(PrayerTimesProvider provider) async {
  await flutterLocalNotificationsPlugin.cancelAll();
  if (provider.times == null) return;

  void schedulePrayer(int id, String name, String time) {
    final prayerTime = parsePrayerTime(time);

    scheduleNotification(
      id: id * 10,
      title: "$name Reminder",
      body: "$name prayer will be in 20 minutes",
      scheduledDate: prayerTime.subtract(const Duration(minutes: 20)),
      playAdhan: false,
    );

    scheduleNotification(
      id: id * 10 + 1,
      title: "Prayer Time",
      body: "It's time for $name",
      scheduledDate: prayerTime,
      playAdhan: true,
    );
  }

  schedulePrayer(1, "Fajr", provider.times!.fajr);
  schedulePrayer(2, "Dhuhr", provider.times!.dhuhr);
  schedulePrayer(3, "Asr", provider.times!.asr);
  schedulePrayer(4, "Maghrib", provider.times!.maghrib);
  schedulePrayer(5, "Isha", provider.times!.isha);
}

Future<Map<String, dynamic>> loadSadaqahData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/hadith_quran_sadaqah.json',
  );
  return json.decode(jsonString);
}

Future<void> scheduleSadaqahReminder() async {
  final data = await loadSadaqahData();
  final sadaqahRefs = [
    ...data['sadaqahReferences']['quranVerses'],
    ...data['sadaqahReferences']['hadiths'],
  ];

  final random = Random();
  final ref = sadaqahRefs[random.nextInt(sadaqahRefs.length)];

  final String title = "Sadaqah Reminder";
  final String body =
      ref['translation'] ?? "Give charity today for the sake of Allah.";

  final now = tz.TZDateTime.now(tz.local);
  var friday = tz.TZDateTime(tz.local, now.year, now.month, now.day, 12, 0);

  while (friday.weekday != DateTime.friday || friday.isBefore(now)) {
    friday = friday.add(const Duration(days: 1));
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    999,
    title,
    body,
    friday,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'sadaqah_channel_id',
        'Sadaqah Notifications',
        channelDescription: 'Weekly sadaqah reminders on Fridays',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
  );
}
