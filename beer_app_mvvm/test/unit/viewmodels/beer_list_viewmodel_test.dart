import 'package:flutter_test/flutter_test.dart';
import 'package:beer_app_mvvm/viewmodels/beer_list_viewmodel.dart';

void main() {
  group('BeerListViewModel', () {
    late BeerListViewModel viewModel;

    setUp(() {
      viewModel = BeerListViewModel();
    });

    test('initial state should have categories loaded', () {
      expect(viewModel.categories.isNotEmpty, true);
      expect(viewModel.searchQuery.isEmpty, true);
      expect(viewModel.isSearching, false);
      expect(viewModel.hasSearchResults, false);
    });

    test('updateSearchQuery should update search state', () {
      viewModel.updateSearchQuery('アサヒ');

      expect(viewModel.searchQuery, 'アサヒ');
      expect(viewModel.isSearching, true);
      expect(viewModel.searchResults.isNotEmpty, true);
    });

    test('updateSearchQuery with empty string should clear search', () {
      viewModel.updateSearchQuery('アサヒ');
      expect(viewModel.isSearching, true);

      viewModel.updateSearchQuery('');
      expect(viewModel.isSearching, false);
      expect(viewModel.searchResults.isEmpty, true);
    });

    test('clearSearch should reset search state', () {
      viewModel.updateSearchQuery('キリン');
      expect(viewModel.isSearching, true);

      viewModel.clearSearch();
      expect(viewModel.searchQuery.isEmpty, true);
      expect(viewModel.isSearching, false);
      expect(viewModel.searchResults.isEmpty, true);
    });

    test('findBeerByName should return correct beer', () {
      final beer = viewModel.findBeerByName('アサヒ スーパードライ');
      expect(beer, isNotNull);
      expect(beer!.name, 'アサヒ スーパードライ');
    });

    test('findBeerByName with non-existent name should return null', () {
      final beer = viewModel.findBeerByName('存在しないビール');
      expect(beer, isNull);
    });

    test('getBeersByCategory should return beers for valid category', () {
      final beers = viewModel.getBeersByCategory('ラガー');
      expect(beers.isNotEmpty, true);
      expect(beers.every((beer) => beer.category == 'ラガー'), true);
    });

    test('getBeersByCategory with invalid category should return empty list', () {
      final beers = viewModel.getBeersByCategory('存在しないカテゴリ');
      expect(beers.isEmpty, true);
    });
  });
}