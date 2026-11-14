import 'package:flutter/material.dart';

class StaleNotice extends StatelessWidget {
  const StaleNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF382C1D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF73532D)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: Color(0xFFFFC078), size: 17),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'You are viewing the last saved snapshot. Live data could not be refreshed.',
              style: TextStyle(color: Color(0xFFFFD49D), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
