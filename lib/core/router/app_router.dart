import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/memories/presentation/memories_screen.dart';
import '../../screens/entry_screen.dart';
import '../../features/memories/presentation//memory_details_screen.dart';
import '../../screens/map_screen.dart';

final routerProvider = Provider<GoRouter>((ref) => appRouter);

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MemoriesScreen(),
    ),
    GoRoute(
      path: '/new',
      builder: (context, state) => const EntryScreen(),
    ),
    GoRoute(
      path: '/memory/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return MemoryDetailScreen(memoryId: id);
      },
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapScreen(),
    ),
  ],
);