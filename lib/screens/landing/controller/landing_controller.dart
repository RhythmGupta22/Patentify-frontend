// // lib/screens/landing/controller/landing_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:patentify/screens/authentication/screen/login_screen.dart';
// import 'package:patentify/screens/landing/screen/landing_screen.dart';
//
// class LandingController extends GetxController {
//   final ScrollController scrollController = ScrollController();
//   final homeKey = GlobalKey();
//   final aboutKey = GlobalKey();
//   final howItWorksKey = GlobalKey();
//   final testimonialsKey = GlobalKey();
//   final contactKey = GlobalKey();
//
//   // Reactive animation flags
//   final RxBool heroAnimationStarted = false.obs;
//   final RxBool aboutAnimationStarted = false.obs;
//   final RxBool howItWorksAnimationStarted = false.obs;
//   final RxBool testimonialsAnimationStarted = false.obs;
//   final RxBool contactAnimationStarted = false.obs;
//
//   void scrollToSection(GlobalKey key) {
//     final context = key.currentContext;
//     if (context != null) {
//       Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
//     }
//   }
//
//   void navigateToLogin() {
//     Get.to(()=>LoginScreen());
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Auto-start hero animation on init
//     heroAnimationStarted.value = true;
//   }
//
//   @override
//   void dispose() {
//     scrollController.dispose();
//     super.dispose();
//     ScrollController().dispose();
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patentify/screens/authentication/controller/auth_controller.dart';
import 'package:patentify/screens/authentication/screen/login_screen.dart';

class LandingController extends GetxController with GetSingleTickerProviderStateMixin {
  final AuthController authController = Get.find();
  final RxBool isLoading = false.obs;

  // Scroll keys for navigation
  final GlobalKey homeKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey howItWorksKey = GlobalKey();
  final GlobalKey testimonialsKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  final ScrollController scrollController = ScrollController();

  // Reactive mouse position for parallax
  final Rx<Offset> mousePosition = Offset.zero.obs;

  // Animation controller and value for gradient bubble
  late AnimationController gradientController;
  late Animation<double> gradientAnimation;

  void navigateToLogin() {
    isLoading.value = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.to(() => const LoginScreen());
      isLoading.value = false;
    });
  }

  void scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null && scrollController.hasClients) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        final offset = box.localToGlobal(Offset.zero).dy - kToolbarHeight;
        scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize gradient animation
    gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    gradientAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: gradientController, curve: Curves.linear),
    );
    gradientController.addListener(() {
      // Update animation value reactively
      gradientAnimation.value; // Trigger update via listener
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    gradientController.dispose();
    super.onClose();
  }
}