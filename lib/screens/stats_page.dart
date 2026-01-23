import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/glass_container.dart';

class StatsPage extends StatelessWidget {
  final List<Todo> todos;

  const StatsPage({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Stats', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Summary Card
                  GlassContainer(
                    child: Column(
                      children: [
                        const Text(
                          "Task Progress",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        CircularProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white24,
                          color: Colors.cyanAccent,
                          strokeWidth: 10,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "$completed / $total Completed",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chart
                  Expanded(
                    child: GlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Last 7 Days",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
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
                                    Text(
                                      count.toString(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      width: 20,
                                      height:
                                          heightFactor * 150 +
                                          10, // Min height 10
                                      decoration: BoxDecoration(
                                        color: Colors.cyanAccent.withValues(
                                          alpha: 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      weekday,
                                      style: const TextStyle(
                                        color: Colors.white,
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC), Color(0xFF80D0C7)],
        ),
      ),
    );
  }
}
