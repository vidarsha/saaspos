import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String subtitle;

  const OnboardingLayout({
    super.key,
    required this.child,
    this.title = 'Transform your business into an enterprise.',
    this.subtitle = 'One platform for multi-branch inventory, POS, and deep analytics.',
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Left Side: Branding (Hidden on mobile for better UX, or shown at top)
          if (!isMobile)
            Expanded(
              flex: 4,
              child: Container(
                color: const Color(0xFF0F172A),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.network(
                          'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&q=80',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(60.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.rocket_launch_rounded, color: Colors.blueAccent, size: 40),
                              const SizedBox(width: 16),
                              Text(
                                'GoBeeZ POS',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '© 2024 GoBeeZ SaaS Platforms',
                            style: GoogleFonts.inter(color: Colors.white30, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Right Side: Dynamic Content
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 24.0 : 60.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - (isMobile ? 48 : 120),
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
