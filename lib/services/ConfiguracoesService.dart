import 'package:flutter/foundation.dart';

class ConfiguracoesService extends ChangeNotifier {
  static final ConfiguracoesService _instance =
      ConfiguracoesService._internal();

  factory ConfiguracoesService() => _instance;

  ConfiguracoesService._internal();

  double _volume = 0.7;
  double _luminosidade = 1;
  bool _somAtivo = true;

  double get volume => _somAtivo ? _volume : 0;
  double get volumeSalvo => _volume;
  double get luminosidade => _luminosidade;
  bool get somAtivo => _somAtivo;

  void atualizarVolume(double valor) {
    _volume = valor.clamp(0, 1).toDouble();
    if (_volume > 0 && !_somAtivo) {
      _somAtivo = true;
    }
    notifyListeners();
  }

  void alternarSom(bool ativo) {
    _somAtivo = ativo;
    notifyListeners();
  }

  void atualizarLuminosidade(double valor) {
    _luminosidade = valor.clamp(0.25, 1).toDouble();
    notifyListeners();
  }

  void restaurarPadrao() {
    _volume = 0.7;
    _luminosidade = 1;
    _somAtivo = true;
    notifyListeners();
  }
}
