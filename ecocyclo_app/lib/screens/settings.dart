import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../widgets/settings/settings_header.dart';
import '../widgets/settings/settings_menu_button.dart';
import '../widgets/back_button_app.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';

final logger = Logger();

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 💡 CACHE ESTATICO: Estas variáveis armazenam os dados e persistem na memória
  // mesmo quando a instância da tela é destruída (ao usar Navigator.pop).
  static String? _cachedCompanyName;
  static bool? _cachedIsLoggedIn;

  // O valor "Carregando..." serve como uma flag de que os dados não foram buscados.
  String companyName = "Carregando...";
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    
    // 1. TENTA USAR O CACHE
    if (_cachedCompanyName != null && _cachedIsLoggedIn != null) {
      // Se o cache existir, inicializa o estado instantaneamente com o cache
      companyName = _cachedCompanyName!;
      isLoggedIn = _cachedIsLoggedIn!;
    } else {
      // 2. SE NÃO HOUVER CACHE, CARREGA OS DADOS (com delay)
      loadCompanyInfo();
    }
  }

  Future<void> loadCompanyInfo() async {
    final name = await AuthService.getCompanyName();
    final token = await AuthService.getToken();
    
    // Verificamos se o widget ainda está na árvore antes de chamar setState
    if (mounted) {
      // 3. ATUALIZA O ESTADO E O CACHE
      setState(() {
        companyName = name;
        isLoggedIn = token != null;
        _cachedCompanyName = name; // Atualiza o cache estático
        _cachedIsLoggedIn = token != null; // Atualiza o cache estático
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = 229.0;
    final bottomPadding = 20.0;
    // Ajuste aqui se a quantidade de botões mudar (aqui são 5: Login/Logout + 3 fixos)
    final buttonsHeight = 80.0 * 5 + 20.0 * 4 + 40.0;
    final verticalSpace =
        (screenHeight - headerHeight - bottomPadding - buttonsHeight) / 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SettingsHeader(companyName: companyName),
                  SizedBox(height: verticalSpace),

                  // Só mostra o botão de Login se não estiver logado
                  if (!isLoggedIn) ...[
                    SettingsMenuButton(
                      text: "Login",
                      svgIconPath: "assets/icons/person.svg",
                      onPressed: () async {
                        // Ao retornar do login, chamamos loadCompanyInfo para atualizar
                        await Navigator.pushNamed(context, '/login');
                        
                        // 💡 CORREÇÃO: Resetamos o estado local imediatamente após o retorno do login.
                        // Isso força o widget a mostrar "Carregando..." por um breve momento,
                        // garantindo que ele não mantenha o estado de "deslogado" enquanto 
                        // a nova chamada à API está sendo processada.
                        setState(() {
                          companyName = "Carregando...";
                          isLoggedIn = false;
                        });

                        // Força o reload após a navegação de retorno
                        loadCompanyInfo(); 
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  SettingsMenuButton(
                    text: "Notificações",
                    svgIconPath: "assets/icons/not.svg",
                  ),
                  const SizedBox(height: 20),
                  SettingsMenuButton(
                    text: "Sobre o Ecocyclo",
                    svgIconPath: "assets/icons/inf.svg",
                  ),
                  const SizedBox(height: 20),
                  SettingsMenuButton(
                    text: "Segurança e Privacidade",
                    svgIconPath: "assets/icons/priv.svg",
                  ),
                  const SizedBox(height: 20),

                  // Logout só faz sentido se estiver logado
                  if (isLoggedIn)
                    SettingsMenuButton(
                      text: "Sair da conta",
                      svgIconPath: null,
                      textGradient: AppColors.logoutGradient,
                      onPressed: () async {
                        logger.i("Saindo da conta...");
                        await AuthService.logout();
                        
                        // 💡 MUDANÇA CRÍTICA: Reseta o cache estático.
                        // Isso garante que a próxima visita à tela faça a chamada API (loadCompanyInfo).
                        _cachedCompanyName = null; 
                        _cachedIsLoggedIn = null;

                        setState(() {
                          isLoggedIn = false;
                          companyName = "Carregando..."; 
                        });
                        
                        // Usamos pushReplacementNamed para limpar a pilha e garantir 
                        // que a HomeScreen seja a raiz após o logout.
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                    ),

                  SizedBox(height: verticalSpace),
                ],
              ),
            ),

            BackButtonApp(onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
