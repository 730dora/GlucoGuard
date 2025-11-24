import 'package:flutter/material.dart';
import '../services/api.dart';
import 'package:intl/intl.dart';
import 'history_details.dart'; // <--- IMPORT THE NEW FILE

class HistoryScreen extends StatelessWidget {
  final String uid;

  const HistoryScreen({super.key, required this.uid});

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      // Format: "Nov 24"
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return '?';
    }
  }

  String _formatTime(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      // Format: "2:30 PM"
      return DateFormat('h:mm a').format(date);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService.getHistory(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final history = snapshot.data ?? [];

        if (history.isEmpty) {
          return const Center(
            child: Text(
              'No predictions yet.\nGo to the Predict tab!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          itemCount: history.length,
          padding: const EdgeInsets.all(20),
          separatorBuilder: (ctx, i) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final h = history[i];
            final prob = (h['probability'] as num).toDouble();

            return Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onTap: () {
                  // --- NAVIGATION LOGIC ---
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryDetailsScreen(data: h),
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: prob > 0.7
                      ? Colors.red[100]
                      : (prob > 0.4 ? Colors.purple[100] : Colors.green[100]),
                  child: Text(
                    '${(prob * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                title: Text(
                  h['risk'],
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  "${_formatDate(h['date'])} • ${_formatTime(h['date'])}",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }
}