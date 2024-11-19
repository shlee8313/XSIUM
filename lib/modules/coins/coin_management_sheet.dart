// lib/presentation/screens/home/components/coin/coin_management_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/theme_controller.dart';
import 'fee_info_widget.dart';
import 'xrp_exchange_dialog.dart';
import 'transaction_history_widget.dart';

class CoinManagementSheet extends StatelessWidget {
  const CoinManagementSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => Container(
          decoration: BoxDecoration(
            color: themeController.isDarkMode.value
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildBalanceSection(),
              _buildActionButtons(),
              const FeeInfoWidget(),
            ],
          ),
        ));
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Get.find<ThemeController>().isDarkMode.value
                ? Colors.grey[800]!
                : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Xsium Balance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/xsium_coin.png',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 12),
              const Text(
                '2,450',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Get.dialog(
                const XRPExchangeDialog(),
                barrierDismissible: false,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
              ),
              child: const Text('Exchange XRP'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.to(() => const TransactionHistoryWidget()),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
              ),
              child: const Text('History'),
            ),
          ),
        ],
      ),
    );
  }
}
