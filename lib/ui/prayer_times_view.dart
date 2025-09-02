import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadhan_companion_app/provider/bookmark_provider.dart';
import 'package:ramadhan_companion_app/provider/carousel_provider.dart';
import 'package:ramadhan_companion_app/provider/location_input_provider.dart';
import 'package:ramadhan_companion_app/provider/login_provider.dart';
import 'package:ramadhan_companion_app/provider/prayer_times_provider.dart';
import 'package:ramadhan_companion_app/ui/details_verse_view.dart';
import 'package:ramadhan_companion_app/ui/islamic_calendar_view.dart';
import 'package:ramadhan_companion_app/ui/login_view.dart';
import 'package:ramadhan_companion_app/ui/masjid_nearby_view.dart';
import 'package:ramadhan_companion_app/ui/qibla_finder_view.dart';
import 'package:ramadhan_companion_app/ui/quran_detail_view.dart';
import 'package:ramadhan_companion_app/ui/quran_view.dart';
import 'package:ramadhan_companion_app/ui/sadaqah_view.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_button.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';
import 'package:ramadhan_companion_app/widgets/shimmer_loading.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PrayerTimesView extends StatelessWidget {
  const PrayerTimesView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimesProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!provider.shouldAskLocation) provider.initialize();
    });

    final RefreshController refreshController = RefreshController(
      initialRefresh: false,
    );

    Future<void> refreshData() async {
      final provider = context.read<PrayerTimesProvider>();

      if (provider.city != null && provider.country != null) {
        await provider.fetchPrayerTimes(provider.city!, provider.country!);
      }

      // await provider.refreshDailyContent();
      refreshController.refreshCompleted();
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

            return SmartRefresher(
              controller: refreshController,
              enablePullDown: true,
              onRefresh: refreshData,
              header: const WaterDropHeader(),
              child: CustomScrollView(
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
                          color: Colors.white,
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
                        _buildIconsRow(context, provider),
                        const SizedBox(height: 20),
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
        Row(
          children: [
            InkWell(
              // onTap: () => _showLogoutConfirmation(context, provider),
              child: const Icon(Icons.settings_outlined),
            ),
            SizedBox(width: 8),
            InkWell(
              onTap: () => _showLogoutConfirmation(context, provider),
              child: const Icon(Icons.logout),
            ),
          ],
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
  return provider.hijriDateModel != null
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
                        "${provider.hijriDateModel!.hijriDay} ${provider.hijriDateModel!.hijriMonth} ${provider.hijriDateModel!.hijriYear}",
                        overflow: TextOverflow.ellipsis, // ⬅️ prevent overflow
                      ),
                      Text(
                        "${provider.hijriDateModel!.gregorianDay}, ${provider.hijriDateModel!.gregorianDayDate} ${provider.hijriDateModel!.gregorianMonth} ${provider.hijriDateModel!.gregorianYear}",
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
                      maxLines: 2,
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

Widget _buildIconsRow(BuildContext context, PrayerTimesProvider provider) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLocateMasjidNearby(context, provider),
          _buildQiblaFinder(context, provider),
          _buildIslamicCalendar(context, provider),
        ],
      ),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [_buildQuran(context), _buildSedekah(context)],
      ),
    ],
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
    padding: const EdgeInsets.all(8.0),
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
          color: AppColors.lightViolet.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.violet.withOpacity(1)),
        ),
        child: const Text(
          'Sadaqah now ',
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
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 20, top: 10),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
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
                    label: "City",
                    onChanged: locationProvider.setCity,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: "Country",
                    onChanged: locationProvider.setCountry,
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
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: provider.selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            provider.setSelectedDate(picked);
                          }
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
    );
  } else {
    showModalBottomSheet(context: context, builder: (context) => content);
  }
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
