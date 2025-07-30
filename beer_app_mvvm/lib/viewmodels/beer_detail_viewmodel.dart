import 'package:flutter/foundation.dart';
import '../models/beer_data.dart';

class BeerDetailViewModel extends ChangeNotifier {
  BeerData? _beerData;
  bool _isFavorite = false;

  BeerData? get beerData => _beerData;
  bool get isFavorite => _isFavorite;
  bool get hasBeerData => _beerData != null;

  String get beerName => _beerData?.name ?? '';
  String get beerDescription => _beerData?.description ?? '';
  String get beerImageUrl => _beerData?.imageUrl ?? '';
  String get beerCategory => _beerData?.category ?? '';

  void setBeerData(BeerData beerData) {
    _beerData = beerData;
    _loadFavoriteStatus();
    notifyListeners();
  }

  void _loadFavoriteStatus() {
    // TODO: Implement favorite status loading from local storage
    _isFavorite = false;
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    _saveFavoriteStatus();
    notifyListeners();
  }

  void _saveFavoriteStatus() {
    // TODO: Implement favorite status saving to local storage
  }

  void clear() {
    _beerData = null;
    _isFavorite = false;
    notifyListeners();
  }
}