import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/helper/distance_calculation.dart';
import 'package:ramadhan_companion_app/model/sadaqah_model.dart';
import 'package:ramadhan_companion_app/ui/webview_view.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_button.dart';
import 'package:ramadhan_companion_app/widgets/custom_pill_snackbar.dart';
import 'package:ramadhan_companion_app/widgets/custom_reminder.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';
import 'package:ramadhan_companion_app/widgets/shimmer_loading.dart';
import '../provider/sadaqah_provider.dart';

class SadaqahListView extends StatelessWidget {
  const SadaqahListView({super.key});

  @override
  Widget build(BuildContext context) {
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
                Column(
                  children: [
                    _buildAppBar(context),
                    const SizedBox(height: 10),
                    _buildSearchBar(context),
                    const SizedBox(height: 10),
                    _buildCategoryBar(context, provider),
                    const SizedBox(height: 10),

                    Expanded(
                      child: provider.isLoading
                          ? _buildShimmerLoading()
                          : provider.sadaqahList.isEmpty
                          ? const Center(
                              child: Text("No organizations available"),
                            )
                          : RefreshIndicator(
                              backgroundColor: Colors.white,
                              color: AppColors.violet.withOpacity(1),
                              onRefresh: () async {
                                await provider.loadSadaqahList();
                              },
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: provider.sadaqahList.length,
                                itemBuilder: (context, index) {
                                  final sadaqah = provider.sadaqahList[index];
                                  return Container(
                                    margin: const EdgeInsets.all(12),
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => WebViewPage(
                                                url: sadaqah.url,
                                                title: sadaqah.organization,
                                              ),
                                            ),
                                          );
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
                    ),
                  ],
                ),

                // ),
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
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
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
    ),
  );
}

Widget _buildSearchBar(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(60),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: CustomTextField(
        onChanged: (value) {
          context.read<SadaqahProvider>().search(value);
        },
        label: "Search organizations",
      ),
    ),
  );
}

Widget _buildCategoryBar(BuildContext context, SadaqahProvider provider) {
  final List<String> categories = [
    'All',
    'For Gaza 🇵🇸',
    'Crisis & Emergency',
    'Health & Medical',
    'Children & Youth',
    'Animals & Environment',
    'Social & Community Services',
  ];

  return SizedBox(
    height: 40,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = provider.filterCategory == category;

        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 12 : 4, right: 4),
          child: GestureDetector(
            onTap: () => provider.setFilterCategory(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey.shade300,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
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
    onTap: () => showSadaqahField(context, provider),
    child: CustomReminder(),
  );
}

Widget _buildContainer() {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
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

Widget _buildContainerNotice() {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(width: 2, color: AppColors.betterGray.withOpacity(1)),
      borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.all(10),
    child: Text(
      'Please take note it will take up to 1-2 business days to display your organization as part of verification matter.',
      style: TextStyle(fontSize: 14),
    ),
  );
}

Widget _buildShimmerLoading() {
  return ListView.builder(
    padding: const EdgeInsets.all(10),
    itemCount: 4, 
    itemBuilder: (context, index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLoadingWidget(height: 20, width: 50),
                  SizedBox(height: 8),
                  ShimmerLoadingWidget(height: 20, width: 70),
                  SizedBox(height: 8),
                  ShimmerLoadingWidget(height: 20, width: 90),
                  SizedBox(height: 8),
                  ShimmerLoadingWidget(height: 20, width: 110),
                ],
              ),
              const ShimmerLoadingWidget(width: 50, height: 50, isCircle: true),
            ],
          ),
        ),
      );
    },
  );
}

void showSadaqahField(BuildContext context, SadaqahProvider provider) {
  final pageController = PageController();

  final content = StatefulBuilder(
    builder: (context, setState) {
      pageController.addListener(() {
        setState(() {});
      });

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          bottomNavigationBar: Consumer<SadaqahProvider>(
            builder: (context, sadaqahProvider, _) {
              final onPageTwo =
                  pageController.hasClients &&
                  pageController.page?.round() == 1;

              return Container(
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
                  onTap: onPageTwo
                      ? (sadaqahProvider.isFormValid
                            ? () async {
                                final user = FirebaseAuth.instance.currentUser;

                                final sadaqah = Sadaqah(
                                  id: '',
                                  organization: sadaqahProvider
                                      .orgController
                                      .text
                                      .trim(),
                                  bankName: sadaqahProvider.bankController.text
                                      .trim(),
                                  accountNumber: sadaqahProvider
                                      .accountController
                                      .text
                                      .trim(),
                                  reference: "Donation",
                                  url: sadaqahProvider.linkController.text
                                      .trim(),
                                  submittedBy: user?.uid ?? '',
                                  status: "pending",
                                  category: sadaqahProvider.formCategory,
                                );

                                await sadaqahProvider.addSadaqah(sadaqah);
                                provider.resetForm();

                                Navigator.pop(context);
                                CustomPillSnackbar.show(
                                  context,
                                  message:
                                      '✅ Organization submitted successfully!',
                                );
                              }
                            : null)
                      : () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                  backgroundColor: onPageTwo && !sadaqahProvider.isFormValid
                      ? Colors.grey
                      : Colors.black,
                  text: onPageTwo ? 'Submit' : 'Review your details',
                  textColor: Colors.white,
                ),
              );
            },
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // PAGE 1 (Plan selection)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleText(
                        '🌙 Benefits of Adding Your Organization',
                      ),
                      const SizedBox(height: 12),
                      _buildContainer(),
                      const SizedBox(height: 30),
                      _buildOneOffPayment(),
                    ],
                  ),

                  // PAGE 2 (Review + Org details)
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
                      SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              _buildTitleText('Your Organization'),
                              CustomTextField(
                                controller: provider.orgController,
                                label: 'Organization Name',
                              ),
                              _buildTitleText('Category'),
                              Consumer<SadaqahProvider>(
                                builder: (context, sadaqahProvider, _) {
                                  return GestureDetector(
                                    onTap: () {
                                      showCategoryBottomSheet(context, (
                                        category,
                                      ) {
                                        sadaqahProvider.setFormCategory(
                                          category,
                                        ); // ✅ use consumer’s sadaqahProvider
                                      });
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Text(
                                        sadaqahProvider
                                            .formCategory, // ✅ updated value now reflects instantly
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              sadaqahProvider.formCategory ==
                                                  "All"
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              _buildTitleText('Link to your website/ social'),
                              CustomTextField(
                                controller: provider.linkController,
                                label: 'Link',
                                keyboardType: TextInputType.url,
                              ),

                              _buildTitleText('Bank Name'),
                              CustomTextField(
                                controller: provider.bankController,
                                label: 'Bank Name',
                              ),

                              _buildTitleText('Account Number'),
                              CustomTextField(
                                controller: provider.accountController,
                                label: 'Account Number',
                                keyboardType: TextInputType.number,
                              ),

                              const SizedBox(height: 20),
                              Text(
                                "One-off",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.violet.withOpacity(1),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "RM ${formatCurrency(50)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),
                              _buildContainerNotice(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

void showCategoryBottomSheet(
  BuildContext context,
  Function(String) onCategorySelected,
) {
  final List<String> categories = [
    'All',
    'For Gaza 🇵🇸',
    'Crisis & Emergency',
    'Health & Medical',
    'Children & Youth',
    'Animals & Environment',
    'Social & Community Services',
  ];

  String? selectedCategory;

  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5, // ✅ half screen
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Select a Category",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category list
                    Expanded(
                      child: ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = selectedCategory == category;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.violet.withOpacity(1)
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Cancel + Confirm buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            text: 'Cancel',
                            borderColor: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            onTap: selectedCategory == null
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    onCategorySelected(selectedCategory!);
                                  },
                            text: 'Confirm',
                            textColor: Colors.white,
                            backgroundColor: AppColors.violet.withOpacity(1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildOneOffPayment() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.violet.withOpacity(0.1),
          border: Border.all(color: AppColors.violet.withOpacity(1)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Early bird promo',
          style: TextStyle(
            color: AppColors.violet.withOpacity(1),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      SizedBox(height: 20),

      Text('One-off Payment', style: TextStyle(fontSize: 14)),
      Text(
        'RM ${formatCurrency(50)}',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
      ),
    ],
  );
}

// Widget _buildContainerSubscription({
//   required String subscription,
//   required String billed,
//   required double amount,
//   required double amountPerMonth,
//   required String selectedPlan,
//   required VoidCallback onTap,
// }) {
//   final isSelected = selectedPlan == subscription;

//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: AppColors.lightGray.withOpacity(1),
//         border: Border.all(
//           color: isSelected
//               ? AppColors.violet.withOpacity(1)
//               : AppColors.betterGray.withOpacity(1),
//           width: 2,
//         ),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 '$subscription subscription',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Text('RM ${formatCurrency(amountPerMonth)} / month'),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text('RM ${formatCurrency(amount)} per year, billed $billed'),
//         ],
//       ),
//     ),
//   );
// }
