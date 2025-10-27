import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import '../theme/app_colors.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/home_disposal_card.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../services/auth_service.dart';
import '../services/disposal_service.dart'; // futuro serviço para descartes
import '../models/disposal_stats.dart'; // modelo para descartes
import '/screens/map_screen.dart';

final logger = Logger();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String companyName = "Carregando...";
  DisposalStats disposalStats = DisposalStats(inProgress: 0, finished: 0);
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    loadCompanyName();
    loadDisposalStats();
  }

  Future<void> loadCompanyName() async {
    final name = await AuthService.getCompanyName();
    setState(() => companyName = name);
  }

  Future<void> loadDisposalStats() async {
    setState(() => isLoadingStats = true);
    // Aqui você chamaria o backend, mas atualmente devolve valores mock
    final stats = await DisposalService.getDisposalStats();
    setState(() {
      disposalStats = stats;
      isLoadingStats = false;
    });
  }

  void _navigateToMap(BuildContext context) {
    logger.i('Navegando para a tela de Mapa...');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(
              companyName: companyName, // nome dinâmico
              onProfilePressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    isLoadingStats
                        ? const CircularProgressIndicator()
                        : HomeDisposalCard(
                            inProgress: disposalStats.inProgress,
                            finished: disposalStats.finished,
                          ),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.45,
                      children: [
                        _FeatureCard(
                          assetName: 'assets/icons/rewards.svg',
                          label: 'Recompensas',
                          onTap: () => logger.i('Recompensas clicado!'),
                        ),
                        _FeatureCard(
                          assetName: 'assets/icons/certificado.svg',
                          label: 'Certificados',
                          onTap: () => logger.i('Certificados clicado!'),
                        ),
                        _FeatureCard(
                          assetName: 'assets/icons/impact.svg',
                          label: 'Impactos Ambientais',
                          onTap: () => logger.i('Impactos Ambientais clicado!'),
                        ),
                        _FeatureCard(
                          assetName: 'assets/icons/collections.svg',
                          label: 'Rastrear Coletas',
                          onTap: () => logger.i('Rastrear Coletas clicado!'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            CustomBottomNavigationBar(
              onMapTap: () => _navigateToMap(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String assetName;
  final String label;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.assetName,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [AppColors.gradientLeft, AppColors.gradientRight],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            width: 2,
            color: AppColors.gradientLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: SvgPicture.asset(
                assetName,
                height: 40,
                width: 40,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ShaderMask(
              shaderCallback: (bounds) =>
                  gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
