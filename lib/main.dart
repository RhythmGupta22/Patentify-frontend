import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:patentify/screens/authentication/controller/auth_controller.dart';
import 'package:patentify/screens/authentication/screen/login_screen.dart';
import 'package:patentify/screens/chat/controller/chat_controller.dart';
import 'package:patentify/screens/chat/screen/chat_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize controllers with GetX
  Get.put(AuthController());
  Get.put(ChatController());

  runApp(const PatentifyApp());
}

class PatentifyApp extends StatelessWidget {
  const PatentifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return GetMaterialApp(
      title: 'Patentify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Obx(() {
        final user = authController.user.value?.displayName;
        return user != null ? const ChatScreen() : const LoginScreen();
      }),
    );
  }
}