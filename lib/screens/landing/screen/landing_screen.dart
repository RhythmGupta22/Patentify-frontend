import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:patentify/screens/authentication/controller/auth_controller.dart';
import 'package:patentify/screens/landing/controller/landing_controller.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final List<Offset> _stars = List.generate(
    50,
        (_) => Offset(
      math.Random().nextDouble() * 1000,
      math.Random().nextDouble() * 700,
    ),
  );

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LandingController controller = Get.find();
    final AuthController authController = Get.find();

    return Scaffold(extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16),
          child: Row(
            children: [
              const Icon(FontAwesomeIcons.rocket, color: Colors.deepPurple, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Patentify',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
          Padding(
                  padding: const EdgeInsets.only(left: 50.0),
                  child: Row(spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () => controller.scrollToSection(controller.homeKey),
                        child: const Text('Home', style: TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                      TextButton(
                        onPressed: () => controller.scrollToSection(controller.aboutKey),
                        child: const Text('About', style: TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                      TextButton(
                        onPressed: () => controller.scrollToSection(controller.howItWorksKey),
                        child: const Text('How It Works', style: TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                      TextButton(
                        onPressed: () => controller.scrollToSection(controller.testimonialsKey),
                        child: const Text('Testimonials', style: TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                      TextButton(
                        onPressed: () => controller.scrollToSection(controller.contactKey),
                        child: const Text('Contact', style: TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                    ],
                  ),
                ),

            ],
          ),
        ),
      ),
      body: MouseRegion(
        onHover: (event) {
          controller.mousePosition.value = event.localPosition; // Update reactively
        },
        child: SingleChildScrollView(
          controller: controller.scrollController,
          child: Column(
            children: [
              // Hero Section
              Container(
                key: controller.homeKey,
                height: 700,
                color: const Color.fromRGBO(0, 0, 0, 1), // Solid black background
                child: GetBuilder<LandingController>(
                  builder: (controller) => CustomPaint(
                    painter: MovingGradientBubblePainter(controller.gradientAnimation.value),
                    child: Stack(
                      children: [
                        // Stars with Subtle Parallax Effect
                        Obx(() => Stack(
                          children: _stars.map((star) {
                            final dx = star.dx + (controller.mousePosition.value.dx - 500) * 0.05;
                            final dy = star.dy + (controller.mousePosition.value.dy - 350) * 0.05;
                            return Positioned(
                              left: dx,
                              top: dy,
                              child: const Icon(
                                Icons.circle,
                                size: 2,
                                color: Colors.white70,
                              ),
                            );
                          }).toList(),
                        )),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FadeInDown(
                                duration: const Duration(milliseconds: 1000),
                                child: Text(
                                  'Welcome to Patentify',
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 4.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              FadeIn(
                                duration: const Duration(milliseconds: 1200),
                                child: const Text(
                                  'Exploring Patents, Pioneering Innovation.',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white70,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 40),
                              FadeInUp(
                                duration: const Duration(milliseconds: 1400),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => controller.navigateToLogin(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black.withOpacity(0.3),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 2,
                                        shadowColor: Colors.white.withOpacity(0.2),
                                      ),
                                      child: const Text(
                                        'Get Started',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    OutlinedButton(
                                      onPressed: () {
                                        Get.snackbar('Info', 'Learn more about Patentify!');
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.white24),
                                        backgroundColor: Colors.black.withOpacity(0.2),
                                        foregroundColor: Colors.white70,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 2,
                                        shadowColor: Colors.white.withOpacity(0.2),
                                      ),
                                      child: const Text(
                                        'Learn More',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // About Section
              Container(
                key: controller.aboutKey,
                padding: const EdgeInsets.all(40.0),
                color: const Color.fromRGBO(20, 10, 40, 1),
                child: FadeIn(
                  duration: const Duration(milliseconds: 1000),
                  child: Column(
                    children: [
                      const Text(
                        'About Patentify',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Patentify is designed to revolutionize patent research by leveraging cutting-edge AI technology. Our mission is to empower inventors, researchers, and businesses with tools to explore, analyze, and protect intellectual property efficiently, inspired by the vastness of space exploration.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              // How It Works Section
              Container(
                key: controller.howItWorksKey,
                padding: const EdgeInsets.all(40.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color.fromRGBO(30, 15, 60, 1),
                      Color.fromRGBO(0, 0, 0, 1),
                    ],
                  ),
                ),
                child: FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: Column(
                    children: [
                      const Text(
                        'How It Works',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StepCard(
                            number: '1',
                            title: 'Search Patents',
                            description:
                            'Enter keywords or patent numbers to find relevant documents.',
                            icon: FontAwesomeIcons.spaceShuttle,
                          ),
                          _StepCard(
                            number: '2',
                            title: 'AI Analysis',
                            description:
                            'Get detailed insights and summaries from our AI.',
                            icon: FontAwesomeIcons.robot,
                          ),
                          _StepCard(
                            number: '3',
                            title: 'Track Trends',
                            description:
                            'Visualize data and monitor patent trends over time.',
                            icon: FontAwesomeIcons.chartLine,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Testimonials Section
              Container(
                key: controller.testimonialsKey,
                padding: const EdgeInsets.all(40.0),
                color: const Color.fromRGBO(20, 10, 40, 1),
                child: FadeIn(
                  duration: const Duration(milliseconds: 1000),
                  child: Column(
                    children: [
                      const Text(
                        'What Our Users Say',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _TestimonialCard(
                            name: 'Jane Doe',
                            role: 'Inventor',
                            quote:
                            'Patentify saved me hours of research with its AI insights!',
                          ),
                          _TestimonialCard(
                            name: 'John Smith',
                            role: 'Researcher',
                            quote:
                            'The analytics feature is a game-changer for my work.',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Contact Section
              Container(
                key: controller.contactKey,
                padding: const EdgeInsets.all(40.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(0, 0, 0, 1),
                      Color.fromRGBO(30, 15, 60, 1),
                    ],
                  ),
                ),
                child: FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: Column(
                    children: [
                      const Text(
                        'Get in Touch',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Have questions? Reach out to us at support@patentify.com or follow us on social media.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.twitter,
                                color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.linkedin,
                                color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                height: 100,
                color: const Color.fromRGBO(0, 0, 0, 1),
                child: const Center(
                  child: Text(
                    '© 2025 Patentify. All rights reserved.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Step Card Widget
class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData? icon;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(40, 40, 40, 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (icon != null)
            FaIcon(
              icon!,
              size: 24,
              color: Colors.deepPurple,
            ),
          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// Testimonial Card Widget
class _TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final String quote;

  const _TestimonialCard({
    required this.name,
    required this.role,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(50, 50, 50, 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote,
            color: Colors.deepPurple,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            quote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            role,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Moving Gradient Bubble
class MovingGradientBubblePainter extends CustomPainter {
  final double progress;

  MovingGradientBubblePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 50) // Blur effect
      ..shader = RadialGradient(
        center: Alignment(0.0 + progress, 0.0),
        radius: 0.5,
        colors: [
          Colors.deepPurple.withOpacity(0.3),
          Colors.white.withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}