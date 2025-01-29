import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_model.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  final PageController _pageController = PageController();

  final List<OnboardingModel> onboardingData = [
    OnboardingModel(
      title: "Discover Amazing Places",
      description: "Find the best tours and adventures in Azerbaijan",
      image: "assets/images/onboarding1.jpeg",
    ),
    OnboardingModel(
      title: "Easy Booking",
      description: "Book your tour with just a few clicks",
      image: "assets/images/onboarding2.jpeg",
    ),
    OnboardingModel(
      title: "Start Your Journey",
      description: "Begin your adventure with Tripaz",
      image: "assets/images/onboarding3.jpeg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50), // Status bar için boşluk
          Align(
            // Skip butonu için
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: TextButton(
                onPressed: () async {
                  // Onboarding'i tamamlandı olarak işaretle
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboarding_completed', true);

                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Color(0XFFF39C4FF),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height *
                          0.6, // Ekranın %60'ını kaplasın
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(onboardingData[index].image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      onboardingData[index].title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        onboardingData[index].description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    onboardingData.length,
                    (index) => buildDot(index: index),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFFF39C4FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () async {
                    if (currentIndex == onboardingData.length - 1) {
                      // Son sayfadaysa, onboarding'i tamamlandı olarak işaretle
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboarding_completed', true);

                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Text(
                    currentIndex == onboardingData.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AnimatedContainer buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: currentIndex == index ? 20 : 8,
      decoration: BoxDecoration(
        color: currentIndex == index
            ? const Color(0XFFF39C4FF)
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
