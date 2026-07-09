# CLAUDE.md — Vendedores QB

Contexto permanente del proyecto. Léelo antes de tocar cualquier archivo.
---
Odio codigo espaguetty, odio archivos largos maximo 200 300 lineas de codigo dividir en widgets o partial separados con responsabilidad unica NO QUIERO CODIGOS EXTENSOS , odio letras gigantes no es bonito ni elegante ni profesional, SOLID OPEN CLOSE y DRY la biblia, colones solidos, no quiro gradiantes odio el gradiante.
---

## Qué es esta app

App Windows Flutter para **QuickBill Agentes** de QuickBill. es un webview que abre una url 
cuando se abre y no esta configurada debe pedir obligatoriaente el servidor
en el host del servidor voy a colocar ejemplo demo.quickbillcr.com

despues que yo guarde esto deberia ya de verse pantalla completa el webview con la url 

https://demo.quickbillcr.com/agente-venta/login

eso es todo, esta app debe de tener un boton para reconfigurar el servidor o cambiar el token si por algun motivo el consumo de la web no da status 200 al cargar da 404 debe de salir un error de mi app no de lo que retorna la web deveria de decir que el terminal pos se encuentra mal configurado o el token ha cambiado por favor verifique o vuelva a configurarlo y cuando le de click a volver a configurar que me de la oportunidad de editar el servidor o el token 
El nombre visible es **"QuickBill Agentes"**.

---

## Reglas absolutas de código

### Estructura y modularidad

- **Máximo 200–300 líneas por archivo.** Si un archivo supera eso, divídelo.
- **Cero código espagueti.** Todo tiene su lugar. Ver estructura abajo.
- **Cero lógica de negocio en widgets.** Los widgets solo renderizan.
- **Cero strings hardcodeados** en widgets — usar `AppStrings`.
- **Cero números mágicos** — usar `AppDimensions`.
- **Cero `TextStyle` inline** — usar `AppTextStyles`.
- **Cero `Color` inline** — usar `AppColors`.

### UI / Diseño

- **Sin gradientes.** Colores sólidos siempre.
- Paleta basada en el logo verde de QuickBill: primario `#6DBF47`.
- Logo oficial: `assets/images/logo.png` — usado en splash e ícono de la app.
- Nombre de la app a mostrar: **"QuickBill Agentes"**.
- Fuente: `Inter` (declarada en pubspec).

### Arquitectura

- **Clean Architecture** por feature: `data → domain → presentation`.
- **State management**: Riverpod (flutter_riverpod + riverpod_annotation).
- **HTTP**: Dio con `AuthInterceptor` que agrega el Bearer token automáticamente.
- **Routing**: GoRouter con rutas definidas en `AppRoutes`.
- **Almacenamiento seguro**: `SecureStorage` (token, dominio, vendedor_id).
- **Offline**: sqflite para caché local de catálogos.

---

## Estructura de directorios

```
lib/
├── main.dart                        # Punto de entrada
├── app.dart                         # MaterialApp + router
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # ÚNICA fuente de colores
│   │   ├── app_text_styles.dart     # ÚNICA fuente de tipografía
│   │   ├── app_dimensions.dart      # ÚNICA fuente de espaciados/radios
│   │   └── app_strings.dart         # ÚNICA fuente de strings
│   ├── theme/
│   │   └── app_theme.dart           # ThemeData completo
│   ├── network/
│   │   ├── api_client.dart          # Dio factory
│   │   ├── api_endpoints.dart       # Todos los endpoints de la API
│   │   └── interceptors/
│   │       └── auth_interceptor.dart
│   ├── storage/
│   │   └── secure_storage.dart      # Token, dominio, vendedor_id
│   ├── errors/
│   │   ├── exceptions.dart          # Capa de datos
│   │   └── failures.dart            # Capa de dominio (Either)
│   └── utils/
│       ├── formatters.dart          # Monedas, fechas, cédulas
│       └── validators.dart          # Validadores de formularios
│
├── features/
│   └── {feature}/
│       ├── data/
│       │   ├── datasources/         # Llamadas a la API (Dio)
│       │   ├── models/              # JSON → Dart (fromJson/toJson)
│       │   └── repositories/        # Implementación del repo
│       ├── domain/
│       │   ├── entities/            # Clases puras Dart (Equatable)
│       │   ├── repositories/        # Interfaces abstractas
│       │   └── usecases/            # Un caso de uso por archivo
│       └── presentation/
│           ├── pages/               # Pantallas completas (Scaffold)
│           ├── widgets/             # Componentes de esa feature
│           ├── providers/           # Riverpod providers/notifiers
│           └── forms/               # Forms complejos (solo en documentos)
│
├── shared/
│   ├── widgets/
│   │   ├── buttons/                 # PrimaryButton, etc.
│   │   ├── inputs/                  # CustomTextField, etc.
│   │   ├── loaders/                 # FullPageLoader, InlineLoader, etc.
│   │   ├── cards/                   # Tarjetas reutilizables
│   │   ├── dialogs/                 # Diálogos reutilizables
│   │   └── empty_states/            # EmptyStateWidget, ErrorStateWidget
│   └── models/
│       └── pagination_model.dart
│
├── routes/
│   └── app_router.dart              # GoRouter + AppRoutes constants
│
assets/
├── images/
│   └── logo.png                     # Logo oficial QuickBill (splash + icono)
└── icons/
    └── app_icon.png                 # Ícono de la app
```

**Features actuales:**
- `server_setup` — Pantalla de configuración de URL del servidor (solo primera vez)

---
