import 'package:aicc/features/artist_profile/data/datasource/portfolio_data.dart';
import 'package:flutter/material.dart';

import '../../data/models/portfolio_model.dart';
import 'portfolio_card.dart';

class PortfolioGrid extends StatelessWidget {
  final List<PortfolioModel> items;

  const PortfolioGrid({
    super.key,
    required this.items,
  });
  @override
  Widget build(BuildContext context) {
    return GridView.builder(

      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: portfolioList.length,

      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: .82,
      ),

      itemBuilder: (_, index) {
        return PortfolioCard(
          item: portfolioList[index],
        );
      },
    );
  }
}