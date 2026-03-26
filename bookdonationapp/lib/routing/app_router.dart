import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/auth_provider.dart';
import '../features/screens/splash_screen.dart';
import '../features/screens/onboarding_screen.dart';
import '../features/screens/login_screen.dart';
import '../features/screens/signup_screen.dart';
import '../features/screens/home_screen.dart';
import '../features/screens/donate_screen.dart';
import '../features/screens/requests_screen.dart';
import '../features/screens/ebook_listing_screen.dart' show EBookListingScreen;
import '../features/screens/chat_list_screen.dart';
import '../features/screens/chat_screen.dart';
import '../features/screens/profile_screen.dart';
import '../features/screens/edit_profile_screen.dart';
import '../features/screens/book_detail_screen.dart';
import '../features/screens/settings_screen.dart';
import '../features/screens/qr_screen.dart';
import '../features/screens/rewards_screen.dart';
import '../features/screens/eco_tracker_screen.dart';
import '../features/screens/community_screen.dart';
import '../features/screens/language_settings_screen.dart';
import '../features/screens/voice_settings_screen.dart';
import '../features/screens/location_settings_screen.dart';
import '../features/screens/set_location_screen.dart';
import '../features/screens/payment_screen.dart';
import '../features/screens/widgets/bottom_nav_bar.dart';
import '../features/screens/widgets/floating_action_buttons_group.dart';
import '../features/screens/widgets/page_with_floating_buttons.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Don't redirect from splash screen - let it handle navigation
      if (state.matchedLocation == '/') {
        return null;
      }

      final isLoggedIn = authState.hasValue && authState.value != null;
      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/onboarding';

      // If not logged in and not on auth pages, redirect to login
      if (!isLoggedIn && !isOnAuthPage) {
        return '/login';
      }

      // If logged in and on auth pages, redirect to home
      if (isLoggedIn && isOnAuthPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      // Shell route for bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: Stack(
              children: [
                child,
                const FloatingActionButtonsGroup(),
              ],
            ),
            bottomNavigationBar: const BottomNavBar(),
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/donate',
            builder: (context, state) => const DonateScreen(),
          ),
          GoRoute(
            path: '/requests',
            builder: (context, state) => const RequestsScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
        ],
      ),
      // Other routes (no bottom nav, but with floating buttons)
      GoRoute(
        path: '/ebook-list',
        builder: (context, state) => const PageWithFloatingButtons(
          child: EBookListingScreen(),
        ),
      ),
      GoRoute(
        path: '/book-detail/:id',
        builder: (context, state) {
          final bookId = state.pathParameters['id']!;
          return PageWithFloatingButtons(
            child: BookDetailScreen(bookId: bookId),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const PageWithFloatingButtons(
          child: SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/qr',
        builder: (context, state) => const PageWithFloatingButtons(
          child: QRScreen(),
        ),
      ),
      GoRoute(
        path: '/rewards',
        builder: (context, state) => const PageWithFloatingButtons(
          child: RewardsScreen(),
        ),
      ),
      GoRoute(
        path: '/eco-tracker',
        builder: (context, state) => const PageWithFloatingButtons(
          child: EcoTrackerScreen(),
        ),
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const PageWithFloatingButtons(
          child: CommunityScreen(),
        ),
      ),
      GoRoute(
        path: '/language-settings',
        builder: (context, state) => const PageWithFloatingButtons(
          child: LanguageSettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/voice-settings',
        builder: (context, state) => const PageWithFloatingButtons(
          child: VoiceSettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/location-settings',
        builder: (context, state) => const PageWithFloatingButtons(
          child: LocationSettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/set-location',
        builder: (context, state) => const PageWithFloatingButtons(
          child: SetLocationScreen(),
        ),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return PageWithFloatingButtons(
            child: ChatScreen(chatId: chatId),
          );
        },
      ),
      GoRoute(
        path: '/payment/:id',
        builder: (context, state) {
          final bookId = state.pathParameters['id']!;
          return PageWithFloatingButtons(
            child: PaymentScreen(bookId: bookId),
          );
        },
      ),
    ],
  );
});
