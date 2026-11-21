import 'package:business_map/provider/dashboard/bottom_nav_bar_provider.dart';
import 'package:business_map/provider/saved/saved_provider.dart';
import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/core/routes/routes_name.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/others/general_item_card.dart';
import 'package:business_map/view/custom_widgets/shimmer/custom_shimmer.dart';
import 'package:business_map/view/custom_widgets/snack_bar/custom_snackbar.dart';
import 'package:business_map/view/custom_widgets/state/empty_state_widget.dart';
import 'package:business_map/view/custom_widgets/state/suggestion_error_overlay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/model/response/business_idea_suggestion_response.dart';
import '../../../data/model/response/location_suggestion_response.dart';

class SaveItemScreen extends StatefulWidget {
  const SaveItemScreen({super.key});

  @override
  State<SaveItemScreen> createState() => _SaveItemScreenState();
}

class _SaveItemScreenState extends State<SaveItemScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedProvider>().initListeners();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteSelected(SavedProvider provider) async {
    final isLocs = _tabController.index == 0;
    final count = isLocs ? provider.selectedLocationIds.length : provider.selectedIdeaIds.length;
    if (count == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete ${isLocs ? 'Locations' : 'Ideas'}?"),
        content: Text("Are you sure you want to delete these $count saved items?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await provider.deleteSelected(isLocs);
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: success ? "Deleted successfully" : "Failed to delete items",
          isError: !success,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavedProvider>(
      builder: (context, provider, _) {
        final isLocTab = _tabController.index == 0;
        final isSelecting = isLocTab ? provider.isLocSelectionMode : provider.isIdeaSelectionMode;
        final selectCount = isLocTab ? provider.selectedLocationIds.length : provider.selectedIdeaIds.length;

        if (provider.errorMessage != null && !provider.isLoading) {
          return SuggestionErrorOverlay(
            message: provider.errorMessage!,
            onRetry: () => provider.retryListeners(),
            onDismiss: () => provider.retryListeners(),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: Column(
            children: [
              if (isSelecting)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$selectCount Items Selected",
                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800),
                      ),
                      GestureDetector(
                        onTap: () => provider.clearSelection(isLocTab),
                        child: Text("Deselect", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

              Material(
                color: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey[400],
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  tabs: const [
                    Tab(text: "SAVED LOCATIONS"),
                    Tab(text: "SAVED IDEAS")
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSavedLocations(provider),
                    _buildSavedIdeas(provider)
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: isSelecting
              ? FloatingActionButton.extended(
                  onPressed: () => _deleteSelected(provider),
                  backgroundColor: AppColors.red,
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  label: Text("Delete ($selectCount)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSavedLocations(SavedProvider provider) {
    if (provider.isLoading) return _buildShimmerLoading();
    if (provider.savedLocations.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.map_outlined,
        title: "No Locations Saved",
        subtitle: "Items you save will appear here",
        actionLabel: "Find Locations",
        onAction: () => context.read<BottomNavBarProvider>().setIndex(0),
      );
    }

    return _buildGroupedList<TopLocation>(
      items: provider.savedLocations,
      dateGetter: (loc) => loc.createdAt,
      itemBuilder: (loc) => GeneralItemCard(
        name: loc.businessType,
        location: loc.targetArea.isNotEmpty ? loc.targetArea : loc.locationName,
        description: loc.locationDescription,
        isSelected: provider.selectedLocationIds.contains(loc.id),
        imageUrl: loc.locationImages.isNotEmpty ? loc.locationImages[0] : "",
        onTap: () {
          if (provider.isLocSelectionMode) {
            provider.toggleLocationSelection(loc.id);
          } else {
            Navigator.pushNamed(context, RoutesName.locationDetailScreen, arguments: loc);
          }
        },
        onLongPress: () => provider.toggleLocationSelection(loc.id),
      ),
    );
  }

  Widget _buildSavedIdeas(SavedProvider provider) {
    if (provider.isLoading) return _buildShimmerLoading();
    if (provider.savedIdeas.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.lightbulb_outline,
        title: "No Ideas Saved",
        subtitle: "Items you save will appear here",
        actionLabel: "Generate Ideas",
        onAction: () => context.read<BottomNavBarProvider>().setIndex(1),
      );
    }

    return _buildGroupedList<BusinessIdea>(
      items: provider.savedIdeas,
      dateGetter: (idea) => idea.createdAt,
      itemBuilder: (idea) => GeneralItemCard(
        name: idea.businessName,
        location: idea.areaContext ?? "Strategic Market",
        description: idea.description,
        isSelected: provider.selectedIdeaIds.contains(idea.id),
        imageUrl: idea.images.isNotEmpty ? idea.images[0] : "",
        onTap: () {
          if (provider.isIdeaSelectionMode) {
            provider.toggleIdeaSelection(idea.id);
          } else {
            Navigator.pushNamed(context, RoutesName.businessIdeaDetailScreen, arguments: {'idea': idea, 'isSaved': true});
          }
        },
        onLongPress: () => provider.toggleIdeaSelection(idea.id),
      ),
    );
  }

  Widget _buildGroupedList<T>({
    required List<T> items,
    required DateTime? Function(T) dateGetter,
    required Widget Function(T) itemBuilder,
  }) {
    final Map<String, List<T>> groups = {};
    for (var item in items) {
      final date = dateGetter(item) ?? DateTime.now();
      final key = DateFormat('MMMM yyyy').format(date);
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(item);
    }

    final List<dynamic> flattened = [];
    groups.forEach((key, groupItems) {
      flattened.add(key);
      flattened.addAll(groupItems);
    });

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        SizeConfig.width(20),
        SizeConfig.height(10),
        SizeConfig.width(20),
        SizeConfig.height(20),
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: flattened.length,
      itemBuilder: (context, index) {
        final element = flattened[index];
        final theme = Theme.of(context);

        if (element is String) {
          return Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? SizeConfig.height(10) : SizeConfig.height(24),
              bottom: SizeConfig.height(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      element.split(' ')[0],
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.85),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      element.split(' ')[1],
                      style: TextStyle(
                        color: theme.primaryColor.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 2,
                  width: 20,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.height(4)),
          child: itemBuilder(element as T),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.all(SizeConfig.width(20)),
      itemCount: 4,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            CustomShimmer(height: 80, width: 80, borderRadius: BorderRadius.circular(12)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomShimmer(height: 20, width: 140, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 10),
                  CustomShimmer(height: 12, width: 100, borderRadius: BorderRadius.circular(4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
