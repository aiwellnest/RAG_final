import 'package:ai_wellnest_frontend/provider/auth_provider.dart';
import 'package:ai_wellnest_frontend/screen/auth_screen/screens/sign_in_screen.dart';
import 'package:ai_wellnest_frontend/screen/auth_screen/screens/sign_up_screen.dart';
import 'package:ai_wellnest_frontend/screen/loading_screen/loading_screen.dart';
import 'package:ai_wellnest_frontend/screen/main_screen/main_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  GoRouter get router => GoRouter(
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const MainScreen(),
          ),
          GoRoute(
            path: '/signin',
            builder: (context, state) => const SignInScreen(),
          ),
          GoRoute(
            path: '/signup',
            builder: (context, state) => const SignUpScreen(),
          ),
          GoRoute(
            path: '/loading',
            builder: (context, state) => const LoadingScreen(),
          ),
        ],
        redirect: (context, state) {
          if (authProvider.isCheckingAuthState) {
            return '/loading';
          }

          final bool isSignedIn = authProvider.isSignedIn;
          final bool isOnSignInOrSignUp =
              state.fullPath == '/signin' || state.fullPath == '/signup';

          if (!isSignedIn && !isOnSignInOrSignUp) {
            return '/signin';
          }

          if (isSignedIn &&
              (isOnSignInOrSignUp || state.fullPath == '/loading')) {
            return '/home';
          }

          return null;
        },
        refreshListenable: authProvider,
      );
}
