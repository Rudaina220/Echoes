import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../screens/entry_screen.dart';
import '../../features/memories/presentation/memories_screen.dart';
import '../../features/memories/presentation//memory_details_screen.dart';
import '../../screens/map_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MemoriesScreen(),
      ),
      GoRoute(
        path: '/new',
        name: 'new-entry',
        builder: (context, state) => const EntryScreen(),
      ),
      GoRoute(
        path: '/memory/:id',
        name: 'memory-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MemoryDetailScreen(memoryId: id);
        },
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) => const MapScreen(),
      ),
    ],
  );
});