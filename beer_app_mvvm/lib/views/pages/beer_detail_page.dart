import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/beer_data.dart';
import '../../viewmodels/beer_detail_viewmodel.dart';
import '../../utils/theme.dart';

class BeerDetailPage extends StatelessWidget {
  final BeerData beer;

  const BeerDetailPage({
    super.key,
    required this.beer,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BeerDetailViewModel()..setBeerData(beer),
      child: Consumer<BeerDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.beerName),
              actions: [
                IconButton(
                  icon: Icon(
                    viewModel.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: viewModel.isFavorite ? Colors.red : null,
                  ),
                  onPressed: viewModel.toggleFavorite,
                ),
              ],
            ),
            body: _buildBody(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BeerDetailViewModel viewModel) {
    if (!viewModel.hasBeerData) {
      return const Center(
        child: Text('ビール情報が見つかりません'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBeerImage(viewModel),
            const SizedBox(height: 24),
            _buildBeerInfo(viewModel),
            const SizedBox(height: 16),
            _buildBeerDescription(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildBeerImage(BeerDetailViewModel viewModel) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          viewModel.beerImageUrl,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_drink,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '画像を読み込めません',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBeerInfo(BeerDetailViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          viewModel.beerName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColorLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            viewModel.beerCategory,
            style: AppTheme.captionStyle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBeerDescription(BeerDetailViewModel viewModel) {
    return Text(
      viewModel.beerDescription,
      style: AppTheme.bodyStyle,
    );
  }
}