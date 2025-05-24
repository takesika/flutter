import 'package:flutter/material.dart';

class BeerDetailPage extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String description;

  const BeerDetailPage({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.teal.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                description,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
