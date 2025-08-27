import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/calendar_provider.dart';

class CustomDatePickerSheet extends StatelessWidget {
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomDatePickerSheet({
    super.key,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DateProvider>(context, listen: true);
    final selectedDate = provider.selectedDate;

    final daysInMonth = DateUtils.getDaysInMonth(
      selectedDate.year,
      selectedDate.month,
    );

    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final startWeekday = firstDayOfMonth.weekday;
    final today = DateTime.now();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Date",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // manual input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Day"),
                    controller: TextEditingController(
                      text: selectedDate.day.toString(),
                    ),
                    onSubmitted: (v) {
                      final d = int.tryParse(v);
                      if (d != null && d >= 1 && d <= daysInMonth) {
                        provider.setSelectedDate(DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          d,
                        ));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Month"),
                    controller: TextEditingController(
                      text: selectedDate.month.toString(),
                    ),
                    onSubmitted: (v) {
                      final m = int.tryParse(v);
                      if (m != null && m >= 1 && m <= 12) {
                        provider.setSelectedDate(DateTime(
                          selectedDate.year,
                          m,
                          selectedDate.day,
                        ));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Year"),
                    controller: TextEditingController(
                      text: selectedDate.year.toString(),
                    ),
                    onSubmitted: (v) {
                      final y = int.tryParse(v);
                      if (y != null) {
                        provider.setSelectedDate(DateTime(
                          y,
                          selectedDate.month,
                          selectedDate.day,
                        ));
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    final prevMonth = DateTime(
                      selectedDate.year,
                      selectedDate.month - 1,
                      1,
                    );
                    provider.setSelectedDate(prevMonth);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  "${selectedDate.year}-${selectedDate.month}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final nextMonth = DateTime(
                      selectedDate.year,
                      selectedDate.month + 1,
                      1,
                    );
                    provider.setSelectedDate(nextMonth);
                  },
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // weekdays header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text("Mo"), Text("Tu"), Text("We"),
                Text("Th"), Text("Fr"), Text("Sa"), Text("Su"),
              ],
            ),

            const SizedBox(height: 10),

            // calendar grid
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daysInMonth + (startWeekday - 1),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  if (index < startWeekday - 1) {
                    return const SizedBox.shrink();
                  }
                  final day = index - (startWeekday - 2);
                  final thisDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    day,
                  );
                  final isSelected = thisDate.day == selectedDate.day &&
                      thisDate.month == selectedDate.month &&
                      thisDate.year == selectedDate.year;

                  final isToday = thisDate.day == today.day &&
                      thisDate.month == today.month &&
                      thisDate.year == today.year;

                  return GestureDetector(
                    onTap: () => provider.setSelectedDate(thisDate),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green
                            : isToday
                                ? Colors.green.withOpacity(0.3)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "$day",
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}
