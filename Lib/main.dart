import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const SOSAutoApp());
}

class SOSAutoApp extends StatelessWidget {
  const SOSAutoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S.O.S. Auto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFD32F2F),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MainMapScreen(),
    );
  }
}

class MainMapScreen extends StatefulWidget {
  const MainMapScreen({super.key});

  @override
  State<MainMapScreen> createState() => _MainMapScreenState();
}

class _MainMapScreenState extends State<MainMapScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final String _wompiUrl = 'https://checkout.wompi.co/l/VPOS_3Odu3K';

  // Disparador de emergencia con cuenta regresiva de 5 segundos
  void _triggerEmergency(String alertType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EmergencyCountdownDialog(
          alertType: alertType,
          onCancelWithPin: _verifySecurityPin,
        );
      },
    );
  }

  // Verificación biométrica o por PIN para anulación de falsos positivos
  Future<bool> _verifySecurityPin() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Ingrese su PIN o biometría para cancelar la alerta de emergencia',
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      return authenticated;
    } catch (e) {
      return false;
    }
  }

  // Enlace oficial Wompi para aliados y pauta comercial
  Future<void> _openWompi() async {
    final Uri url = Uri.parse(_wompiUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la pasarela Wompi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S.O.S. Auto - Asistencia Vial'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Capa de Mapa Interactivo
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Text(
                '🗺️ Mapa Interactivo S.O.S. Auto\n(Cámaras, vía mojada, límites y aliados)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          ),
          
          // Banner publicitario no intrusivo superior
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.campaign, color: Colors.amber, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Paute con Nosotros | Aliados en ruta',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botones Flotantes Permanentes sobre el Mapa
          Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(45),
                  ),
                  onPressed: () => _triggerEmergency('Estoy en Peligro'),
                  icon: const Icon(Icons.warning_amber),
                  label: const Text('🔴 Estoy en Peligro'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(45),
                  ),
                  onPressed: () => _triggerEmergency('Robo de Auto'),
                  icon: const Icon(Icons.car_crash),
                  label: const Text('🟠 Robo de Auto'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(45),
                  ),
                  onPressed: () => _triggerEmergency('Estoy Varado'),
                  icon: const Icon(Icons.build),
                  label: const Text('🟡 Estoy Varado'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(40),
                  ),
                  onPressed: _openWompi,
                  icon: const Icon(Icons.payment, color: Colors.blue),
                  label: const Text('📢 Paute con Nosotros (Wompi)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Diálogo de cuenta regresiva de 5 segundos con anulación por PIN/Biometría
class EmergencyCountdownDialog extends StatefulWidget {
  final String alertType;
  final Future<bool> Function() onCancelWithPin;

  const EmergencyCountdownDialog({
    super.key,
    required this.alertType,
    required this.onCancelWithPin,
  });

  @override
  State<EmergencyCountdownDialog> createState() => _EmergencyCountdownDialogState();
}

class _EmergencyCountdownDialogState extends State<EmergencyCountdownDialog> {
  int _secondsLeft = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
        if (mounted) {
          Navigator.of(context).pop();
          _sendEmergencyAlert();
        }
      }
    });
  }

  void _sendEmergencyAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('⚠️ Alerta "${widget.alertType}" transmitida con éxito.')),
    );
  }

  void _handleCancel() async {
    _timer?.cancel();
    bool authenticated = await widget.onCancelWithPin();
    if (authenticated) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Alerta cancelada correctamente mediante clave/biometría.')),
        );
      }
    } else {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('EMERGENCIA: ${widget.alertType}', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Transmitiendo ubicación en:'),
          const SizedBox(height: 10),
          Text(
            '$_secondsLeft',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 10),
          const Text('Si activó por error, confirme su PIN o huella para anular.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _handleCancel,
          child: const Text('CANCELAR ALERTA', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
