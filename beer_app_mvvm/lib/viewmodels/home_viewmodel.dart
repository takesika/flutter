import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void resetToHome() {
    setSelectedIndex(0);
  }
}