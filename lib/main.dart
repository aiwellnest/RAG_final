import 'package:ai_wellnest_frontend/repository/auth_repository.dart';
import 'package:ai_wellnest_frontend/repository/chat_repository.dart';
import 'package:ai_wellnest_frontend/firebase_options.dart';
import 'package:ai_wellnest_frontend/provider/auth_provider.dart';
import 'package:ai_wellnest_frontend/provider/chat_provider.dart';
import 'package:ai_wellnest_frontend/routes/router.dart';
import 'package:ai_wellnest_frontend/theme/color_pallete.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AIWellnestApp());
}

class AIWellnestApp extends StatefulWidget {
  const AIWellnestApp({super.key});

  @override
  State<AIWellnestApp> createState() => _AIWellnestAppState();
}

class _AIWellnestAppState extends State<AIWellnestApp> {
  late AuthProvider authProvider;
  late ChatProvider chatProvider;
  late AppRouter appRouter;

  @override
  void initState() {
    super.initState();

    final authRepository = AuthRepository();
    authProvider = AuthProvider(authRepository);

    final chatRepository = ChatRepository();
    chatProvider = ChatProvider(chatRepository);

    appRouter = AppRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => authProvider),
        ChangeNotifierProvider(create: (context) => chatProvider),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'AI Wellnest',
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: ColorPallete.darkGreenColor),
          useMaterial3: true,
        ),
        routerConfig: appRouter.router,
      ),
    );
  }
}
