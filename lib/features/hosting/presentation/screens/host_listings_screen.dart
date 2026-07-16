import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/features/hosting/presentation/providers/host_listings_provider.dart';
import 'package:quintou_app/features/spaces/presentation/widgets/space_list_card.dart';
import 'package:go_router/go_router.dart';

class HostListingsScreen extends ConsumerWidget {
  const HostListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(hostListingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Meus Anúncios', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: listingsAsync.when(
        data: (listings) {
          if (listings.isEmpty) {
            return const Center(child: Text('Você ainda não possui anúncios.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(hostListingsProvider.future),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: listings.length,
              separatorBuilder: (_, __) => const SizedBox.shrink(),
              itemBuilder: (context, index) {
                final space = listings[index];
                return SpaceListCard(
                  space: space,
                  onTap: () {
                    context.push('/space-details', extra: space);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }
}
