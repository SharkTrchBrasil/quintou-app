import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/providers/providers.dart';

final hostDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(hostRepositoryProvider);
  return await repo.getDashboard();
});
