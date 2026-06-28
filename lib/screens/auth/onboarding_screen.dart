import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'What is SkillSwap?',
      'description': 'A continuous peer-to-peer learning platform where every user can simultaneously be a teacher and a learner.',
      'icon': 'swap_horizontal_circle',
    },
    {
      'title': 'Learn Skills from Peers',
      'description': 'Search and match with other users to learn python coding, UI/UX design, photography, and much more.',
      'icon': 'local_library',
    },
    {
      'title': 'Teach Your Own Skills',
      'description': 'Share your unique knowledge with others, build your tutoring reputation, and guide fellow students.',
      'icon': 'school',
    },
    {
      'title': 'Exchange Without Money',
      'description': 'No money is ever exchanged on SkillSwap - learning is purely mutual, based on direct skill exchange.',
      'icon': 'swap_calls',
    },
    {
      'title': 'Earn Badges & XP',
      'description': 'Conduct sessions, receive reviews, earn XP, and unlock accomplishments to climb the leaderboard.',
      'icon': 'military_tech',
    },
    {
      'title': 'Join Live Classes',
      'description': 'Host public live classes, record lectures, or participate in interactive live streaming discussions.',
      'icon': 'live_tv',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Skip Login', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconData(_onboardingData[index]['icon']!),
                            size: 80.0,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 48.0),
                        Text(
                          _onboardingData[index]['title']!,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          _onboardingData[index]['description']!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16.0,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  CustomButton(
                    text: _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String key) {
    switch (key) {
      case 'swap_horizontal_circle':
        return Icons.swap_horizontal_circle;
      case 'local_library':
        return Icons.local_library;
      case 'school':
        return Icons.school;
      case 'swap_calls':
        return Icons.swap_calls;
      case 'military_tech':
        return Icons.military_tech;
      case 'live_tv':
        return Icons.live_tv;
      default:
        return Icons.bolt;
    }
  }

  Widget _buildDot(int index) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 6.0),
      height: 8.0,
      width: _currentPage == index ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
