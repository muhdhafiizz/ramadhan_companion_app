import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_button.dart';
import 'package:ramadhan_companion_app/widgets/custom_pill_snackbar.dart';
import 'package:ramadhan_companion_app/widgets/custom_reminder.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';
import '../provider/sadaqah_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SadaqahListView extends StatelessWidget {
  const SadaqahListView({super.key});

  @override
  Widget build(BuildContext context) {
    // trigger reminder once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SadaqahProvider>();
      if (!provider.hasShownReminder) {
        provider.markReminderShown();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Consumer<SadaqahProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      const SizedBox(height: 10),
                      _buildSearchBar(context),
                      Expanded(
                        child: provider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : provider.sadaqahList.isEmpty
                            ? const Center(
                                child: Text("No organizations available"),
                              )
                            : ListView.builder(
                                itemCount: provider.sadaqahList.length,
                                itemBuilder: (context, index) {
                                  final sadaqah = provider.sadaqahList[index];
                                  return Container(
                                    margin: const EdgeInsets.all(10),
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
                                    child: ListTile(
                                      title: Text(
                                        sadaqah.organization,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sadaqah.bankName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              await Clipboard.setData(
                                                ClipboardData(
                                                  text: sadaqah.accountNumber,
                                                ),
                                              );
                                              CustomPillSnackbar.show(
                                                context,
                                                message:
                                                    "✅ Account number copied!",
                                              );
                                            },
                                            child: Text(
                                              sadaqah.accountNumber,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                          if (sadaqah.reference.isNotEmpty)
                                            Text(
                                              "Reference: ${sadaqah.reference}",
                                            ),
                                        ],
                                      ),
                                      trailing: GestureDetector(
                                        onTap: () async {
                                          if (sadaqah.url.isNotEmpty) {
                                            final url = Uri.parse(sadaqah.url);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(
                                                url,
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            }
                                          }
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: Colors.grey[100],
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                if (provider.hasShownReminder)
                  Positioned(
                    bottom: 20,
                    left: 12,
                    right: 12,
                    child: _buildSadaqahOrganization(context, provider),
                  ),
              ],
            );
          },
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
        "Sadaqah Organizations",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    ],
  );
}

Widget _buildSearchBar(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(60),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomTextField(
        onChanged: (value) {
          context.read<SadaqahProvider>().search(value);
        },
        label: "Search organizations",
      ),
    ),
  );
}

Widget _buildTitleText(String name) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        name,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ),
  );
}

Widget _buildSubtitleText(String name) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(name, style: TextStyle(fontSize: 18)),
  );
}

Widget _buildDescriptionText(String name) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      name,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildSadaqahOrganization(
  BuildContext context,
  SadaqahProvider provider,
) {
  return GestureDetector(
    onTap: () => _showSadaqahField(context, provider),
    child: CustomReminder(),
  );
}

Widget _buildContainer() {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColors.lightGray.withOpacity(1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        _buildDescriptionText(
          'Gain exposure to a wider Muslim community\n\nBuild credibility by being listed in a curated Islamic platform.\n\nSimplify the donation process for your supporters.\n\nHelp Muslims fulfill their sadaqah and charity obligations more easily.\n\nEngage recurring donors who want to give regularly (daily, weekly, or monthly).',
        ),
      ],
    ),
  );
}

Widget _buildPriceText() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSubtitleText('Only at'),
      Text.rich(
        TextSpan(
          text: 'RM 19.90/',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          children: [
            const TextSpan(text: ' '),
            const TextSpan(
              text: 'month',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildContainerNotice() {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(width: 2, color: AppColors.betterGray.withOpacity(1)),
      borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.all(10),
    child: Text(
      'Please take note it will take up to 3-5 business days to display your organization as part of verification matter.',
      style: TextStyle(fontSize: 14),
    ),
  );
}


void _showSadaqahField(BuildContext context, SadaqahProvider provider) {
  final pageController = PageController();

  final content = StatefulBuilder(
    builder: (context, setState) {
      pageController.addListener(() {
        setState(() {});
      });

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          bottomNavigationBar: Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 30,
              top: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, -1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: CustomButton(
              onTap: () {
                if (pageController.page == 0) {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  print('submit sadaqah form');
                }
              },
              backgroundColor: AppColors.violet.withOpacity(1),
              text: (pageController.hasClients &&
                      pageController.page?.round() == 1)
                  ? 'Submit'
                  : 'Review your details',
              textColor: Colors.white,
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Page 1
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleText('🌙  Benefits of Adding Your Organization'),
                    const SizedBox(height: 12),
                    _buildContainer(),
                    const SizedBox(height: 20),
                    _buildPriceText(),
                  ],
                ),

                // Page 2
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(height: 20),
                    _buildTitleText('Your Organization'),
                    CustomTextField(label: 'Organization Name'),
                    _buildTitleText('Link to your website/ social'),
                    CustomTextField(label: 'Link'),
                    _buildTitleText('Bank Name'),
                    CustomTextField(label: 'Bank Name'),
                    _buildTitleText('Account Number'),
                    CustomTextField(label: 'Account Number'),
                    const Spacer(),
                    _buildContainerNotice(),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (Theme.of(context).platform == TargetPlatform.iOS) {
    showCupertinoSheet(
      context: context,
      pageBuilder: (context) => Material(child: content),
    ).whenComplete(() {
      // 👇 Reset system bar style after sheet closes
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    });
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => content,
    ).whenComplete(() {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    });
  }
}

