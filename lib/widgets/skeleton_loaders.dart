import 'package:flutter/material.dart';

class SkeletonCard extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.height = 100.0,
    this.width = double.infinity,
    this.borderRadius = 16.0,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const SkeletonCard(height: 140.0),
          const SizedBox(height: 24.0),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonCard(height: 20.0, width: 140.0),
              SkeletonCard(height: 20.0, width: 60.0),
            ],
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            height: 180.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SkeletonCard(height: 180.0, width: 260.0),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          const SkeletonCard(height: 20.0, width: 120.0),
          const SizedBox(height: 12.0),
          const SkeletonCard(height: 80.0),
          const SizedBox(height: 12.0),
          const SkeletonCard(height: 80.0),
        ],
      ),
    );
  }
}

class MentorListSkeleton extends StatelessWidget {
  const MentorListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: const Row(
            children: [
              SkeletonCard(height: 60.0, width: 60.0, borderRadius: 30.0),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonCard(height: 16.0, width: 150.0),
                    SizedBox(height: 8.0),
                    SkeletonCard(height: 12.0, width: 100.0),
                    SizedBox(height: 8.0),
                    SkeletonCard(height: 12.0, width: 200.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
