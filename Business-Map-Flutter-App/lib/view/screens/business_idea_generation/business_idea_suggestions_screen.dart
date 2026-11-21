import 'package:business_map/provider/business/business_idea_provider.dart';
import 'package:business_map/core/routes/routes_name.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/others/general_item_card.dart';
import 'package:business_map/view/custom_widgets/state/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusinessIdeaSuggestionsScreen extends StatefulWidget {
  const BusinessIdeaSuggestionsScreen({super.key});

  @override
  State<BusinessIdeaSuggestionsScreen> createState() =>
      _BusinessIdeaSuggestionsScreenState();
}

class _BusinessIdeaSuggestionsScreenState
    extends State<BusinessIdeaSuggestionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Business Ideas")),
      body: Consumer<BusinessIdeaProvider>(
        builder: (context, provider, _) {
          final ideas = provider.suggestedIdeas;
          final targetArea =
              provider.suggestionResponse?.requestSummary?.targetArea ??
              "New Opportunity";

          if (ideas.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.lightbulb_outline,
              title: "No Ideas Found",
              subtitle: "Try adjusting your criteria and generate again.",
              usePrimaryTint: true,
              actionLabel: "Adjust Criteria",
              onAction: () => Navigator.pop(context),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.width(20),
              vertical: SizeConfig.height(20),
            ),
            itemCount: ideas.length,
            itemBuilder: (context, index) {
              final idea = ideas[index];
              return GeneralItemCard(
                name: idea.businessName,
                location: targetArea,
                description: idea.description,
                usp: idea.usp,
                imageUrl: idea.images.isNotEmpty
                    ? idea.images[0]
                    : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5y32GroAEL8FFTa0zVbLMIMrrqCEFqKDASQ&s",
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RoutesName.businessIdeaDetailScreen,
                    arguments: idea,
                  );
                },
              );
            },
            separatorBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: SizeConfig.height(10)),
                child: const Divider(indent: 0, endIndent: 0),
              );
            },
          );
        },
      ),
    );
  }
}
