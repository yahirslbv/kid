// lib/shared/app_imports.dart

// ─── PAQUETES EXTERNOS MUY USADOS ───
export 'package:provider/provider.dart';

// ─── LOCALIZACIÓN (IDIOMAS) ───
export '../l10n/app_localizations.dart';

// ─── WIDGETS COMPARTIDOS ───
export 'widgets/bot_avatar.dart';
export 'widgets/kids/kids_feature_card.dart';
export 'widgets/kids/progress_stars.dart';
export 'widgets/kids/reward_badge.dart';

// ─── PROVEEDORES DE LÓGICA (PROVIDERS) ───
export '../features/auth/logic/auth_provider.dart';
export '../features/chat/logic/chat_provider.dart';
export '../features/editor/logic/editor_provider.dart';
export '../features/settings/logic/theme_provider.dart';
export '../features/settings/logic/language_provider.dart';
export '../features/mecanica_vectorial/logic/mecanica_provider.dart';

// ─── PANTALLAS GENERALES (SCREENS) ───
export '../features/auth/screens/login_screen.dart';
export '../features/home/screens/home_screen.dart';
export '../features/editor/screens/editor_screen.dart';
export '../features/chat/screens/chat_screen.dart';
export '../features/settings/screens/settings_screen.dart';
export '../features/settings/screens/profile_screen.dart';
export '../features/kids_home/screens/kids_home_screen.dart';

// ─── PANTALLAS DE ESTADÍSTICA ───
export '../features/estadistica/screens/estadistica_screen.dart';
export '../features/estadistica/screens/scan_problem_screen.dart';
export '../features/estadistica/screens/descriptiva_screen.dart';
export '../features/estadistica/screens/distribuciones_continuas_screen.dart';
export '../features/estadistica/screens/distribuciones_discretas_screen.dart';

// ─── PANTALLAS DE MECÁNICA VECTORIAL ───
export '../features/mecanica_vectorial/screens/graficador_screen.dart';
export '../features/mecanica_vectorial/screens/ia_tutor_screen.dart';

// ─── PANTALLAS DE MÉTODOS NUMÉRICOS ───
export '../features/metodos_numericos/screens/metodos_numericos_screen.dart';
export '../features/metodos_numericos/screens/biseccion_screen.dart';
export '../features/metodos_numericos/screens/raices_ecuaciones_screen.dart';
export '../features/metodos_numericos/screens/newton_raphson_screen.dart';
export '../features/metodos_numericos/screens/secante_screen.dart';
export '../features/metodos_numericos/screens/sistemas_lineales_screen.dart';
export '../features/metodos_numericos/screens/gauss_jordan_screen.dart';
export '../features/metodos_numericos/screens/jacobi_screen.dart';
export '../features/metodos_numericos/screens/gauss_seidel_screen.dart';
export '../features/metodos_numericos/screens/ajuste_curvas_screen.dart';
export '../features/metodos_numericos/screens/regresion_lineal_screen.dart';
export '../features/metodos_numericos/screens/lagrange_screen.dart';
export '../features/metodos_numericos/screens/integracion_numerica_screen.dart';
export '../features/metodos_numericos/screens/trapecio_screen.dart';
export '../features/metodos_numericos/screens/simpson_13_screen.dart';
export '../features/metodos_numericos/screens/simpson_38_screen.dart';
export '../features/metodos_numericos/screens/ecuaciones_diferenciales_screen.dart';
export '../features/metodos_numericos/screens/euler_screen.dart';
export '../features/metodos_numericos/screens/rk4_screen.dart';

// --- PANTALLAS DE ÁLGEBRA ---
export '../features/algebra/screens/algebra_screen.dart';
export '../features/algebra/screens/tabulador_screen.dart';
export '../features/algebra/screens/ecuaciones_cuadraticas_screen.dart';
export '../features/algebra/screens/operaciones_matrices_screen.dart';
export '../features/algebra/screens/determinantes_screen.dart';
export '../features/algebra/screens/division_sintetica_screen.dart';
export '../features/algebra/screens/numeros_complejos_screen.dart';
