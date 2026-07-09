abstract final class AppStrings {
  // App
  static const appName = 'QuickBill Agentes';

  // Setup
  static const setupTitle = 'Configurar servidor';
  static const setupSubtitle = 'Ingresa el host de tu servidor QuickBill';
  static const hostLabel = 'Servidor';
  static const hostHint = 'ej: demo.quickbillcr.com';
  static const connectButton = 'Conectar';
  static const hostRequired = 'El servidor es requerido';

  // Security
  static const securitySectionTitle = 'Configuración de acceso (avanzado)';
  static const headerNameLabel = 'Nombre del header';
  static const headerNameHint = 'ej: X-QB-Agente-App';
  static const headerValueLabel = 'Valor esperado del header';
  static const headerValueHint = 'ej: flutter-webview';
  static const userAgentLabel = 'User-Agent esperado';
  static const userAgentHint = 'ej: QuickBillAgenteFlutter';
  static const securityDefaultsHint = 'Dejar en blanco para usar los valores por defecto del sistema.';

  // Agent Viewer error
  static const errorTitle = 'Servidor no disponible';
  static const errorBody =
      'El servidor se encuentra mal configurado o no responde. '
      'Por favor verifique o vuelva a configurarlo.';
  static const errorReconfigure = 'Volver a configurar';

  // General
  static const cancelButton = 'Cancelar';

  // Settings menu
  static const settingsReconfigure = 'Reconfigurar servidor';
  static const settingsConfigurePrinter = 'Configurar impresora';

  // Printer setup
  static const printerSetupTitle = 'Configurar impresora';
  static const printerSetupSubtitle = 'Selecciona el tipo de conexión';
  static const printerTypeNetwork = 'Red (IP)';
  static const printerTypeUsb = 'USB (Windows)';
  static const printerIpLabel = 'Dirección IP';
  static const printerIpHint = 'ej: 192.168.1.100';
  static const printerPortLabel = 'Puerto';
  static const printerPortHint = '9100';
  static const printerNameLabel = 'Impresora instalada';
  static const printerNameHint = 'Selecciona una impresora';
  static const printerSaveButton = 'Guardar impresora';
  static const printerTestButton = 'Imprimir prueba';
  static const printerIpRequired = 'La IP es requerida';
  static const printerPortRequired = 'El puerto es requerido';
  static const printerNameRequired = 'Selecciona una impresora';
  static const printerSaveSuccess = 'Impresora guardada';
  static const printerTestSuccess = 'Prueba enviada';
  static const printerError = 'Error de impresión: ';
  static const printerLoadingList = 'Cargando impresoras...';
  static const printerNoneFound = 'No se encontraron impresoras instaladas';
  static const noPrinterTitle = 'Sin impresora configurada';
  static const noPrinterBody =
      'No hay ninguna impresora configurada. '
      'Ve a ajustes y configura una antes de imprimir.';
  static const noPrinterAction = 'Configurar ahora';
}
