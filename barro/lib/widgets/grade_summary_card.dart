import 'package:flutter/material.dart';

class GradeSummaryCard extends StatelessWidget {
  final String title;
  final double average;
  final int itemCount;
  final double highest;
  final double lowest;
  final Color color;
  final IconData icon;

  const GradeSummaryCard({
    super.key,
    required this.title,
    required this.average,
    required this.itemCount,
    required this.highest,
    required this.lowest,
    required this.color,
    required this.icon,
  });

  String _getLetterGrade(double pct) {
    if (pct >= 97) return '1.00';
    if (pct >= 94) return '1.25';
    if (pct >= 91) return '1.50';
    if (pct >= 88) return '1.75';
    if (pct >= 85) return '2.00';
    if (pct >= 82) return '2.25';
    if (pct >= 79) return '2.50';
    if (pct >= 76) return '2.75';
    if (pct >= 75) return '3.00';
    return '5.00';
  }

  String _getRemark(double pct) {
    if (pct >= 97) return 'Excellent';
    if (pct >= 94) return 'Very Good';
    if (pct >= 88) return 'Good';
    if (pct >= 82) return 'Satisfactory';
    if (pct >= 75) return 'Passing';
    return 'Needs Improvement';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getLetterGrade(average),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${average.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          Text(
            _getRemark(average),
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 18),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: average / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 18),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('Items', '$itemCount'),
              _buildDivider(),
              _buildStat('Highest', '${highest.toStringAsFixed(1)}%'),
              _buildDivider(),
              _buildStat('Lowest', '${lowest.toStringAsFixed(1)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}
