// lib/presentation/screens/home/components/coin/transaction_history_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/theme_controller.dart';

class TransactionHistoryWidget extends StatelessWidget {
  const TransactionHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor:
          themeController.isDarkMode.value ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor:
            themeController.isDarkMode.value ? Colors.black : Colors.white,
        foregroundColor:
            themeController.isDarkMode.value ? Colors.white : Colors.black,
      ),
      body: ListView.builder(
        itemCount: 10, // 실제 데이터로 대체
        itemBuilder: (context, index) {
          return _TransactionItem(
            type: index % 2 == 0 ? 'Exchange' : 'Chat Fee',
            amount: index % 2 == 0 ? '+100' : '-1',
            date: DateTime.now().subtract(Duration(days: index)),
            isPositive: index % 2 == 0,
          );
        },
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String type;
  final String amount;
  final DateTime date;
  final bool isPositive;

  const _TransactionItem({
    required this.type,
    required this.amount,
    required this.date,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            themeController.isDarkMode.value ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeController.isDarkMode.value
                ? Colors.black26
                : Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPositive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.add : Icons.remove,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                Text(
                  date.toString().substring(0, 16),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$amount XSIUM',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
