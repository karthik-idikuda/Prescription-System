import 'package:flutter/material.dart';

/// Shimmer loading skeleton for list items
class SkeletonLoader extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Patient list skeleton
class PatientListSkeleton extends StatelessWidget {
  final int count;

  const PatientListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: PatientCardSkeleton(),
      ),
    );
  }
}

class PatientCardSkeleton extends StatelessWidget {
  const PatientCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SkeletonLoader(height: 56, width: 56, borderRadius: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(height: 16, width: MediaQuery.of(context).size.width * 0.4),
                const SizedBox(height: 8),
                SkeletonLoader(height: 12, width: MediaQuery.of(context).size.width * 0.3),
              ],
            ),
          ),
          const SkeletonLoader(height: 24, width: 24, borderRadius: 12),
        ],
      ),
    );
  }
}

/// Prescription list skeleton
class PrescriptionListSkeleton extends StatelessWidget {
  final int count;

  const PrescriptionListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonLoader(height: 16, width: MediaQuery.of(context).size.width * 0.25),
                  const SkeletonLoader(height: 24, width: 80, borderRadius: 12),
                ],
              ),
              const SizedBox(height: 12),
              SkeletonLoader(height: 14, width: MediaQuery.of(context).size.width * 0.5),
              const SizedBox(height: 8),
              SkeletonLoader(height: 14, width: MediaQuery.of(context).size.width * 0.35),
            ],
          ),
        ),
      ),
    );
  }
}
