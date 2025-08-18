import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ramadhan_companion_app/provider/islamic_calendar_provider.dart';

class IslamicCalendarView extends StatelessWidget {
  const IslamicCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IslamicCalendarProvider>(
      builder: (context, provider, child) {
        final days = provider.getDaysInMonth();
        final startWeekday = provider.firstWeekdayOfMonth();
        final leadingEmpty = startWeekday - 1;

        final todayKey = HijriCalendar.now().toFormat("dd/MM/yyyy");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.fetchSpecialDays();
        });

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildAppBar(context),
                  const SizedBox(height: 20),
                  _buildYearAndNextMonth(provider),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: HijriCalendar.shortWeekdays
                        .map(
                          (day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 1,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                      itemCount: leadingEmpty + days.length,
                      itemBuilder: (context, index) {
                        if (index < leadingEmpty) {
                          return const SizedBox.shrink();
                        }

                        final day = days[index - leadingEmpty];
                        final isToday =
                            (day.toFormat("dd/MM/yyyy") == todayKey);

                        return Container(
                          decoration: BoxDecoration(
                            color: isToday
                                ? Colors.green.withOpacity(0.3)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "${day.hDay}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildTitleText('Special Days'),

                  Expanded(
                    child: provider.specialDays.isEmpty
                        ? const Center(child: Text("No special days loaded"))
                        : ListView.builder(
                            itemCount: provider.specialDays
                                .where(
                                  (s) => s.month == provider.focusedDate.hMonth,
                                )
                                .length,
                            itemBuilder: (context, index) {
                              final filtered = provider.specialDays
                                  .where(
                                    (s) =>
                                        s.month == provider.focusedDate.hMonth,
                                  )
                                  .toList();

                              final special = filtered[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Image.asset(
                                    'assets/icon/glitter_icon.png',
                                    height: 30,
                                    width: 30,
                                  ),
                                  title: Text(special.name),
                                  subtitle: Text(
                                    "Day: ${special.day}",
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildAppBar(BuildContext context) {
  return Row(
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
      const SizedBox(width: 10),
      const Text(
        "Islamic Calendar",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    ],
  );
}

Widget _buildYearAndNextMonth(IslamicCalendarProvider provider) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        provider.monthYearLabel,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: provider.prevMonth,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: provider.nextMonth,
          ),
        ],
      ),
    ],
  );
}

Widget _buildTitleText(String name) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      name,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
    ),
  );
}
