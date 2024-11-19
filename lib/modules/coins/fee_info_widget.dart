// lib/presentation/screens/home/components/coin/fee_info_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/theme_controller.dart';

class FeeInfoWidget extends StatelessWidget {
  const FeeInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fee Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: themeController.isDarkMode.value
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeeItem(
            'Text Message',
            '1 XSIUM',
            Icons.chat_bubble_outline,
          ),
          _buildFeeItem(
            'Canvas Chat',
            '5 XSIUM',
            Icons.brush,
          ),
          _buildFeeItem(
            'Group Chat',
            '2 XSIUM/person',
            Icons.group,
          ),
          _buildFeeItem(
            'File Sharing',
            '3 XSIUM',
            Icons.attach_file,
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItem(String title, String fee, IconData icon) {
    final themeController = Get.find<ThemeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: themeController.isDarkMode.value
                ? Colors.white70
                : Colors.black54,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: themeController.isDarkMode.value
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            fee,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeController.isDarkMode.value
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
