import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/lembrete.dart';

/// Agenda as notificações dos lembretes de coleta (RF04).
///
/// Fica atrás desta interface para os testes usarem uma versão falsa, sem
/// depender do sistema de notificações do aparelho.
abstract class Notificacoes {
  Future<void> iniciar();

  /// Pede permissão para notificar (Android 13+ e iOS). Devolve se foi aceita.
  Future<bool> pedirPermissao();

  /// Agenda uma notificação semanal para cada dia do lembrete.
  Future<void> agendar(Lembrete lembrete);

  Future<void> cancelar(Lembrete lembrete);
}

/// Cada dia do lembrete vira uma notificação com id próprio: 3 dias = 3 ids.
int idNotificacao(Lembrete lembrete, int dia) => lembrete.id * 10 + dia;

/// Próxima data em que cai [dia] da semana às [hora]:[minuto], a partir de [agora].
/// Se for hoje e o horário ainda não passou, é hoje mesmo.
tz.TZDateTime proximaOcorrencia(tz.TZDateTime agora, int dia, int hora, int minuto) {
  var data = tz.TZDateTime(agora.location, agora.year, agora.month, agora.day, hora, minuto);
  while (data.weekday != dia || !data.isAfter(agora)) {
    data = tz.TZDateTime(agora.location, data.year, data.month, data.day + 1, hora, minuto);
  }
  return data;
}

class NotificacoesLocais implements Notificacoes {
  NotificacoesLocais([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _canal = AndroidNotificationDetails(
    'lembretes_coleta',
    'Lembretes de coleta',
    channelDescription: 'Avisos do dia e horário da coleta seletiva',
    importance: Importance.high,
    priority: Priority.high,
    color: Color(0xFF007F3D), // verde escuro do app
  );

  @override
  Future<void> iniciar() async {
    tzdata.initializeTimeZones();
    try {
      final fuso = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(fuso.identifier));
    } catch (e) {
      // Sem o fuso do aparelho, usa o de Aracaju (UTC-3, igual a São Paulo).
      debugPrint('Fuso não encontrado: $e');
      tz.setLocalLocation(tz.getLocation('America/Maceio'));
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notificacao'),
        iOS: DarwinInitializationSettings(
          // A permissão só é pedida quando o usuário cria o primeiro lembrete.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<bool> pedirPermissao() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? false;

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) return await ios.requestPermissions(alert: true, sound: true) ?? false;

    return false;
  }

  @override
  Future<void> agendar(Lembrete lembrete) async {
    final agora = tz.TZDateTime.now(tz.local);
    final modo = await _modoAndroid();
    for (final dia in lembrete.dias) {
      await _plugin.zonedSchedule(
        id: idNotificacao(lembrete, dia),
        title: 'Hoje tem coleta seletiva',
        body: '${lembrete.titulo} às ${lembrete.horario}',
        scheduledDate: proximaOcorrencia(agora, dia, lembrete.hora, lembrete.minuto),
        notificationDetails: const NotificationDetails(android: _canal, iOS: DarwinNotificationDetails()),
        androidScheduleMode: modo,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Alarme exato quando o Android deixa. O inexato pode atrasar até 1 hora
  /// (visto no emulador), o que faria o aviso chegar depois do caminhão.
  /// No Android 14+ o exato vem desligado, e aí fica o inexato mesmo, sem
  /// mandar o usuário para as configurações.
  Future<AndroidScheduleMode> _modoAndroid() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final podeExato = await android?.canScheduleExactNotifications() ?? false;
    return podeExato ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  @override
  Future<void> cancelar(Lembrete lembrete) async {
    // Cancela os 7 dias, porque o lembrete pode ter mudado de dias na edição.
    for (var dia = DateTime.monday; dia <= DateTime.sunday; dia++) {
      await _plugin.cancel(id: idNotificacao(lembrete, dia));
    }
  }
}

/// Usada se o sistema de notificações falhar ao iniciar: os lembretes
/// continuam salvos e aparecem na tela, só não tocam.
class NotificacoesDesligadas implements Notificacoes {
  const NotificacoesDesligadas();

  @override
  Future<void> iniciar() async {}

  @override
  Future<bool> pedirPermissao() async => false;

  @override
  Future<void> agendar(Lembrete lembrete) async {}

  @override
  Future<void> cancelar(Lembrete lembrete) async {}
}
