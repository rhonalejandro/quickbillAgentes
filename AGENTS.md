# AGENTS.md — QuickBill Agentes (quickbill_agentes)

> Contexto del proyecto para agentes de código. Léelo antes de modificar cualquier archivo.

---

## Descripción general

**QuickBill Agentes** es una aplicación de escritorio Windows construida con Flutter que funciona como contenedor WebView para el módulo de agentes de venta de **QuickBill CR**.

La app es esencialmente un contenedor fullscreen de WebView (`flutter_inappwebview`) que carga una URL web del servidor POS del cliente. Cuando la aplicación se abre por primera vez, solicita obligatoriamente:
- El host del servidor (ej: `iskia.quickbillcr.com`)
- El token de acceso de la caja configurada

Una vez guardados, construye la URL `https://{host}/pos/terminalpos/{token}` y la carga en pantalla completa.

Si el WebView devuelve un error HTTP (404, etc.) o error de red, la app muestra una pantalla de error nativa indicando que el terminal está mal configurado o el token ha cambiado, con opción de reconfigurar.

La app también integra soporte para impresión local desde el WebView mediante un puente JavaScript:
- El WebView expone handlers JS (`toggleFullScreen`, `print`).
- Impresora de red (socket raw ESC/POS) o impresora USB Windows (vía API Win32 `OpenPrinter`/`WritePrinter`).

---

## Stack tecnológico

| Capa | Paquete | Versión / Uso |
|------|---------|---------------|
| SDK | Flutter | `^3.10.4` |
| Estado | `flutter_riverpod` | `^2.5.1` — StateNotifier / AsyncNotifier |
| Routing | `go_router` | `^14.2.7` |
| Almacenamiento seguro | `flutter_secure_storage` | `^9.2.2` — host, token, config impresora |
| WebView | `flutter_inappwebview` | `^6.1.0` — carga del módulo de agentes |
| Ventana | `window_manager` | `^0.4.0` — fullscreen al iniciar, toggle F11 |
| Fuentes | `google_fonts` | `^6.2.1` — Inter |
| Igualdad | `equatable` | `^2.0.5` — entidades de dominio |
| Win32 nativo | `win32` | `^5.5.3` — impresión USB Windows |
| FFI | `ffi` | `^2.1.3` — alloc de memoria nativa para impresión |
| Lints | `flutter_lints` | `^6.0.0` |

**Plataforma principal:** Windows desktop. Aunque el proyecto tiene carpetas de Android, iOS, macOS, Linux y web, el código actual utiliza APIs específicas de Windows (`win32`, PowerShell para descubrimiento de impresoras, `window_manager` en fullscreen).

---

## Estructura de directorios (`lib/`)

```
lib/
├── main.dart                          # Punto de entrada. Inicializa window_manager en fullscreen.
├── app.dart                           # MaterialApp.router + theme
├── routes/
│   └── app_router.dart                # GoRouter: splash → setup → pos → printer-setup
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # ÚNICA fuente de colores (primario #6DBF47)
│   │   ├── app_text_styles.dart       # ÚNICA fuente de tipografía (Inter)
│   │   ├── app_dimensions.dart        # Espaciados, radios, tamaños de componentes
│   │   └── app_strings.dart           # ÚNICA fuente de textos (español)
│   ├── theme/
│   │   └── app_theme.dart             # ThemeData con Material3
│   ├── storage/
│   │   └── secure_storage.dart        # Wrapper sobre FlutterSecureStorage
│   └── printer/
│       ├── printer_service.dart       # Lógica de impresión: red (socket) y USB (Win32)
│       └── printer_discovery_service.dart  # Descubre impresoras Windows vía PowerShell
├── features/
│   ├── splash/
│   │   └── presentation/pages/splash_page.dart
│   ├── server_setup/
│   │   ├── domain/entities/server_config.dart
│   │   ├── domain/repositories/server_config_repository.dart
│   │   ├── data/repositories/server_config_repository_impl.dart
│   │   └── presentation/
│   │       ├── pages/server_setup_page.dart
│   │       ├── providers/server_config_provider.dart
│   │       └── widgets/ (server_form.dart, setup_header.dart)
│   ├── agent_viewer/
│   │   └── presentation/
│   │       ├── pages/agent_viewer_page.dart      # WebView + handlers JS + diálogo ajustes
│   │       ├── providers/agent_viewer_provider.dart
│   │       └── widgets/ (agent_error_widget.dart, settings_fab.dart)
│   └── printer_setup/
│       ├── domain/entities/printer_config.dart
│       ├── domain/repositories/printer_config_repository.dart
│       ├── data/repositories/printer_config_repository_impl.dart
│       └── presentation/
│           ├── pages/printer_setup_page.dart
│           ├── providers/printer_config_provider.dart
│           └── widgets/ (network_printer_form.dart, printer_type_selector.dart, usb_printer_selector.dart)
└── shared/
    └── widgets/
        ├── buttons/primary_button.dart
        └── inputs/custom_text_field.dart
```

**Nota:** A diferencia de lo documentado en `CLAUDE.md`, este proyecto **no usa Dio ni llamadas HTTP directas a una API REST**. La comunicación con el POS es 100% a través del WebView. La capa `data` de cada feature se limita a leer/escribir en `SecureStorage`.

---

## Convenciones de código

- **Idioma:** Todos los textos visibles están en español y centralizados en `AppStrings`.
- **Máximo 200–300 líneas por archivo.** Si un archivo crece, divídelo en widgets más pequeños.
- **Cero strings hardcodeados** en widgets — usar `AppStrings`.
- **Cero números mágicos** — usar `AppDimensions`.
- **Cero `TextStyle` o `Color` inline** — usar `AppTextStyles` / `AppColors`.
- **Sin gradientes.** Solo colores sólidos. Paleta basada en el verde QuickBill (`#6DBF47`).
- **Font:** `Inter` (GoogleFonts).
- **Arquitectura:** Clean Architecture por feature: `data → domain → presentation`.
- **State management:** Riverpod (`StateNotifier`, `AsyncNotifier`).
- **Routing:** GoRouter con constantes en `AppRoutes`.
- **Widgets puramente presentacionales.** La lógica vive en providers / notifiers / repositories / services.

---

## Flujo de la aplicación

1. **Splash** (`/`) — Verifica si existe `ServerConfig` en `SecureStorage`.
   - Si no existe → navega a `/setup`.
   - Si existe → navega a `/pos`.
2. **Setup** (`/setup`) — Formulario con host. Valida, guarda en `SecureStorage`, navega a `/pos`.
3. **POS Viewer** (`/pos`) — Carga `InAppWebView` con la URL construida desde `ServerConfig.agentUrl`.
   - Si HTTP error o network error → muestra `AgentErrorWidget`.
   - Botón superior de ajustes (icono settings) abre diálogo para reconfigurar servidor o configurar impresora.
   - Handler JS `toggleFullScreen` invocado desde F11.
   - Handler JS `print` recibe base64, decodifica y envía a `PrinterService`.
4. **Printer Setup** (`/printer-setup`) — Permite elegir entre impresora de red (IP + puerto) o USB Windows (dropdown de impresoras del sistema). Guarda config en `SecureStorage`.

---

## Comandos de build y test

```bash
# Ejecutar en modo debug (Windows)
flutter run -d windows

# Build para Windows release
flutter build windows

# Analizar código
flutter analyze

# Ejecutar tests (actualmente solo placeholder)
flutter test
```

---

## Instrucciones de testing

- El proyecto tiene un test placeholder en `test/widget_test.dart`.
- No hay tests unitarios ni de integración actualmente.
- Si agregas lógica de negocio compleja (validators, formatters, usecases), añade tests unitarios con `flutter_test`.
- Si agregas widgets complejos, añade widget tests.

---

## Consideraciones de seguridad

- Las credenciales (host, token) y la configuración de impresora se almacenan con `FlutterSecureStorage`, que en Windows usa el **Data Protection API (DPAPI)**.
- La URL del módulo de agentes se construye siempre con el esquema `https://` y la ruta `/agente-venta/login`.
- No hay manejo de certificados SSL personalizados ni pinning.
- El WebView permite JavaScript (`javaScriptEnabled: true`) y expone handlers nativos. Cualquier código ejecutado dentro del WebView tiene acceso a llamar `window.flutter_inappwebview.callHandler('print', ...)`.

---

## Dependencias nativas de Windows

- `win32` + `ffi`: Impresión directa a impresoras USB Windows vía spooler (`OpenPrinter`, `StartDocPrinter`, `WritePrinter`).
- PowerShell: Descubrimiento de impresoras instaladas (`Get-Printer`). Esto significa que la app depende de que PowerShell esté disponible y sin restricciones de ejecución de scripts en el entorno destino.
- `window_manager`: Control de ventana fullscreen. La app inicia en pantalla completa y F11 alterna el modo.

---

## Notas para agentes

- Este proyecto **no usa assets estáticos** actualmente (no existe carpeta `assets/`). Si necesitas agregar imágenes o fuentes locales, crea la carpeta y declárala en `pubspec.yaml`.
- No modifiques `Runner.rc` ni los archivos nativos de Windows a menos que sea estrictamente necesario (cambio de ícono, nombre de ejecutable, etc.).
- Mantén la coherencia con el idioma español en todos los textos de UI.
- Respeta el límite de líneas por archivo. `agent_viewer_page.dart` ya está cerca del límite (290 líneas); si necesitas agregar más lógica, extrae widgets o métodos privados a archivos separados dentro de `widgets/`.
