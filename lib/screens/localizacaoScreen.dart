import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/LocalizacaoService.dart';

class LocalizacaoScreen extends StatefulWidget {
  const LocalizacaoScreen({super.key});
  @override
  State<LocalizacaoScreen> createState() => _LocalizacaoScreenState();
}

class _LocalizacaoScreenState extends State<LocalizacaoScreen> {
  final LocalizacaoService _service = LocalizacaoService();
  Position? _posicao;
  String? _erro;
  bool _carregando = false;

  Future<void> _obter() async {
    setState(() { _carregando = true; _erro = null; _posicao = null; });
    try {
      final p = await _service.obterPosicaoAtual();
      setState(() { _posicao = p; _carregando = false; });
    } catch (e) {
      setState(() { _erro = e.toString().replaceAll('Exception: ', ''); _carregando = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1040),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1040), elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFA78BFA)),
        title: const Text('LOCALIZAÇÃO', style: TextStyle(fontFamily: 'monospace', fontSize: 12, letterSpacing: 3, color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: Color(0xFF2D1B69))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.15),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: const Color(0xFFA78BFA).withOpacity(0.4), width: 1.5),
            ),
            child: const Icon(Icons.my_location_rounded, color: Color(0xFFA78BFA), size: 32),
          ),
          const SizedBox(height: 28),
          if (_carregando) ...[
            const CircularProgressIndicator(color: Color(0xFFA78BFA), strokeWidth: 2),
            const SizedBox(height: 12),
            const Text('Obtendo GPS...', style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFF7C6FAF))),
          ],
          if (_erro != null) ...[
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF200808), borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4))),
              child: Column(children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFF87171), size: 26),
                const SizedBox(height: 8),
                Text(_erro!, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFFF87171), height: 1.6)),
              ]),
            ),
            const SizedBox(height: 16),
          ],
          if (_posicao != null) ...[
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF100840), borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA78BFA).withOpacity(0.4))),
              child: Column(children: [
                const Icon(Icons.check_circle_outline_rounded, color: Color(0xFFA78BFA), size: 26),
                const SizedBox(height: 12),
                _row('Latitude', _posicao!.latitude.toStringAsFixed(6)),
                const SizedBox(height: 6),
                _row('Longitude', _posicao!.longitude.toStringAsFixed(6)),
                const SizedBox(height: 6),
                _row('Precisão', '${_posicao!.accuracy.toStringAsFixed(1)} m'),
              ]),
            ),
            const SizedBox(height: 16),
          ],
          if (!_carregando)
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 18),
                label: Text(_posicao != null ? 'ATUALIZAR' : 'CAPTURAR GPS',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.white)),
                onPressed: _obter,
              ),
            ),
        ]),
      ),
    );
  }

  Widget _row(String l, String v) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFF7C6FAF))),
      Text(v, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFC4B5FD), fontWeight: FontWeight.bold)),
    ],
  );
}
