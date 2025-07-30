import 'package:flutter/foundation.dart';
import '../models/beer_category.dart';
import '../models/beer_data.dart';
import '../repositories/beer_repository.dart';

class BeerListViewModel extends ChangeNotifier {
  final BeerRepository _beerRepository = BeerRepository();
  
  List<BeerCategory> _categories = [];
  String _searchQuery = '';
  List<BeerData> _searchResults = [];
  bool _isSearching = false;

  List<BeerCategory> get categories => _categories;
  String get searchQuery => _searchQuery;
  List<BeerData> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get hasSearchResults => _searchResults.isNotEmpty;

  BeerListViewModel() {
    _loadCategories();
  }

  void _loadCategories() {
    _categories = _beerRepository.getBeerCategories();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _isSearching = query.isNotEmpty;
    
    if (_isSearching) {
      _searchResults = _beerRepository.searchBeers(query);
    } else {
      _searchResults = [];
    }
    
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    _searchResults = [];
    notifyListeners();
  }

  BeerData? findBeerByName(String name) {
    return _beerRepository.findBeerByName(name);
  }

  List<BeerData> getBeersByCategory(String categoryName) {
    final category = _categories.firstWhere(
      (cat) => cat.title == categoryName,
      orElse: () => BeerCategory(title: '', beers: []),
    );
    return category.beers;
  }
}