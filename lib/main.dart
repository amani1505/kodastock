import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/theme/light_theme.dart';
import 'core/config/theme/dark_theme.dart';
import 'core/config/theme/theme_provider.dart';
import 'core/config/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: KodaStockApp(),
    ),
  );
}

class KodaStockApp extends ConsumerWidget {
  const KodaStockApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'KodaStock',
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: themeMode,
      
      // Router Configuration
      routerConfig: router,
      
      // Localization
      supportedLocales: const [
        Locale('en', 'US'),
      ],
    );
  }
}
