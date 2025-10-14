import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/hadith_provider.dart';
// import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_button.dart';
// import 'package:ramadhan_companion_app/widgets/custom_pill_snackbar.dart';
import 'package:ramadhan_companion_app/widgets/shimmer_loading.dart';

class HadithView extends StatelessWidget {
  final String bookSlug;
  final String chapterId;

  const HadithView({
    super.key,
    required this.bookSlug,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          HadithProvider()..loadHadiths(bookSlug, chapterId: chapterId),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Consumer<HadithProvider>(
                  builder: (context, provider, _) {
                    return _buildAppBar(context, provider, bookSlug);
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Consumer<HadithProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading && provider.hadiths.isEmpty) {
                        return Center(child: _buildShimmerLoading());
                      }
                      if (provider.error != null) {
                        return Center(
                          child: Text(
                            "Error: ${provider.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (provider.currentHadith == null) {
                        return const Center(child: Text("No hadith found."));
                      }

                      final hadith = provider.currentHadith!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (hadith.headingEnglish != null &&
                              hadith.headingEnglish!.trim().isNotEmpty) ...[
                            Text(
                              hadith.headingEnglish!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],

                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hadith.englishNarrator ?? "",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(height: 30),

                                  Text(
                                    hadith.hadithArabic ?? "",
                                    style: const TextStyle(
                                      fontFamily: 'AmiriQuran',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      height: 2.5,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    hadith.hadithEnglish ?? "",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomButton(
                                onTap:
                                    provider.currentHadith == null ||
                                        provider.hadiths.isEmpty ||
                                        provider.hadiths.first == hadith
                                    ? null
                                    : provider.previousHadith,
                                text: 'Previous',
                                decoration: TextDecoration.underline,
                                iconData: Icons.arrow_back,
                                height: 50,
                              ),

                              Text(
                                provider.hadithPositionText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              CustomButton(
                                onTap:
                                    provider.currentHadith == null ||
                                        provider.hadiths.isEmpty ||
                                        (!provider.hasMore &&
                                            provider.hadiths.last ==
                                                provider.currentHadith)
                                    ? null
                                    : () async {
                                        await provider.nextHadith(bookSlug);
                                      },
                                text: 'Next',
                                iconAtEnd: true,
                                decoration: TextDecoration.underline,
                                iconData: Icons.arrow_forward,
                                height: 45,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildAppBar(
  BuildContext context,
  HadithProvider provider,
  String bookSlug,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
      // GestureDetector(
      //   onTap: () => _showHadithList(context, provider, bookSlug),
      //   child: const Icon(Icons.list_outlined),
      // ),
    ],
  );
}

Widget _buildShimmerLoading() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        ShimmerLoadingWidget(height: 20, width: double.infinity),
        SizedBox(height: 5),

        ShimmerLoadingWidget(height: 20, width: double.infinity),
        SizedBox(height: 5),

        ShimmerLoadingWidget(height: 20, width: double.infinity),
        SizedBox(height: 10),
        ShimmerLoadingWidget(height: 20, width: double.infinity),
        SizedBox(height: 5),

        ShimmerLoadingWidget(height: 20, width: double.infinity),
        SizedBox(height: 5),

        ShimmerLoadingWidget(height: 20, width: double.infinity),
        SizedBox(height: 5),

        ShimmerLoadingWidget(height: 20, width: double.infinity),
        SizedBox(height: 5),

        SizedBox(height: 20),
        ShimmerLoadingWidget(height: 20, width: double.infinity),
        SizedBox(height: 5),

        ShimmerLoadingWidget(height: 20, width: double.infinity),
        SizedBox(height: 5),

        ShimmerLoadingWidget(height: 20, width: double.infinity),
      ],
    ),
  );
}

// void _showHadithList(
//   BuildContext context,
//   HadithProvider provider,
//   String bookSlug,
// ) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.white,
//     builder: (_) {
//       return Scaffold(
//         bottomNavigationBar: Container(
//           padding: const EdgeInsets.only(
//             left: 20,
//             right: 20,
//             bottom: 30,
//             top: 20,
//           ),
//           child: CustomButton(
//             onTap: provider.isLoading
//                 ? null
//                 : () async {
//                     final previousCount = provider.hadiths.length;
//                     await provider.loadMore(bookSlug);

//                     if (provider.hadiths.length == previousCount) {
//                       CustomPillSnackbar.show(
//                         context,
//                         message: 'No more hadiths in this chapter',
//                       );
//                     }
//                   },
//             text: 'Load More',
//             backgroundColor: AppColors.violet.withOpacity(1),
//             textColor: Colors.white,
//           ),
//         ),
//       );
//     },
//   );
// }
