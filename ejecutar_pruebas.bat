@echo off
title Math AI Studio - Suite Completa de Pruebas
color 0B

:: Encabezado principal
echo ========================================================
echo                    MATH AI STUDIO
echo        SISTEMA DE VERIFICACION AUTOMATIZADA
echo ========================================================
echo.

:: SECCION 1: PRUEBAS UNITARIAS
echo [FASE 1/2] Iniciando pruebas unitarias de logica y modelos...
echo --------------------------------------------------------
:: Corre todos los archivos dentro de la carpeta /test
call flutter test
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo [!] ERROR: Algunas pruebas unitarias fallaron.
    echo Revisa la logica antes de proceder con las simulaciones.
    pause
    exit /b %errorlevel%
)
echo.
echo [+] Fase 1 completada con exito.
echo.

:: SECCION 2: PRUEBAS DE SIMULACION (INTEGRATION TESTS)
echo [FASE 2/2] Iniciando simulaciones interactivas (E2E)...
echo --------------------------------------------------------
echo NOTA: Asegurate de tener tu Android o Emulador conectado.
echo.

echo - Simulando: Autenticacion...
call flutter test integration_test/simulacion_login_test.dart

echo - Simulando: Mecanica Vectorial (Fuerzas)...
call flutter test integration_test/simulacion_mecanica_test.dart

echo - Simulando: Chat IA (Tutor Gemini)...
call flutter test integration_test/simulacion_chat_ia_test.dart

echo - Simulando: Editor de Funciones (2D/3D)...
call flutter test integration_test/simulacion_editor_test.dart

echo - Simulando: Metodos Numericos (Biseccion)...
call flutter test integration_test/simulacion_metodos_numericos_test.dart

echo - Simulando: Ecuaciones Diferenciales (EDO)...
call flutter test integration_test/simulacion_ecuaciones_diferenciales_test.dart

echo - Simulando: Estadistica Descriptiva...
call flutter test integration_test/simulacion_estadistica_test.dart

echo.
echo ========================================================
echo         TODAS LAS PRUEBAS HAN FINALIZADO
echo ========================================================
echo Revisa los resultados detallados arriba.
pause
