# 📐 Math AI Studio (graficacion_ai)

> **Proyecto de Dispositivos Móviles**

**Math AI Studio** es una aplicación móvil desarrollada en Flutter que busca democratizar la comprensión de las matemáticas complejas. A diferencia de herramientas tradicionales como GeoGebra o Desmos, que se centran solo en el resultado visual, este proyecto integra **Inteligencia Artificial** para actuar como un tutor personal, explicando el comportamiento de las funciones, dominios y puntos críticos.

## 🎓 Contexto Académico

Este proyecto fue desarrollado como parte de la materia **Dispositivos Móviles**

* **Materia:** Dispositivos Móviles (Grupo 564)
* **Docente:** José Manuel Muñoz Contreras
* **Equipo de Desarrollo:**
  * Cruz Hernandez Juan Carlos
  * Medrano Barrera Victor Yahir
  * Rodriguez Cardenas Marshall
  * Cortes Hernández Baku Lenin

  ## ✨ Características Principales

* **🤖 Tutoría con IA (Gemini):** Explica *por qué* una curva se comporta de cierta manera, no solo la dibuja.
* **📈 Graficación 2D:** Visualización precisa de funciones cartesianas (`fl_chart`).
* **🧊 Graficación 3D:** Renderizado de superficies y vectores en tres dimensiones (`ditredi`).
* **🔐 Acceso Seguro:** Gestión de usuarios mediante **Firebase Auth**.
* **☁️ Historial en la Nube:** Sincronización de ecuaciones y consultas en **Cloud Firestore**.
* **🌍 Internacionalización:** Soporte nativo para Español e Inglés.

## 🛠️ Arquitectura y Tecnologías

El proyecto sigue una arquitectura **"Feature-First"** (basada en características) para asegurar escalabilidad y separación de responsabilidades:

* **Framework:** Flutter (Dart 3.0+)
* **Patrón de Diseño:** Feature-First (Separación estricta de UI, Lógica y Datos).
* **Gestión de Estado:** Provider.
* **Backend:** Firebase (Core, Auth, Firestore).
* **IA:** Google Generative AI SDK.
* **Matemáticas:** `math_expressions`, `vector_math`.

```bash
lib/
├── main.dart                  # 🚀 Punto de entrada de la aplicación
├── app.dart                   # 🛠️ Configuración global (Rutas, Temas, Localización)
├── firebase_options.dart      # 🔥 Configuración generada por FlutterFire
├── core/                      # 🧱 Bloques constructivos compartidos
│   ├── constants/             # API Keys, Strings estáticos
│   ├── theme/                 # Estilos, Paleta de colores
│   └── utils/                 # Validadores, Helpers matemáticos
├── features/                  # 📦 Módulos funcionales (La lógica principal)
│   ├── algebra/               # ➗ Lógica y UI para Álgebra y Funciones
│   │   ├── logic/             # AlgebraProvider (Estado y fórmulas)
│   │   └── screens/           # UI de Álgebra
│   ├── auth/                  # 🔐 Login, Registro, Recuperación de contraseña
│   │   ├── logic/             # AuthProvider (Estado)
│   │   └── screens/           # UI de Autenticación
│   ├── chat/                  # 🤖 Interfaz de chat con Gemini AI
│   │   ├── logic/             # ChatProvider (Gestión de mensajes)
│   │   └── screens/           # Vista del chat
│   ├── ecuaciones_diferenciales/ # 📈 Lógica y UI para Ecuaciones Diferenciales
│   │   ├── logic/             # EcuacionesProvider (Estado y resolución)
│   │   └── screens/           # UI de Ecuaciones
│   ├── editor/                # ✏️ Input de ecuaciones y parseo matemático general
│   │   ├── logic/             # EditorProvider
│   │   └── screens/           # Teclado matemático custom
│   ├── home/                  # 🏠 Pantalla principal, navegación (BottomNav) y Menú Lateral
│   ├── mecanica_vectorial/    # 📐 Lógica y UI para Mecánica Vectorial Estática
│   │   ├── logic/             # MecanicaProvider (Vectores, estática)
│   │   └── screens/           # UI de Mecánica Vectorial
│   ├── settings/              # ⚙️ Configuración de usuario (Idioma/Tema)
│   └── visualizer/            # 📊 Motores de renderizado (Gráficas)
│       └── screens/           # Canvas 2D y 3D
└── l10n/                      # 🌍 Archivos de traducción (.arb)
    ├── app_en.arb
    └── app_es.arb
```

## 🚀 Instalación y Configuración

### 1. Prerrequisitos
* Flutter SDK (Canal estable)
* Cuenta de Google Cloud (para API Key de Gemini)