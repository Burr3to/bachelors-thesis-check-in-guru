import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared_widgets/autoplay_video.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/responsive.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondaryBg = colorScheme.surfaceContainer;
    const double maxContentWidth = 1150; // Pôvodná šírka

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children:[
            // 1. HERO SEKCIA (Vrátený modrý gradient a Chip)
            const _HeroSection(maxContentWidth: maxContentWidth),

            // 2. SEKCIA 1
            _FeatureSection(
              maxWidth: maxContentWidth,
              title: context.l10n.home_sec1_title,
              descriptionText: context.l10n.home_sec1_desc,
              videoAsset: 'assets/videos/AutorCreate.webm',
              isReversed: false,
            ),

            // 3. SEKCIA 2 (Šedé/tmavé pozadie)
            _FeatureSection(
              maxWidth: maxContentWidth,
              backgroundColor: secondaryBg,
              title: context.l10n.home_sec2_title,
              descriptionText: context.l10n.home_sec2_desc,
              videoAsset: 'assets/videos/Respondent.webm',
              isReversed: true,
            ),

            // 4. SEKCIA 3
            _FeatureSection(
              maxWidth: maxContentWidth,
              title: context.l10n.home_sec3_title,
              descriptionText: context.l10n.home_sec3_desc,
              videoAsset: 'assets/videos/AutorOverview.webm',
              isReversed: false,
            ),

            // 5. FOOTER (Vrátený tmavý dizajn)
            const _FooterSection(),
          ],
        ),
      ),
    );
  }
}

// --- HERO SECTION ---
class _HeroSection extends StatelessWidget {
  final double maxContentWidth;

  const _HeroSection({required this.maxContentWidth});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryBlue = colorScheme.primary;
    final isMobile = context.isMobile;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:[
            primaryBlue.withAlpha(theme.brightness == Brightness.light ? 12 : 30),
            colorScheme.surface,
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 60 : 110,
              horizontal: isMobile ? 20 : 40,
            ),
            child: Column(
              children:[
                // Vrátený malý "Chip" hore
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withAlpha(25),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    context.l10n.home_hero_chip,
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 32),
                Text(
                  context.l10n.home_hero_title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 42 : 62, // Stále veľké, ale prispôsobené mobilu
                    fontWeight: FontWeight.bold,
                    height: 1.05,
                    letterSpacing: -1.5,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 32),
                Text(
                  context.l10n.home_hero_subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 22,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: isMobile ? 32 : 48),
                // Vrátený pôvodný veľký "šťavnatý" button
                ElevatedButton(
                  onPressed: () => context.go('/tasks/create'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 32 : 40,
                      vertical: isMobile ? 20 : 26,
                    ),
                    elevation: 8,
                    shadowColor: primaryBlue.withAlpha(100),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    context.l10n.home_hero_cta,
                    style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- FEATURE SECTION ---
class _FeatureSection extends StatelessWidget {
  final double maxWidth;
  final String title;
  final String descriptionText;
  final String videoAsset;
  final bool isReversed;
  final Color? backgroundColor;

  const _FeatureSection({
    required this.maxWidth,
    required this.title,
    required this.descriptionText,
    required this.videoAsset,
    required this.isReversed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryBlue = colorScheme.primary;
    final isMobile = context.isMobile;

    // TEXTOVÁ ČASŤ (odstránená fajka pre skrátenie, ale farby zachované)
    Widget textContent = Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children:[
        SelectionArea(
          child: Text(
            title,
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              fontSize: isMobile ? 32 : 44,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.5,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SelectionArea(
          child: _buildStyledDescription(context, descriptionText, primaryBlue, isMobile),
        ),
      ],
    );

    // VIDEO ČASŤ (vrátený Transform.scale a veľký farebný tieň)
    Widget videoContent = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryBlue.withAlpha(25), width: 1),
        boxShadow:[
          BoxShadow(
            color: primaryBlue.withAlpha(theme.brightness == Brightness.light ? 32 : 10),
            blurRadius: 50,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Transform.scale(
        scale: 1.03, // Vrátený pop-out efekt
        child: HoverVideoPlayer(assetPath: videoAsset),
      ),
    );

    return Container(
      color: backgroundColor ?? colorScheme.surface,
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 60 : 80,
              horizontal: isMobile ? 20 : 40,
            ),
            child: isMobile
                ? Column(
              children:[
                textContent,
                const SizedBox(height: 40),
                videoContent,
              ],
            )
                : Row(
              children:[
                if (isReversed) Expanded(flex: 6, child: videoContent) else Expanded(flex: 4, child: textContent),
                const SizedBox(width: 80),
                if (isReversed) Expanded(flex: 4, child: textContent) else Expanded(flex: 6, child: videoContent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledDescription(BuildContext context, String text, Color accentColor, bool isMobile) {
    final parts = text.split('**');
    final colorScheme = Theme.of(context).colorScheme;

    return Text.rich(
      textAlign: isMobile ? TextAlign.center : TextAlign.left,
      TextSpan(
        style: TextStyle(
          fontSize: isMobile ? 18 : 20,
          color: colorScheme.onSurfaceVariant,
          height: 1.6,
        ),
        children: parts.asMap().entries.map((entry) {
          final isBold = entry.key % 2 != 0;
          return TextSpan(
            text: entry.value,
            // Vrátená modrá farba pre bold text (marketingový zvýraznený efekt)
            style: isBold ? TextStyle(color: accentColor, fontWeight: FontWeight.bold) : null,
          );
        }).toList(),
      ),
    );
  }
}

// --- FOOTER ---
class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80), // Vrátený veľký padding
      width: double.infinity,
      // Vrátená pôvodná "midnight blue" z tvojho kódu
      color: theme.brightness == Brightness.light ? const Color(0xFF1A1F36) : Colors.black,
      child: Center(
        child: Column(
          children:[
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
            Text(
              context.l10n.home_footer_subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 40),
            Text(
              context.l10n.home_footer_copyright,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}