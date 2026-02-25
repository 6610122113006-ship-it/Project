import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/create_post_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('pet_box');
  await Hive.openBox('auth_box');
  runApp(const PetVillageApp());
}

class PetVillageApp extends StatelessWidget {
  const PetVillageApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Village Pet Watch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        fontFamily: 'Kanit', // อย่าลืมเพิ่ม Font ใน pubspec.yaml หากต้องการใช้
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/': (context) => const WelcomeScreen(),
        '/feed': (context) => const FeedScreen(),
        '/create': (context) => const CreatePostScreen(),
      },
    );
  }
}