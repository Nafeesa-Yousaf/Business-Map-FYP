import 'package:business_map/core/routes/route_args.dart';
import 'package:business_map/data/model/response/location_suggestion_response.dart';
import 'package:business_map/provider/location/location_provider.dart';
import 'package:business_map/provider/saved/saved_provider.dart';
import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/images.dart';
import 'package:business_map/core/routes/routes_name.dart';
import 'package:business_map/utils/price_converter.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/button/save_button.dart';
import 'package:business_map/view/custom_widgets/cards/detail_analysis_link_card.dart';
import 'package:business_map/view/custom_widgets/cards/detail_section_card.dart';
import 'package:business_map/view/custom_widgets/layout/image_sliver_header.dart';
import 'package:business_map/view/custom_widgets/others/custom_chip.dart';
import 'package:business_map/view/custom_widgets/snack_bar/custom_snackbar.dart';
import 'package:business_map/view/custom_widgets/text/read_more_text_widget.dart';
import 'package:business_map/view/custom_widgets/button/urdu_read_button.dart';
import 'package:business_map/provider/tts/tts_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../custom_widgets/shimmer/custom_shimmer.dart';

class LocationDetailScreen extends StatefulWidget {
  const LocationDetailScreen({super.key});

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  late ScrollController _scrollController;
  bool _isAppBarCollapsed = false;
  TTSProvider? _ttsProvider;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = RouteArgs.of<TopLocation>(context);
      if (loc != null) {
        context.read<SavedProvider>().checkSavedStatus(loc.locationName, true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ttsProvider = Provider.of<TTSProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _ttsProvider?.stop();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final collapsed =
          _scrollController.offset > (SizeConfig.height(300) - kToolbarHeight);
      if (collapsed != _isAppBarCollapsed) {
        setState(() {
          _isAppBarCollapsed = collapsed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = RouteArgs.of<TopLocation>(context);
    if (loc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Location Details")),
        body: const Center(child: Text("Invalid or missing location data.")),
      );
    }

    final theme = Theme.of(context);
    return Consumer<SavedProvider>(
      builder: (context, savedProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(context, savedProvider, loc),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.width(20),
                    vertical: SizeConfig.height(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(context, loc),

                      SizedBox(height: SizeConfig.height(28)),

                      if (loc.suitability.tags.isNotEmpty)
                        _buildTagsSection(context, loc),

                      SizedBox(height: SizeConfig.height(28)),

                      DetailSectionCard(
                        title: "About this Location",
                        icon: Icons.info_outline_rounded,
                        themeColor: theme.primaryColor,
                        trailing: UrduReadButton(
                          text: loc.locationDescription,
                          sectionId: 'about_location',
                          title: 'About this Location',
                        ),
                        content: ReadMoreTextWidget(
                          text: loc.locationDescription,
                        ),
                      ),

                      SizedBox(height: SizeConfig.height(24)),

                      DetailAnalysisLinkCard(
                        title: "Competitor Landscape",
                        subtitle:
                            "${loc.competitorAnalysis.totalCompetitorsCount} Similar Businesses",
                        badge: loc.competitorAnalysis.competitionLevel,
                        imagePath: Images.competitorImg,
                        badgeColor: Colors.indigo,
                        heroTag: "img_competitor",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RoutesName.competitorAnalysisScreen,
                            arguments: loc,
                          );
                        },
                      ),

                      SizedBox(height: SizeConfig.height(24)),

                      DetailAnalysisLinkCard(
                        title: "Budget Breakdown",
                        subtitle:
                            "Est. Total: ${PriceConverter.format(loc.budgetAnalysis.totalEstimatedBudget)} PKR",
                        badge: loc.budgetAnalysis.status,
                        imagePath: Images.budgetAnalysisImg,
                        badgeColor: (loc.budgetAnalysis.status?.isNotEmpty ?? false)
                            ? (loc.budgetAnalysis.status!.toLowerCase().contains(
                                  "within",
                                )
                                ? Colors.green
                                : Colors.orange)
                            : null,
                        heroTag: "img_budget",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RoutesName.budgetBreakdownScreen,
                            arguments: loc.budgetAnalysis,
                          );
                        },
                      ),

                      SizedBox(height: SizeConfig.height(24)),

                      DetailSectionCard(
                        title: "Why this location?",
                        icon: Icons.stars_rounded,
                        themeColor: Colors.amber[800]!,
                        trailing: UrduReadButton(
                          text: loc.suitability.summary,
                          sectionId: 'strategic_fit',
                          title: 'Why this location?',
                        ),
                        content: ReadMoreTextWidget(
                          text: loc.suitability.summary,
                        ),
                      ),

                      SizedBox(height: SizeConfig.height(12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    SavedProvider provider,
    TopLocation loc,
  ) {
    return ImageSliverHeader(
      title: loc.locationName,
      images: loc.locationImages,
      isCollapsed: _isAppBarCollapsed,
      placeholderIcon: Icons.location_on,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: _buildSaveButton(provider, loc, mini: true),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context, TopLocation loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                loc.locationName,
                style: AppTextStyles.headingLarge(context).copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: SizeConfig.text(20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildARButton(context, loc),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.room_rounded,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                loc.location,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    SavedProvider provider,
    TopLocation loc, {
    bool mini = false,
  }) {
    return SaveButton(
      isSaved: provider.isCurrentItemSaved,
      isLoading: provider.isLoading,
      onTap: () => _handleToggleSave(context, provider, loc),
      isMini: mini,
      isAppBarCollapsed: _isAppBarCollapsed,
    );
  }

  Widget _buildARButton(BuildContext context, TopLocation loc) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAROptionsSheet(context, loc),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.view_in_ar_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  "AR VIEW",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: SizeConfig.text(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAROptionsSheet(BuildContext context, TopLocation loc) {
    final hasExternal = loc.arConfig.externalUrl.isNotEmpty;
    final hasInternal = loc.arConfig.internalUrl.isNotEmpty;
    final isUnified = loc.arConfig.isUnified;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                "AR Experience",
                style: AppTextStyles.headingMedium(
                  context,
                ).copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),

              if (!hasExternal && !hasInternal) ...[
                const SizedBox(height: 20, width: double.infinity),
                Icon(Icons.view_in_ar, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  "No AR preview available for this location",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                Text(
                  "Choose how to view the 3D model",
                  style: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                if (hasExternal || hasInternal) ...[
                  _AROptionTile(
                    icon: Icons.map_rounded,
                    title: "View on Map",
                    subtitle: isUnified
                        ? "Unified View (Internal & External)"
                        : hasExternal
                        ? "External View"
                        : "Internal View",
                    color: theme.primaryColor,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(
                        context,
                        RoutesName.arFeatureScreen,
                        arguments: loc,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                if (isUnified) ...[
                  _AROptionTile(
                    icon: Icons.camera_alt_rounded,
                    title: "Place on Surface",
                    subtitle: "Unified Experience (Internal & External)",
                    color: Colors.deepOrange,
                    onTap: () {
                      Navigator.pop(ctx);
                      _launchSceneViewer(context, loc.arConfig.externalUrl);
                    },
                  ),
                ] else ...[
                  if (hasExternal) ...[
                    _AROptionTile(
                      icon: Icons.camera_alt_rounded,
                      title: "Place External on Surface",
                      subtitle: "View the exterior building layout",
                      color: Colors.deepOrange,
                      onTap: () {
                        Navigator.pop(ctx);
                        _launchSceneViewer(context, loc.arConfig.externalUrl);
                      },
                    ),
                    if (hasInternal) const SizedBox(height: 12),
                  ],
                  if (hasInternal)
                    _AROptionTile(
                      icon: Icons.camera_alt_rounded,
                      title: "Place Internal on Surface",
                      subtitle: "View the interior floor plan",
                      color: Colors.teal,
                      onTap: () {
                        Navigator.pop(ctx);
                        _launchSceneViewer(context, loc.arConfig.internalUrl);
                      },
                    ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTagsSection(BuildContext context, TopLocation loc) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: loc.suitability.tags
          .map(
            (tag) => CustomChip(
              label: tag,
              fontSize: SizeConfig.text(12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
          )
          .toList(),
    );
  }

  void _handleToggleSave(
    BuildContext context,
    SavedProvider provider,
    TopLocation location,
  ) async {
    final success = await provider.toggleSaveLocation(location);
    if (!mounted) return;
    if (success) {
      CustomSnackbar.show(
        context: context,
        message: provider.isCurrentItemSaved
            ? "Location saved to your profile"
            : "Location removed from your profile",
        isError: false,
      );
    } else {
      CustomSnackbar.show(
        context: context,
        message: "Something went wrong",
        isError: true,
      );
    }
  }

  Future<void> _launchSceneViewer(BuildContext context, String modelUrl) async {
    if (modelUrl.isEmpty) {
      CustomSnackbar.show(
        context: context,
        message: "No AR model available for this location",
        isError: true,
      );
      return;
    }

    final encodedUrl = Uri.encodeComponent(modelUrl);

    final intentUri = Uri.parse(
      'intent://arvr.google.com/scene-viewer/1.1'
      '?file=$encodedUrl'
      '&mode=ar_only'
      '&resizable=true'
      '&title=Business%20Model'
      '&enable_occlusion=true'
      '&placement=floor'
      '#Intent;scheme=https;package=com.google.android.googlequicksearchbox;action=android.intent.action.VIEW;end;',
    );

    final fallbackUri = Uri.parse(
      'https://arvr.google.com/scene-viewer/1.1'
      '?file=$encodedUrl'
      '&mode=ar_only'
      '&resizable=true',
    );

    try {
      if (await canLaunchUrl(intentUri)) {
        await launchUrl(intentUri);
      } else if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          CustomSnackbar.show(
            context: context,
            message: "AR not supported. Please install Google app or ARCore.",
            isError: true,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(
          context: context,
          message: "Failed to launch AR: $e",
          isError: true,
        );
      }
    }
  }
}

class _AROptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AROptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
