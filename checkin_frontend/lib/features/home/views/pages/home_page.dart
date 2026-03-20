import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared_widgets/autoplay_video.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Tvoja identita
    const primaryBlue = Colors.blueAccent;
    const backgroundGrey = Color(0xFFF8F9FA);
    const double maxContentWidth = 1150;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HERO SEKTCIA ---
            Container(
              width: double.infinity,
              // Jemný modrý prechod pre hĺbku
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryBlue.withAlpha(12), Colors.white],
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 110, horizontal: 40),
                    child: Column(
                      children: [
                        // Chip s informáciou o módoch
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: primaryBlue.withAlpha(25),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "Independent • Collaborative • Public • Private",
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "Smart Checklists.\nFrictionless Responses.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 62,
                            fontWeight: FontWeight.bold,
                            height: 1.05,
                            letterSpacing: -1.5,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "The professional way to collect data. You build the task,\nthey complete it in seconds—no registration required for respondents.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => context.go('/login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 26,
                                ),
                                elevation: 8,
                                shadowColor: primaryBlue.withAlpha(100),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                "Create Your First Task",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // SEKCIA 1
            _buildFeatureSection(
              context: context,
              maxWidth: maxContentWidth,
              accentColor: primaryBlue,
              title: "Two Modes. Infinite Control.",
              description: _styledDescription(
                "Choose **Collaborative** for shared team goals where everyone works together, or **Independent** to give every respondent their own private copy of the checklist.",
                primaryBlue,
              ),
              videoAsset: 'assets/videos/AutorCreate.mp4',
              isReversed: false,
            ),

            // SEKCIA 2
            _buildFeatureSection(
              context: context,
              maxWidth: maxContentWidth,
              accentColor: primaryBlue,
              backgroundColor: backgroundGrey,
              title: "Participation Made Simple.",
              description: _styledDescription(
                "Respondents join via a simple URL. For public tasks, **no login is required**—they just type their name and start. Fast, direct, and effective.",
                primaryBlue,
              ),
              videoAsset: 'assets/videos/Respondent.mp4',
              isReversed: true,
            ),

            // SEKCIA 3
            _buildFeatureSection(
              context: context,
              maxWidth: maxContentWidth,
              accentColor: primaryBlue,
              title: "Your Data, Your Rules.",
              description: _styledDescription(
                "Need verified responses? Switch to **Private Mode** to require authentication. Want maximum reach? Use **Public Mode** for instant access without barriers.",
                primaryBlue,
              ),
              videoAsset: 'assets/videos/AutorOverview.mp4',
              isReversed: false,
            ),

            // --- FOOTER ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 80),
              width: double.infinity,
              color: const Color(0xFF1A1F36),
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      "CheckIn",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(height: 2, width: 40, color: primaryBlue),
                    const SizedBox(height: 20),
                    const Text(
                      "The efficient way to manage Tasks.",
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "© 2026 CheckIn • Powered by Flutter Web",
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection({
    required BuildContext context,
    required double maxWidth,
    required Color accentColor,
    required String title,
    required Widget description,
    required String videoAsset,
    required bool isReversed,
    Color backgroundColor = Colors.white,
  }) {
    final textColumn = Expanded(
      flex: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectionArea(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.5,
                color: Color(0xFF1A1F36),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // RichText na zvýraznenie kľúčových slov
          SelectionArea(child: description),
          const SizedBox(height: 32),
          // Malý indikátor s modrou farbou
          Row(
            children: [
              Icon(Icons.check_circle, color: accentColor, size: 20),
              const SizedBox(width: 10),
              const Text(
                "Ready in seconds",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );

    final videoColumn = Expanded(
      flex: 6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withAlpha(25), width: 1),
          boxShadow: [
            BoxShadow(
              color: accentColor.withAlpha(32),
              blurRadius: 50,
              offset: const Offset(0, 25),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Transform.scale(
          scale: 1.03,
          child: AutoplayVideo(assetPath: videoAsset),
        ),
      ),
    );

    return Container(
      color: backgroundColor,
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
            child: Row(
              children: [
                if (isReversed) videoColumn else textColumn,
                const SizedBox(width: 80),
                if (isReversed) textColumn else videoColumn,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledDescription(String text, Color accentColor) {
    final parts = text.split('**');
    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 20, color: Colors.black54, height: 1.6),
        children: parts.asMap().entries.map((entry) {
          final isBold = entry.key % 2 != 0;
          return TextSpan(
            text: entry.value,
            style: isBold
                ? TextStyle(color: accentColor, fontWeight: FontWeight.bold)
                : null,
          );
        }).toList(),
      ),
    );
  }
}
