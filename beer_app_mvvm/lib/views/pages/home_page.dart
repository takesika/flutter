import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import 'beer_list_page.dart';
import 'generate_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              AppConstants.appTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  AppConstants.appDescription,
                  textAlign: TextAlign.center,
                  style: AppTheme.headingStyle,
                ),
                const SizedBox(height: 100),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BeerListPage(),
                      ),
                    );
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_drink, size: 28),
                      SizedBox(height: 4),
                      Text(AppConstants.selectBeerButton),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GeneratePage(),
                      ),
                    );
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.search, size: 28),
                      SizedBox(height: 4),
                      Text(AppConstants.generateBeerButton),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: AppConstants.homeLabel,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: AppConstants.selectLabel,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome),
                label: AppConstants.generateLabel,
              ),
            ],
            currentIndex: viewModel.selectedIndex,
            onTap: (index) {
              viewModel.setSelectedIndex(index);
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BeerListPage(),
                  ),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GeneratePage(),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}