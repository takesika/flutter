import 'beer_data.dart';

class BeerCategory {
  final String title;
  final List<BeerData> beers;

  BeerCategory({
    required this.title,
    required this.beers,
  });

  factory BeerCategory.fromJson(Map<String, dynamic> json) {
    return BeerCategory(
      title: json['title'] ?? '',
      beers: (json['beers'] as List<dynamic>?)
              ?.map((beer) => BeerData.fromJson(beer))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'beers': beers.map((beer) => beer.toJson()).toList(),
    };
  }
}