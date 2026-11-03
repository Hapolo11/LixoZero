import 'package:geolocator/geolocator.dart';

enum FalhaLocalizacao { gpsDesligado, semPermissao, semSinal }

typedef Posicao = ({double lat, double lng});

/// A posição só é usada para ordenar os pontos por distância. Não é salva.
class LocalizacaoService {
  Future<({Posicao? posicao, FalhaLocalizacao? falha})> posicaoAtual() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return (posicao: null, falha: FalhaLocalizacao.gpsDesligado);
      }

      var permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }
      if (permissao == LocationPermission.denied || permissao == LocationPermission.deniedForever) {
        return (posicao: null, falha: FalhaLocalizacao.semPermissao);
      }

      final pos = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 8),
            ),
          );
      return (posicao: (lat: pos.latitude, lng: pos.longitude), falha: null);
    } catch (_) {
      // Normalmente é o GPS que não respondeu a tempo.
      return (posicao: null, falha: FalhaLocalizacao.semSinal);
    }
  }

  Future<void> abrirConfiguracoes(FalhaLocalizacao falha) async {
    if (falha == FalhaLocalizacao.gpsDesligado) {
      await Geolocator.openLocationSettings();
    } else if (falha == FalhaLocalizacao.semPermissao &&
        await Geolocator.checkPermission() == LocationPermission.deniedForever) {
      // Quando o usuário marcou "não perguntar de novo", só pelas configurações.
      await Geolocator.openAppSettings();
    }
  }
}
