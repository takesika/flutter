import 'package:flutter_test/flutter_test.dart';
import 'package:beer_app_mvvm/viewmodels/home_viewmodel.dart';

void main() {
  group('HomeViewModel', () {
    late HomeViewModel viewModel;

    setUp(() {
      viewModel = HomeViewModel();
    });

    test('initial selectedIndex should be 0', () {
      expect(viewModel.selectedIndex, 0);
    });

    test('setSelectedIndex should update selectedIndex and notify listeners', () {
      bool listenerCalled = false;
      viewModel.addListener(() {
        listenerCalled = true;
      });

      viewModel.setSelectedIndex(1);

      expect(viewModel.selectedIndex, 1);
      expect(listenerCalled, true);
    });

    test('setSelectedIndex with same index should not notify listeners', () {
      bool listenerCalled = false;
      viewModel.setSelectedIndex(1); // Set to 1 first
      
      viewModel.addListener(() {
        listenerCalled = true;
      });

      viewModel.setSelectedIndex(1); // Set to same value

      expect(viewModel.selectedIndex, 1);
      expect(listenerCalled, false);
    });

    test('resetToHome should set selectedIndex to 0', () {
      viewModel.setSelectedIndex(2);
      expect(viewModel.selectedIndex, 2);

      viewModel.resetToHome();
      expect(viewModel.selectedIndex, 0);
    });
  });
}