import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/generate_viewmodel.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../widgets/loading_widget.dart' as custom_widgets;

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GenerateViewModel(),
      child: Consumer<GenerateViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(AppConstants.generateTitle),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputSection(viewModel),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _buildResultSection(viewModel),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputSection(GenerateViewModel viewModel) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: AppConstants.beerNameHint,
          ),
          onChanged: viewModel.updateInputText,
          onSubmitted: (_) => _handleGenerate(viewModel),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: viewModel.canGenerate ? () => _handleGenerate(viewModel) : null,
            child: viewModel.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  )
                : const Text(AppConstants.searchButton),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection(GenerateViewModel viewModel) {
    if (viewModel.isLoading) {
      return const custom_widgets.LoadingWidget(message: AppConstants.generating);
    }

    if (viewModel.hasError) {
      return custom_widgets.ErrorWidget(
        message: viewModel.errorMessage,
        onRetry: () => _handleGenerate(viewModel),
      );
    }

    if (viewModel.hasResult) {
      return _buildBeerResult(viewModel);
    }

    return const custom_widgets.EmptyWidget(
      message: 'ご飯の名前を入力してうんちくを生成してください',
      icon: Icons.search,
    );
  }

  Widget _buildBeerResult(GenerateViewModel viewModel) {
    final beer = viewModel.generatedBeer!;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '生成結果',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: viewModel.clearResult,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (beer.imageUrl.isNotEmpty) ...[
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  beer.imageUrl,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_drink,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            beer.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            beer.description,
            style: AppTheme.bodyStyle,
          ),
        ],
      ),
    );
  }

  void _handleGenerate(GenerateViewModel viewModel) {
    if (viewModel.canGenerate) {
      viewModel.generateBeerData();
    }
  }
}