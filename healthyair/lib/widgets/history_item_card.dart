// lib/widgets/history_item_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryItemCard extends StatelessWidget {
  final String cityName;
  final String aqi;
  final String time;
  final VoidCallback onTap;

  const HistoryItemCard({
    Key? key,
    required this.cityName,
    required this.aqi,
    required this.time,
    required this.onTap,
  }) : super(key: key);

  // Helper method to determine color based on AQI value
  Color _getAqiColor() {
    try {
      final aqiValue = int.parse(aqi);
      if (aqiValue <= 50) return Colors.green;
      if (aqiValue <= 100) return Colors.yellow;
      if (aqiValue <= 150) return Colors.orange;
      if (aqiValue <= 200) return Colors.red;
      if (aqiValue <= 300) return Colors.purple;
      return Colors.brown;
    } catch (e) {
      // If AQI is not a valid number, return gray
      return Colors.grey;
    }
  }

  // Format the timestamp
  String _formatTime() {
    try {
      final DateTime dateTime = DateTime.parse(time);
      return DateFormat('MMM d, yyyy - h:mm a').format(dateTime);
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Location icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // City and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cityName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // AQI indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getAqiColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getAqiColor(),
                    width: 1,
                  ),
                ),
                child: Text(
                  'AQI: $aqi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getAqiColor(),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Chevron icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}