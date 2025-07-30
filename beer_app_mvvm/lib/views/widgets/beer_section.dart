import 'package:flutter/material.dart';
import '../../models/beer_category.dart';
import '../../models/beer_data.dart';
import 'beer_card.dart';

class BeerSection extends StatelessWidget {
  final BeerCategory category;
  final Function(BeerData) onBeerTap;

  const BeerSection({
    super.key,
    required this.category,
    required this.onBeerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: category.beers.length,
              itemBuilder: (context, index) {
                final beer = category.beers[index];
                return BeerCard(
                  beer: beer,
                  onTap: () => onBeerTap(beer),
                  isHorizontal: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}