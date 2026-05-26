import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class MiniMapa extends StatefulWidget {
  final String ambienteAlvo;
  const MiniMapa({super.key, required this.ambienteAlvo});

  @override
  State<MiniMapa> createState() => _MiniMapaState();
}

class _MiniMapaState extends State<MiniMapa>
    with SingleTickerProviderStateMixin {
  Position? _pos;
  bool _carregando = true;
  String? _erro;
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _atualizar();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _atualizar() async {
    setState(() { _carregando = true; _erro = null; });
    try {
      final pos = await LocationService.obterPosicao();
      setState(() { _pos = pos; _carregando = false; });
    } catch (e) {
      setState(() {
        _erro = e.toString().replaceAll('Exception: ', '');
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final destino = ambientesPUC.firstWhere(
      (a) => a.id == widget.ambienteAlvo,
      orElse: () => ambientesPUC.first,
    );

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F14).withOpacity(0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Título
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(
                destino.nome.split(' ').first,
                style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: _atualizar,
              child: const Icon(Icons.refresh,
                  color: Color(0xFF38BDF8), size: 12),
            ),
          ]),
          const SizedBox(height: 6),

          if (_carregando)
            const SizedBox(
              height: 70,
              child: Center(child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(
                    color: Color(0xFF38BDF8), strokeWidth: 1.5))),
            )
          else if (_erro != null)
            SizedBox(
              height: 70,
              child: Center(
                child: GestureDetector(
                  onTap: _atualizar,
                  child: const Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.gps_off, color: Color(0xFFEF4444), size: 20),
                    SizedBox(height: 4),
                    Text('GPS off\nToque p/ tentar',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFEF4444), fontSize: 8)),
                  ]),
                ),
              ),
            )
          else if (_pos != null) ...[
            _buildRadar(_pos!, destino),
            const SizedBox(height: 6),
            _buildInfo(_pos!, destino),
          ],
        ]),
      ),
    );
  }

  Widget _buildRadar(Position pos, Ambiente destino) {
    final dist = LocationService.distancia(
        pos.latitude, pos.longitude, destino.latitude, destino.longitude);
    final dentroRaio = dist <= destino.raioMetros;
    final angulo = math.atan2(
        destino.longitude - pos.longitude,
        destino.latitude - pos.latitude);

    return SizedBox(
      width: 64, height: 64,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Stack(alignment: Alignment.center, children: [
          // Radar background
          CustomPaint(
            size: const Size(64, 64),
            painter: _RadarPainter(dentroRaio: dentroRaio),
          ),
          // Ponto destino
          if (!dentroRaio)
            Transform.translate(
              offset: Offset(math.sin(angulo) * 21, -math.cos(angulo) * 21),
              child: Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.8),
                      blurRadius: 4)],
                ),
              ),
            ),
          // Seta
          if (!dentroRaio)
            Transform.rotate(
              angle: angulo,
              child: Transform.scale(
                scale: 0.9 + (_ctrl.value * 0.2),
                child: const Icon(Icons.navigation,
                    color: Color(0xFF38BDF8), size: 22),
              ),
            ),
          // Ponto jogador
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              color: dentroRaio
                  ? const Color(0xFF48D058)
                  : const Color(0xFF38BDF8),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                  color: (dentroRaio
                      ? const Color(0xFF48D058)
                      : const Color(0xFF38BDF8)).withOpacity(0.8),
                  blurRadius: 6)],
            ),
          ),
          // Badge chegou
          if (dentroRaio)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF48D058).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF48D058)),
              ),
              child: const Text('AQUI!',
                  style: TextStyle(
                      color: Color(0xFF48D058),
                      fontWeight: FontWeight.bold,
                      fontSize: 9)),
            ),
        ]),
      ),
    );
  }

  Widget _buildInfo(Position pos, Ambiente destino) {
    final dist = LocationService.distancia(
        pos.latitude, pos.longitude, destino.latitude, destino.longitude);
    final dentroRaio = dist <= destino.raioMetros;

    if (dentroRaio) {
      return const Text('✅ No local!',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Color(0xFF48D058),
              fontWeight: FontWeight.bold,
              fontSize: 9));
    }

    final angulo = math.atan2(
        destino.longitude - pos.longitude,
        destino.latitude - pos.latitude);
    final graus = (angulo * 180 / math.pi + 360) % 360;
    String dir;
    if (graus < 22.5 || graus >= 337.5) dir = '↑N';
    else if (graus < 67.5) dir = '↗NE';
    else if (graus < 112.5) dir = '→L';
    else if (graus < 157.5) dir = '↘SE';
    else if (graus < 202.5) dir = '↓S';
    else if (graus < 247.5) dir = '↙SO';
    else if (graus < 292.5) dir = '←O';
    else dir = '↖NO';

    final distStr = dist < 1000
        ? '${dist.toInt()}m'
        : '${(dist / 1000).toStringAsFixed(1)}km';

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(distStr,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11)),
      const SizedBox(width: 6),
      Text(dir,
          style: const TextStyle(
              color: Color(0xFF38BDF8),
              fontWeight: FontWeight.bold,
              fontSize: 11)),
    ]);
  }
}

class _RadarPainter extends CustomPainter {
  final bool dentroRaio;
  _RadarPainter({required this.dentroRaio});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final cor = dentroRaio
        ? const Color(0xFF48D058)
        : const Color(0xFF38BDF8);

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, size.width / 2 * (i / 3),
          Paint()
            ..color = cor.withOpacity(0.07 * i)
            ..style = PaintingStyle.fill);
      canvas.drawCircle(center, size.width / 2 * (i / 3),
          Paint()
            ..color = cor.withOpacity(0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5);
    }

    final crossPaint = Paint()
      ..color = cor.withOpacity(0.15)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(center.dx, 0),
        Offset(center.dx, size.height), crossPaint);
    canvas.drawLine(Offset(0, center.dy),
        Offset(size.width, center.dy), crossPaint);
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.dentroRaio != dentroRaio;
}
