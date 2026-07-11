import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';

class SpaceDetailsScreen extends ConsumerWidget {
  final Space space;

  const SpaceDetailsScreen({super.key, required this.space});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: space.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: space.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          space.images[index].url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => _buildPlaceholder(),
                        );
                      },
                    )
                  : _buildPlaceholder(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  if (authState.user == null) {
                    context.push('/login');
                  } else {
                    // TODO: call favoritar API
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    space.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        space.averageRating > 0 ? space.averageRating.toStringAsFixed(1) : 'Novo',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(' (${space.totalReviews} avaliações)', style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on, color: Colors.grey.shade600, size: 18),
                      Text('${space.city}, ${space.state}', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  const Divider(height: 40),
                  Text(
                    'Sobre este espaço',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    space.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.5),
                  ),
                  const Divider(height: 40),
                  Text(
                    'O que o espaço oferece',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // TODO: Lista de comodidades
                  const SizedBox(height: 100), // padding para o bottom bar
                ],
              ),
            ),
          )
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'R\$ ${space.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'por ${space.pricingType == 'hourly' ? 'hora' : 'dia'}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (authState.user == null) {
                    context.push('/login');
                  } else {
                    context.push('/booking-setup', extra: space);
                  }
                },
                child: const Text('Agendar', style: TextStyle(fontSize: 18, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }
}
