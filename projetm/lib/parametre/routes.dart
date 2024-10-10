import 'package:go_router/go_router.dart';

import '../authentification/inscription.dart';
import '../authentification/login_page.dart';
import '../mobiles/acceuil/accueil.dart';
import '../mobiles/acceuil/histoire.dart';
import '../mobiles/notification/notification.dart';
import '../mobiles/profile/profile.dart';

/*
          '/dashboard': (context) => MainScreen(),
          '/utilisateur': (context) => UserPage(),
          '/publication': (context) => PublicationPage(),
          '/signale': (context) => SignalePage(),
          '/profile_admin': (context) => ProfilePage(),
          '/messager': (context) => MessagePage(),
*/


final routerConfig = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) =>  Accueil(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) =>  Profile(),
    ),
    GoRoute(
      path: '/entry-point',
      builder: (context, state) => Inscription(),
    ),

    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const NotificationPage(),
    ),
    GoRoute(
      path: '/resend-email-verification',
      builder: (context, state) => const Histoire(),
    ),

    // GoRoute(
    //   path: '/password-confirmation/:email',
    //   builder: (context, state) {
    //     final email = state.pathParameters['email'];
    //     if (email == null) {
    //       throw Exception('Recipe ID is missing');
    //     }
    //     return PasswordConfirmationForm(email: email);
    //   },
    // ),

    // GoRoute(
    //   path: '/user-confirmation/:email',
    //   builder: (context, state) {
    //     final email = state.pathParameters['email'];
    //     if (email == null) {
    //       throw Exception('Recipe ID is missing');
    //     }
    //     return UserConfirmationForm(email: email);
    //   },
    // ),
    // GoRoute(
    //   path: '/favorite',
    //   builder: (context, state) => const FavoriteScreen(),
    // ),
    // GoRoute(
    //   path: '/recipe/:id',
    //   builder: (context, state) {
    //     final id = state.pathParameters['id'];
    //     if (id == null) {
    //       throw Exception('Recipe ID or Favorite state is missing');
    //     }
    //     return RecipeDetailsScreen(
    //       id: id,
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: '/profile',
    //   builder: (context, state) => const ProfileScreen(),
    // ),
    // GoRoute(
    //   path: '/edit-profile',
    //   builder: (context, state) => const EditProfileScreen(),
    // ),
    // GoRoute(
    //   path: '/all-recipes',
    //   builder: (context, state) => const AllRecipesScreen(),
    // ),
    // GoRoute(
    //   path: '/search-recipes',
    //   builder: (context, state) => const SearchScreen(),
    // ),
    // GoRoute(
    //   path: '/notifications',
    //   builder: (context, state) => const NotificationsScreen(),
    // ),
  ],
);
