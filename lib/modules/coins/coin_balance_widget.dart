// lib/presentation/screens/home/components/coin/coin_balance_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/theme_controller.dart';
import 'coin_management_sheet.dart';

class CoinBalanceWidget extends StatelessWidget {
  const CoinBalanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GestureDetector(
          onTap: () => _showCoinManagementSheet(context),
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: themeController.isDarkMode.value
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/xsium_coin.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  '2,450', // 실제 잔액으로 대체
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _showCoinManagementSheet(BuildContext context) {
    Get.bottomSheet(
      const CoinManagementSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
