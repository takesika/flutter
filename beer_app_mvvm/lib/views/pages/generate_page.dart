import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/generate_viewmodel.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../utils/rate_limiter.dart';
import '../widgets/loading_widget.dart' as custom_widgets;

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = GenerateViewModel();
        viewModel.initialize(); // 初期化
        return viewModel;
      },
      child: Consumer<GenerateViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(AppConstants.generateTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showUsageInfo(context, viewModel),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUsageStatus(viewModel),
                  const SizedBox(height: 16),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLength: viewModel.maxCharacterCount,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration: InputDecoration(
            hintText: AppConstants.beerNameHint,
            errorText: viewModel.validationError,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      viewModel.updateInputText('');
                    },
                  )
                : null,
            helperText: '文字数: ${viewModel.characterCount}/${viewModel.maxCharacterCount}',
            counterText: '',
          ),
          onChanged: viewModel.updateInputText,
          onSubmitted: (_) => _handleGenerate(viewModel),
          textInputAction: TextInputAction.search,
        ),
        const SizedBox(height: 8),
        if (!viewModel.canGenerate && viewModel.isValidInput)
          _buildRateLimitInfo(viewModel),
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
  
  Widget _buildRateLimitInfo(GenerateViewModel viewModel) {
    final timeUntil = viewModel.getTimeUntilNextRequest();
    if (timeUntil == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Colors.orange[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${timeUntil.inSeconds}秒後に再実行できます',
              style: TextStyle(color: Colors.orange[700], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUsageStatus(GenerateViewModel viewModel) {
    // 1日の利用制限に達した場合のみ表示
    if (viewModel.remainingDaily <= 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[700], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今日の利用上限に達しました',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${viewModel.dailyUsage} / ${viewModel.maxDailyUsage}回 使用済み',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[600],
                    ),
                  ),
                  Text(
                    '明日またお試しください',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // 制限に達していない場合は何も表示しない
    return const SizedBox.shrink();
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

  void _handleGenerate(GenerateViewModel viewModel) async {
    if (viewModel.canGenerate && await viewModel.checkCanGenerate()) {
      _focusNode.unfocus(); // キーボードを閉じる
      viewModel.generateBeerData();
    } else {
      // バリデーションエラーの場合、フィードバックを表示
      String errorMessage = '';
      if (viewModel.validationError != null) {
        errorMessage = viewModel.validationError!;
      } else if (!(await viewModel.checkCanGenerate())) {
        final rateLimiter = RateLimiter();
        errorMessage = await rateLimiter.getErrorMessage('generate');
      }
      
      if (errorMessage.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
  
  void _showUsageInfo(BuildContext context, GenerateViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('利用状況'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('今日: ${viewModel.dailyUsage}/${viewModel.maxDailyUsage}回'),
            Text('今月: ${viewModel.monthlyUsage}/${viewModel.maxMonthlyUsage}回'),
            Text('総利用回数: ${viewModel.totalUsage}回'),
            const SizedBox(height: 16),
            const Text(
              '• 1日最大20回まで利用可能\n'
              '• 1ヶ月最大600回まで利用可能\n'
              '• 連続使用は5秒間隔で制限',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}