import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:dcj_recipe_app/features/recipes/presentation/pages/xport_pages.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/recipe/:id',
        name: 'recipe-detail',
        pageBuilder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          final recipe = state.extra as Recipe;
          return CustomTransitionPage(
            child: RecipeDetailPage(recipeId: recipeId, recipe: recipe),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SearchPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/no-connection',
        name: 'no-connection',
        pageBuilder: (context, state) => const MaterialPage(
          child: NoConnectionPage(),
        ),
      ),
    ],
  );
}
