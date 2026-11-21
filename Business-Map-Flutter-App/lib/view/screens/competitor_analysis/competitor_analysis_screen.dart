import 'package:business_map/core/routes/route_args.dart';
import 'package:business_map/data/model/response/location_suggestion_response.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/screens/competitor_analysis/competitor_info_card.dart';
import 'package:business_map/view/screens/competitor_analysis/interactive_swot_matrix.dart';
import 'package:business_map/view/screens/competitor_analysis/market_summary_section.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:business_map/provider/tts/tts_provider.dart';
import 'package:provider/provider.dart';

class CompetitorAnalysisScreen extends StatefulWidget {
  const CompetitorAnalysisScreen({super.key});

  @override
  State<CompetitorAnalysisScreen> createState() =>
      _CompetitorAnalysisScreenState();
}

class _CompetitorAnalysisScreenState extends State<CompetitorAnalysisScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isAppBarCollapsed = false;
  late ScrollController _scrollController;
  TTSProvider? _ttsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ttsProvider = Provider.of<TTSProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
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

  void _onMapCreated(GoogleMapController controller, TopLocation loc) {
    _mapController = controller;
    _updateMarkers(loc);
  }

  void _updateMarkers(TopLocation loc) {
    final Set<Marker> markers = {};

    markers.add(
      Marker(
        markerId: const MarkerId('prime_site'),
        position: LatLng(loc.coordinates.lat, loc.coordinates.lng),
        infoWindow: InfoWindow(
          title: loc.locationName,
          snippet: 'Your Target Site',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    for (var comp in loc.competitorAnalysis.topCompetitors) {
      markers.add(
        Marker(
          markerId: MarkerId(comp.id),
          position: LatLng(comp.coordinates.lat, comp.coordinates.lng),
          infoWindow: InfoWindow(title: comp.name, snippet: comp.location),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });

    _fitBounds(loc);
  }

  void _fitBounds(TopLocation loc) {
    if (_mapController == null) return;

    double minLat = loc.coordinates.lat;
    double maxLat = loc.coordinates.lat;
    double minLng = loc.coordinates.lng;
    double maxLng = loc.coordinates.lng;

    for (var comp in loc.competitorAnalysis.topCompetitors) {
      double lat = comp.coordinates.lat;
      double lng = comp.coordinates.lng;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = RouteArgs.of<TopLocation>(context);
    if (loc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Competitor Analysis')),
        body: const Center(child: Text('Invalid or missing location data.')),
      );
    }
    final analysis = loc.competitorAnalysis;
    final insights = analysis.insights;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: SizeConfig.height(350),
            pinned: true,
            stretch: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: theme.scaffoldBackgroundColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: _isAppBarCollapsed
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _isAppBarCollapsed
                        ? theme.iconTheme.color
                        : Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            title: _isAppBarCollapsed
                ? Text(
                    "Competitor Analysis",
                    style: AppTextStyles.headingMedium(
                      context,
                    ).copyWith(fontSize: 16),
                  )
                : null,
            actions: [
              if (!_isAppBarCollapsed)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    child: IconButton(
                      icon: const Icon(
                        Icons.my_location_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _fitBounds(loc),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GoogleMap(
                onMapCreated: (controller) => _onMapCreated(controller, loc),
                initialCameraPosition: CameraPosition(
                  target: LatLng(loc.coordinates.lat, loc.coordinates.lng),
                  zoom: 15.0,
                ),
                markers: _markers,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.width(20),
                right: SizeConfig.width(20),
                top: SizeConfig.height(24),
                bottom: SizeConfig.height(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarketSummarySection(
                    totalCompetitors: analysis.totalCompetitorsCount,
                    competitionLevel: analysis.competitionLevel,
                    competitionColor: _getCompetitionColor(
                      analysis.competitionLevel,
                    ),
                  ),

                  SizedBox(height: SizeConfig.height(35)),

                  Text(
                    "Top Competitors",
                    style: AppTextStyles.headingMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: SizeConfig.height(16)),
                  _buildCompetitorList(context, analysis),

                  SizedBox(height: SizeConfig.height(35)),

                  Text(
                    "SWOT Analysis",
                    style: AppTextStyles.headingMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: SizeConfig.height(16)),

                  InteractiveSwotMatrix(insights: insights),

                  SizedBox(height: SizeConfig.height(20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitorList(
    BuildContext context,
    CompetitorAnalysis analysis,
  ) {
    if (analysis.topCompetitors.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: analysis.topCompetitors.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: SizeConfig.height(12)),
      itemBuilder: (context, index) {
        final comp = analysis.topCompetitors[index];
        return InkWell(
          onTap: () {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(comp.coordinates.lat, comp.coordinates.lng),
                17.0,
              ),
            );
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: CompetitorInfoCard(
            name: comp.name,
            rating: comp.rating.toDouble(),
            distance: "${comp.distanceMeters.toStringAsFixed(0)} m",
            location: comp.location,
            imageUrl: comp.imageUrl.isNotEmpty
                ? comp.imageUrl
                : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQXibKgduo4qrBxPHetOiSQN6_Ywpxt5fONHw&s",
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 48,
            color: theme.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Blue Ocean Potential",
            style: AppTextStyles.headingMedium(
              context,
            ).copyWith(color: theme.primaryColor, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            "No direct competitors found in this immediate zone. You have a high chance of capturing the market here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], height: 1.5),
          ),
        ],
      ),
    );
  }

  Color _getCompetitionColor(String level) {
    level = level.toLowerCase();
    if (level.contains("low") || level.contains("unsat")) return Colors.green;
    if (level.contains("moderate") || level.contains("medium"))
      return Colors.blue;
    if (level.contains("high") || level.contains("sat")) return Colors.red;
    return Theme.of(context).primaryColor;
  }
}
