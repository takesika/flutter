import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/beer_list_viewmodel.dart';
import '../../utils/constants.dart';
import '../widgets/beer_section.dart';
import '../widgets/beer_card.dart';
import '../widgets/loading_widget.dart';
import 'beer_detail_page.dart';

class BeerListPage extends StatefulWidget {
  const BeerListPage({super.key});

  @override
  State<BeerListPage> createState() => _BeerListPageState();
}

class _BeerListPageState extends State<BeerListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BeerListViewModel(),
      child: Consumer<BeerListViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(AppConstants.beerListTitle),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: AppConstants.searchHint,
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: viewModel.updateSearchQuery,
                  ),
                ),
              ),
            ),
            body: _buildBody(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BeerListViewModel viewModel) {
    if (viewModel.isSearching) {
      return _buildSearchResults(viewModel);
    } else {
      return _buildCategoryList(viewModel);
    }
  }

  Widget _buildSearchResults(BeerListViewModel viewModel) {
    if (!viewModel.hasSearchResults) {
      return const EmptyWidget(
        message: '検索結果が見つかりませんでした',
        icon: Icons.search_off,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final beer = viewModel.searchResults[index];
        return BeerCard(
          beer: beer,
          isHorizontal: false,
          onTap: () => _navigateToBeerDetail(beer),
        );
      },
    );
  }

  Widget _buildCategoryList(BeerListViewModel viewModel) {
    if (viewModel.categories.isEmpty) {
      return const LoadingWidget(message: AppConstants.loading);
    }

    return ListView.builder(
      itemCount: viewModel.categories.length,
      itemBuilder: (context, index) {
        final category = viewModel.categories[index];
        return BeerSection(
          category: category,
          onBeerTap: _navigateToBeerDetail,
        );
      },
    );
  }

  void _navigateToBeerDetail(beer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BeerDetailPage(beer: beer),
      ),
    );
  }
}