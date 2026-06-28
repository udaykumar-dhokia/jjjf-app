import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonLoadingWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? fallbackSkeleton;

  const SkeletonLoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.fallbackSkeleton,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Skeletonizer(
      enabled: true,
      child: fallbackSkeleton ?? const _DefaultListSkeleton(),
    );
  }
}

class _DefaultListSkeleton extends StatelessWidget {
  const _DefaultListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: const Bone.circle(size: 48),
            title: const Bone.text(words: 2),
            subtitle: const Bone.text(words: 1),
          ),
        );
      },
    );
  }
}

class GridSkeleton extends StatelessWidget {
  final int itemCount;
  const GridSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Bone.circle(size: 48),
                SizedBox(height: 16),
                Bone.text(words: 1),
              ],
            ),
          ),
        );
      },
    );
  }
}
