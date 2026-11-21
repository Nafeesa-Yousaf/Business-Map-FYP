import 'package:business_map/core/routes/route_args.dart';
import 'package:business_map/data/model/response/business_idea_suggestion_response.dart';
import 'package:business_map/provider/business/business_idea_provider.dart';
import 'package:business_map/provider/saved/saved_provider.dart';
import 'package:business_map/provider/tts/tts_provider.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/button/save_button.dart';
import 'package:business_map/view/custom_widgets/layout/image_sliver_header.dart';
import 'package:business_map/view/custom_widgets/snack_bar/custom_snackbar.dart';
import 'package:business_map/view/custom_widgets/text/read_more_text_widget.dart';
import 'package:business_map/view/custom_widgets/button/urdu_read_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../custom_widgets/cards/detail_section_card.dart';
import 'widgets/business_section_header.dart';
import 'widgets/core_services_widget.dart';
import 'widgets/suitability_analysis_widget.dart';
import 'widgets/market_alignment_widget.dart';
import 'widgets/target_audience_widget.dart';
import 'widgets/growth_challenges_widget.dart';
import 'widgets/winding_roadmap_widget.dart';

class BusinessIdeaDetailScreen extends StatefulWidget {
  const BusinessIdeaDetailScreen({super.key});

  @override
  State<BusinessIdeaDetailScreen> createState() =>
      _BusinessIdeaDetailScreenState();
}

class _BusinessIdeaDetailScreenState extends State<BusinessIdeaDetailScreen> {
  late ScrollController _scrollController;
  bool _isAppBarCollapsed = false;

  TTSProvider? _ttsProvider;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfSaved();
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
      final collapsed = _scrollController.offset >
          (SizeConfig.height(300) - kToolbarHeight);
      if (collapsed != _isAppBarCollapsed) {
        setState(() {
          _isAppBarCollapsed = collapsed;
        });
      }
    }
  }

  Future<void> _checkIfSaved() async {
    final idea = _readIdeaArgs(context);
    if (idea != null) {
      context.read<SavedProvider>().checkSavedStatus(idea.businessName, false);
    }
  }

  BusinessIdea? _readIdeaArgs(BuildContext context) {
    final args = RouteArgs.raw(context);
    final direct = RouteArgs.castOrNull<BusinessIdea>(args);
    if (direct != null) return direct;
    final map = RouteArgs.asStringKeyedMap(args);
    return RouteArgs.castOrNull<BusinessIdea>(map?['idea']);
  }

  Future<void> _toggleSave(SavedProvider provider, BusinessIdea idea) async {
    final ideaProvider = context.read<BusinessIdeaProvider>();
    final category = ideaProvider.suggestionResponse?.requestSummary
        ?.businessType;
    final area = ideaProvider.suggestionResponse?.requestSummary?.targetArea;

    final success = await provider.toggleSaveIdea(
        idea, category: category, area: area);
    if (mounted && success) {
      CustomSnackbar.show(context: context,
          message: provider.isCurrentItemSaved
              ? "Idea saved to vault"
              : "Idea removed from vault");
    }
  }

  @override
  Widget build(BuildContext context) {
    final idea = _readIdeaArgs(context);

    if (idea == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Business Idea")),
        body: const Center(
          child: Text("Invalid or missing business idea data."),
        ),
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
              _buildSliverAppBar(context, savedProvider, idea!),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.width(20),
                    vertical: SizeConfig.height(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(context, savedProvider, idea),
                      SizedBox(height: SizeConfig.height(28)),

                      DetailSectionCard(
                        title: "Overview",
                        icon: Icons.auto_awesome_mosaic_rounded,
                        themeColor: theme.primaryColor,
                        trailing: UrduReadButton(
                          text: "${idea.description}${idea.usp != null &&
                              idea.usp!.isNotEmpty
                              ? ". Unique Features ${idea.usp}"
                              : ""}",
                          sectionId: 'overview',
                          title: 'Overview',
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReadMoreTextWidget(
                                text: idea.description, trimLines: 3),
                            if (idea.usp != null && idea.usp!.isNotEmpty) ...[
                              SizedBox(height: SizeConfig.height(16)),
                              _buildUSPSection(context, idea),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: SizeConfig.height(30)),

                      if (idea.whyItFits != null &&
                          idea.whyItFits!.isNotEmpty) ...[
                        if (idea.fitTags.isNotEmpty) ...[
                          MarketAlignmentWidget(tags: idea.fitTags),
                          SizedBox(height: SizeConfig.height(30)),
                        ],
                        SuitabilityAnalysisWidget(judgment: idea.whyItFits!),
                        SizedBox(height: SizeConfig.height(30)),
                      ],

                      if (idea.targetAudience.isNotEmpty) ...[
                        TargetAudienceWidget(audiences: idea.targetAudience),
                        SizedBox(height: SizeConfig.height(30)),
                      ],

                      if (idea.coreServices.isNotEmpty) ...[
                        CoreServicesWidget(services: idea.coreServices),
                        SizedBox(height: SizeConfig.height(30)),
                      ],

                      if (idea.challenges.isNotEmpty) ...[
                        GrowthChallengesWidget(idea: idea),
                        SizedBox(height: SizeConfig.height(30)),
                      ],

                      if (idea.practicalTips.isNotEmpty) ...[
                        BusinessSectionHeader(
                          title: "Growth Path",
                          ttsText: idea.practicalTips.join(". "),
                          sectionId: "roadmap",
                        ),
                        const SizedBox(height: 10),
                        WindingRoadmapWidget(
                          steps: idea.practicalTips,
                          primaryColor: theme.primaryColor,
                        ),
                        SizedBox(height: SizeConfig.height(30)),
                      ],

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

  Widget _buildSliverAppBar(BuildContext context, SavedProvider provider,
      BusinessIdea idea) {
    return ImageSliverHeader(
      title: idea.businessName,
      images: idea.images,
      isCollapsed: _isAppBarCollapsed,
      placeholderIcon: Icons.business_center_rounded,
      actions: [
        if (_isAppBarCollapsed)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildSaveButton(provider, idea, mini: true),
          ),
      ],
    );
  }

  Widget _buildTitleSection(BuildContext context, SavedProvider provider,
      BusinessIdea idea) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    idea.businessName,
                    style: AppTextStyles.headingLarge(context).copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      fontSize: SizeConfig.text(28),
                    ),
                  ),
                  if (idea.categoryContext != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme
                            .of(context)
                            .primaryColor
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        idea.categoryContext!.toUpperCase(),
                        style: TextStyle(
                          color: Theme
                              .of(context)
                              .primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: SizeConfig.text(10),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!_isAppBarCollapsed) _buildSaveButton(provider, idea),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton(SavedProvider provider, BusinessIdea idea,
      {bool mini = false}) {
    return SaveButton(
      isSaved: provider.isCurrentItemSaved,
      isLoading: provider.isLoading,
      onTap: () => _toggleSave(provider, idea),
      isMini: mini,
      isAppBarCollapsed: _isAppBarCollapsed,
    );
  }

  Widget _buildUSPSection(BuildContext context, BusinessIdea idea) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme
                .of(context)
                .primaryColor
                .withOpacity(0.12),
            Theme
                .of(context)
                .primaryColor
                .withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme
            .of(context)
            .primaryColor
            .withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, color: Colors.amber[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "UNIQUE FEATURES",
                  style: TextStyle(
                    fontSize: SizeConfig.text(9),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Theme
                        .of(context)
                        .primaryColor
                        .withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 2),
                ReadMoreTextWidget(
                  text: idea.usp!,
                  trimLines: 3,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    fontSize: SizeConfig.text(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ));
  }
}
