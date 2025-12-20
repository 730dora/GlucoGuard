import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme.dart';
import '../widgets/history_chart.dart';

class HomeScreen extends StatelessWidget {
  final String uid; // from email to uid
  final String username;

  const HomeScreen({super.key, required this.uid, required this.username});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService.getHistory(uid), // Fetch using UID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final history = snapshot.data ?? [];
        final latest = history.isNotEmpty ? history.first : null;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            latest == null
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("No data yet."),
                    ),
                  )
                : Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Latest Result',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            latest['risk'],
                            style: const TextStyle(
                              fontSize: 22,
                              color: AppTheme.violet,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Chances of diabetes: ${(latest['probability'] * 100).toStringAsFixed(1)}%',
                          ),
                          Text(
                            'Source: ${latest['source'] ?? "Local"}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            HistoryChart(history: history),
          ],
        );
      },
    );
  }
}
