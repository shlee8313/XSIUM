// lib/presentation/screens/home/components/coin/xrp_exchange_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/theme_controller.dart';

class XRPExchangeDialog extends StatelessWidget {
  const XRPExchangeDialog({super.key});

  static const double _exchangeRate = 10.0; // 1 XRP = 10 XSIUM

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final xrpController = TextEditingController();
    final xsiumAmount = 0.0.obs;

    return AlertDialog(
      backgroundColor:
          themeController.isDarkMode.value ? Colors.grey[900] : Colors.white,
      title: Text(
        'Exchange XRP to XSIUM',
        style: TextStyle(
          color: themeController.isDarkMode.value ? Colors.white : Colors.black,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: xrpController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: themeController.isDarkMode.value
                  ? Colors.white
                  : Colors.black,
            ),
            decoration: InputDecoration(
              labelText: 'XRP Amount',
              suffixText: 'XRP',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: themeController.isDarkMode.value
                      ? Colors.grey[600]!
                      : Colors.grey[300]!,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            onChanged: (value) {
              final xrp = double.tryParse(value) ?? 0;
              xsiumAmount.value = xrp * _exchangeRate;
            },
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
                'You will receive: ${xsiumAmount.value} XSIUM',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
                ),
              )),
          const SizedBox(height: 8),
          const Text(
            'Exchange Rate: 1 XRP = $_exchangeRate XSIUM',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: themeController.isDarkMode.value
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => _processExchange(xrpController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: const Text('Exchange'),
        ),
      ],
    );
  }

  void _processExchange(String xrpAmount) {
    // 교환 처리 로직
    try {
      final amount = double.parse(xrpAmount);
      if (amount <= 0) {
        throw Exception('Invalid amount');
      }

      // 실제 교환 로직 구현

      Get.back();
      Get.snackbar(
        'Success',
        'Exchange completed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
