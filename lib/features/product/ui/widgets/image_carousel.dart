import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 380,
    this.borderRadius = BorderRadius.zero,
  });

  final List<String> imageUrls;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _images =>
      widget.imageUrls.isEmpty ? [''] : widget.imageUrls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // ── Pages ───────────────────────────────────────────────
          ClipRRect(
            borderRadius: widget.borderRadius,
            child: PageView.builder(
              controller: _controller,
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => _CarouselImage(url: _images[i]),
            ),
          ),

          // ── Dot indicators ──────────────────────────────────────
          if (_images.length > 1)
            Positioned(
              bottom: AppSpacing.md,
              left: 0,
              right: 0,
              child: _DotRow(total: _images.length, current: _current),
            ),

          // ── Image counter ───────────────────────────────────────
          if (_images.length > 1)
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '${_current + 1} / ${_images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CarouselImage extends StatelessWidget {
  const _CarouselImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const ColoredBox(
        color: AppColors.shimmerBase,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: AppSpacing.iconLg,
            color: Colors.white54,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => const ColoredBox(color: AppColors.shimmerBase),
      errorWidget: (_, __, ___) => const ColoredBox(
        color: AppColors.shimmerBase,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: AppSpacing.iconLg,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }
}

class _DotRow extends StatelessWidget {
  const _DotRow({required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: current == i ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: current == i ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
      ),
    );
  }
}
