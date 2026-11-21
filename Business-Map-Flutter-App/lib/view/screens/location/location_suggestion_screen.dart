import 'package:business_map/provider/location/location_provider.dart';
import 'package:business_map/core/routes/routes_name.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/button/app_primary_button.dart';
import 'package:business_map/view/custom_widgets/others/custom_chip.dart';
import 'package:business_map/view/custom_widgets/state/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../data/model/response/location_suggestion_response.dart';
import '../../../utils/app_text_style.dart';

class LocationSuggestionScreen extends StatefulWidget {
  const LocationSuggestionScreen({super.key});

  @override
  State<LocationSuggestionScreen> createState() =>
      _LocationSuggestionScreenState();
}

class _LocationSuggestionScreenState extends State<LocationSuggestionScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller, LocationProvider provider) {
    _mapController = controller;
    _updateMarkers(provider);
  }

  void _updateMarkers(LocationProvider provider) {
    if (provider.suggestionResponse == null) return;

    final locations = provider.suggestionResponse!.topLocations;
    if (locations.isEmpty) return;

    setState(() {
      _markers = locations.map((loc) {
        return Marker(
          markerId: MarkerId(loc.id),
          position: LatLng(loc.coordinates.lat, loc.coordinates.lng),
          infoWindow: InfoWindow(
            title: loc.locationName,
            snippet: loc.suitability.tags.join(', '),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        );
      }).toSet();
    });

    if (locations.isNotEmpty) {
      _fitBounds(locations);
    }
  }

  void _fitBounds(List<dynamic> locations) {
    if (_mapController == null) return;

    double? minLat, maxLat, minLng, maxLng;

    for (var loc in locations) {
      double lat = loc.coordinates.lat;
      double lng = loc.coordinates.lng;

      if (minLat == null || lat < minLat) minLat = lat;
      if (maxLat == null || lat > maxLat) maxLat = lat;
      if (minLng == null || lng < minLng) minLng = lng;
      if (maxLng == null || lng > maxLng) maxLng = lng;
    }

    if (minLat == null || maxLat == null || minLng == null || maxLng == null) return;

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        SizeConfig.width(100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final locations = locationProvider.suggestionResponse?.topLocations ?? [];

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Text(
                "Strategic Matches",
                style: AppTextStyles.headingMedium(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  onMapCreated: (controller) => _onMapCreated(controller, locationProvider),
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(33.6844, 73.0479),
                    zoom: 12.0,
                  ),
                  markers: _markers,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: false,
                  padding: EdgeInsets.only(bottom: SizeConfig.height(300)),
                ),
              ),

              Positioned(
                right: 16,
                top: MediaQuery.of(context).padding.top + 70,
                child: Column(
                  children: [
                    _buildFloatingAction(Icons.my_location_rounded, () => _fitBounds(locations)),
                    const SizedBox(height: 12),
                    _buildFloatingAction(Icons.layers_rounded, () {}),
                  ],
                ),
              ),

              if (locations.isEmpty)
                _buildNoLocationsFound(
                  context,
                  locationProvider.suggestionResponse?.message ?? "No Strategic Matches Found",
                )
              else
                _buildDraggableBottomSheet(context, locations),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingAction(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildNoLocationsFound(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white.withOpacity(0.95),
      child: EmptyStateWidget(
        icon: Icons.explore_off_rounded,
        title: "No Strategic Matches",
        subtitle: message,
        usePrimaryTint: true,
        actionLabel: "Adjust Criteria",
        onAction: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildDraggableBottomSheet(BuildContext context, List<dynamic> locations) {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.18,
      maxChildSize: 0.85,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 25, spreadRadius: -5)],
          ),
          child: ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.zero,
            itemCount: locations.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: Colors.transparent, 
                      child: Center(
                        child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("${locations.length} Sites Identified", style: AppTextStyles.headingMedium(context).copyWith(fontSize: 16, fontWeight: FontWeight.w800)),
                          Text("Ranked by strategic suitability", style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildLocationCard(context, locations[index - 1], index - 1),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLocationCard(BuildContext context, TopLocation loc, int index) {
    final theme = Theme.of(context);
    final int? suitabilityScore = loc.matchPercentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(loc.coordinates.lat, loc.coordinates.lng), 16.0),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.location_on_rounded, color: theme.primaryColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.locationName, style: AppTextStyles.headingMedium(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(loc.location, style: TextStyle(color: Colors.grey[500], fontSize: 11, height: 1.3), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (suitabilityScore != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: suitabilityScore > 90 ? Colors.green[50] : Colors.blue[50], 
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text("$suitabilityScore%", style: TextStyle(color: suitabilityScore > 90 ? Colors.green[700] : Colors.blue[700], fontSize: 10, fontWeight: FontWeight.w900)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                if (loc.suitability.tags.isNotEmpty)
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: loc.suitability.tags.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final tag = loc.suitability.tags[index];
                        return CustomChip(
                          label: tag,
                          color: Colors.grey[700],
                          backgroundColor: Colors.grey[50],
                          fontSize: 10,
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 18),
                AppPrimaryButton(
                  text: "View Details",
                  onPressed: () => Navigator.pushNamed(context, RoutesName.locationDetailScreen, arguments: loc),
                  verticalPadding: 12,
                  textSize: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
