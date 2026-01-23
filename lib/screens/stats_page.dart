import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/glass_container.dart';

class StatsPage extends StatelessWidget {
  final List<Todo> todos;

  const StatsPage({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    // Theme Awareness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    // Calculate simple stats
    final total = todos.length;
    final completed = todos.where((t) => t.isDone).length;
    final progress = total == 0 ? 0.0 : completed / total;

    // Last 7 days stats
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last7Days = List.generate(7, (index) {
      final day = today.subtract(Duration(days: 6 - index));
      final count = todos.where((t) {
        if (!t.isDone || t.completedAt == null) return false;
        final cDate = t.completedAt!;
        return cDate.year == day.year &&
            cDate.month == day.month &&
            cDate.day == day.day;
      }).length;
      return {'day': day, 'count': count};
    });

    final maxCount = last7Days
        .map((e) => e['count'] as int)
        .reduce((a, b) => a > b ? a : b);
    final chartMax = maxCount > 0 ? maxCount : 1;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Stats', style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Summary Card
                  GlassContainer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "$total",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: Stack(
                              children: [
                                Center(
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    backgroundColor: isDark
                                        ? Colors.white24
                                        : Colors.black12,
                                    color: Colors.cyanAccent,
                                    strokeWidth: 8,
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    "${(progress * 100).toInt()}%",
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                "Done",
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "$completed",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chart
                  GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Activity (Last 7 Days)",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: last7Days.map((data) {
                              final count = data['count'] as int;
                              final day = data['day'] as DateTime;
                              final heightFactor = count / chartMax;

                              // Weekday letter
                              final weekday = [
                                "M",
                                "T",
                                "W",
                                "T",
                                "F",
                                "S",
                                "S",
                              ][day.weekday - 1];

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (count > 0)
                                    Text(
                                      count.toString(),
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                  const SizedBox(height: 5),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    width: 15,
                                    height:
                                        heightFactor * 150 + 4, // Min height 4
                                    decoration: BoxDecoration(
                                      color: Colors.cyanAccent.withValues(
                                        alpha: 0.8,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    weekday,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1F1C2C), const Color(0xFF928DAB)]
              : [
                  const Color(0xFF8EC5FC),
                  const Color(0xFFE0C3FC),
                  const Color(0xFF80D0C7),
                ],
        ),
      ),
    );
  }
}
