import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quintou_app/features/spaces/presentation/providers/spaces_provider.dart';
import 'package:quintou_app/features/spaces/presentation/widgets/space_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacesAsyncValue = ref.watch(spacesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Quintou',
          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: spacesAsyncValue.when(
        data: (spaces) {
          if (spaces.isEmpty) {
            return const Center(child: Text('Nenhum espaço encontrado.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(spacesProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: spaces.length,
              itemBuilder: (context, index) {
                return SpaceCard(
                  space: spaces[index],
                  onTap: () {
                    context.push('/space-details', extra: spaces[index]);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro ao carregar os espaços: $error')),
      ),
    );
  }
}

