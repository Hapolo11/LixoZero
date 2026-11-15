import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

/// Um rótulo que o reconhecedor achou na foto, como "Bottle" (0,87).
class RotuloImagem {
  const RotuloImagem(this.texto, this.confianca);

  final String texto;
  final double confianca;
}

/// Descobre o que aparece numa foto. Roda no próprio aparelho (RNF06): a foto
/// não sai do celular.
abstract class ReconhecedorImagem {
  Future<List<RotuloImagem>> reconhecer(String caminhoDaFoto);
}

/// Reconhecimento com o ML Kit (Google). O modelo básico vai dentro do app,
/// então funciona sem internet.
class ReconhecedorMlKit implements ReconhecedorImagem {
  /// Rótulos com menos confiança que isso são descartados.
  static const confiancaMinima = 0.5;

  @override
  Future<List<RotuloImagem>> reconhecer(String caminhoDaFoto) async {
    final rotulador = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: confiancaMinima));
    try {
      final rotulos = await rotulador.processImage(InputImage.fromFilePath(caminhoDaFoto));
      return [for (final r in rotulos) RotuloImagem(r.label, r.confidence)];
    } finally {
      await rotulador.close();
    }
  }
}

enum OrigemFoto { camera, galeria }

/// Abre a câmera ou a galeria e devolve o caminho da foto (null se o usuário
/// desistir).
abstract class SeletorFoto {
  Future<String?> escolher(OrigemFoto origem);
}

class SeletorFotoImagePicker implements SeletorFoto {
  final _picker = ImagePicker();

  @override
  Future<String?> escolher(OrigemFoto origem) async {
    final foto = await _picker.pickImage(
      source: origem == OrigemFoto.camera ? ImageSource.camera : ImageSource.gallery,
      // Foto menor é mais rápida de analisar e basta para reconhecer o objeto.
      maxWidth: 1024,
      imageQuality: 85,
    );
    return foto?.path;
  }
}
