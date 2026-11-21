import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/others/app_network_image.dart';
import 'package:business_map/view/custom_widgets/shimmer/custom_shimmer.dart';
import 'package:flutter/material.dart';

class ImageSliverHeader extends StatefulWidget {
  final String title;
  final List<String> images;
  final bool isCollapsed;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final double expandedHeight;
  final IconData? placeholderIcon;

  const ImageSliverHeader({
    super.key,
    required this.title,
    required this.images,
    required this.isCollapsed,
    this.onBack,
    this.actions,
    this.expandedHeight = 300,
    this.placeholderIcon = Icons.image_rounded,
  });

  @override
  State<ImageSliverHeader> createState() => _ImageSliverHeaderState();
}

class _ImageSliverHeaderState extends State<ImageSliverHeader> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: SizeConfig.height(widget.expandedHeight),
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: theme.scaffoldBackgroundColor,
      title: widget.isCollapsed
          ? Text(
              widget.title,
              style: AppTextStyles.headingMedium(context).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          : null,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor:
              widget.isCollapsed ? Colors.transparent : Colors.black.withOpacity(0.3),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: widget.isCollapsed ? theme.iconTheme.color : Colors.white,
              size: 20,
            ),
            onPressed: widget.onBack ?? () => Navigator.pop(context),
          ),
        ),
      ),
      actions: widget.actions,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.images.isNotEmpty)
              PageView.builder(
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) => AppNetworkImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CustomShimmer(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(widget.placeholderIcon, size: 50, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor.withOpacity(0.8), theme.primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(widget.placeholderIcon, color: Colors.white24, size: 80),
              ),
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 1.0],
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
