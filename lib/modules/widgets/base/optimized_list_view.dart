// lib/presentation/widgets/base/optimized_list_view.dart
import 'package:flutter/material.dart';

class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final String pageKey;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.pageKey,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: PageStorageKey(pageKey),
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => RepaintBoundary(
              child: itemBuilder(context, index),
            ),
            childCount: itemCount,
          ),
        ),
      ],
    );
  }
}
