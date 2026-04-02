// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'OmniService Hub';

  @override
  String get businessActive => 'Negocio Activo';

  @override
  String get tenantIdLabel => 'ID de Inquilino';

  @override
  String get regionalPrecision => 'Precisión Regional';

  @override
  String get samplePrice => 'Precio de Muestra';

  @override
  String get currentDate => 'Fecha Actual';

  @override
  String get durationLabel => 'Duración (min)';

  @override
  String get conflictError =>
      'Este horario ya está reservado. Por favor, elige otro.';

  @override
  String get bookingSuccess => '¡Reserva confirmada! Pendiente de aprobación.';

  @override
  String get pending => 'Pendiente';

  @override
  String get confirmed => 'Confirmado';

  @override
  String get cancelled => 'Cancelado';

  @override
  String get approve => 'Aprobar';

  @override
  String get reschedule => 'Reprogramar';

  @override
  String get loading => 'Cargando...';

  @override
  String get appTitle => 'Panel de OmniService Hub';

  @override
  String get bookNow => 'Reservar Ahora';

  @override
  String get settings => 'Configuración';

  @override
  String get currencySymbol => '\$';

  @override
  String get paymentConfirmed => 'Pago Confirmado';

  @override
  String get selectService => 'Seleccionar un Servicio';

  @override
  String get welcomeBack =>
      'Bienvenido de nuevo. Por favor, inicie sesión para continuar.';

  @override
  String get emailLabel => 'Correo Electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get signInButton => 'Iniciar Sesión';

  @override
  String get noAccount => '¿No tienes una cuenta? Crear un negocio';

  @override
  String get startBusiness => 'Inicia tu Negocio';

  @override
  String get createBusinessDesc =>
      'Crea tu cuenta e inicializa tu centro de servicios en segundos.';

  @override
  String get businessNameLabel => 'Nombre del Negocio';

  @override
  String get businessNameHint => 'ej. Fontanería Acme';

  @override
  String get businessNameRequired => 'Nombre del Negocio es requerido';

  @override
  String get createAccountButton => 'Crear Cuenta';

  @override
  String get haveAccount => '¿Ya tienes una cuenta? Iniciar Sesión';

  @override
  String get businessTypeLabel => 'Business Type';

  @override
  String get businessTypeHint => 'e.g. Salon, Consulting, Logistics';

  @override
  String get manageServices => 'Gestionar Servicios';

  @override
  String get manageAppointments => 'Gestionar Citas';

  @override
  String get addService => 'Agregar Nuevo Servicio';

  @override
  String get serviceName => 'Nombre del Servicio';

  @override
  String get description => 'Descripción';

  @override
  String get price => 'Precio';

  @override
  String get add => 'Agregar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirmDelete =>
      '¿Estás seguro de que quieres eliminar este servicio?';
}
