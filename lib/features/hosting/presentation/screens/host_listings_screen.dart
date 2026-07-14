import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/features/hosting/presentation/providers/host_listings_provider.dart';

class HostListingsScreen extends ConsumerWidget {
  const HostListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(hostListingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              // Navigate to create space screen
            },
          )
        ],
      ),
      body: listingsAsync.when(
        data: (spaces) {
          if (spaces.isEmpty) {
            return const Center(child: Text('You have no listings.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: spaces.length,
            itemBuilder: (context, index) {
              final space = spaces[index];
              final imageUrl = space.images.isNotEmpty ? space.images.first.url : null;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: imageUrl != null
                      ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                      : Container(width: 60, height: 60, color: Colors.grey),
                  title: Text(space.title),
                  subtitle: Text('\$${space.price.toStringAsFixed(2)}/hr • ${space.city}'),
                  trailing: const Icon(Icons.public), // Assumes all spaces returned here are published
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
