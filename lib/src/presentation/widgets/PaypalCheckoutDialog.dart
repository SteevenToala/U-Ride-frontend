import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/trip-reservations/TripReservationsUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Diálogo de checkout de PayPal para el pago de reservas de viaje.
/// Llama al backend para crear una orden de PayPal, abre la página de pago real
/// y proporciona la verificación final contra la API REST de PayPal.
class PaypalCheckoutDialog extends StatefulWidget {
  final double total;
  final Future<bool> Function(String paypalOrderId) onCreateReservation;
  final VoidCallback onSuccess;

  const PaypalCheckoutDialog({
    super.key,
    required this.total,
    required this.onCreateReservation,
    required this.onSuccess,
  });

  @override
  State<PaypalCheckoutDialog> createState() => _PaypalCheckoutDialogState();
}

class _PaypalCheckoutDialogState extends State<PaypalCheckoutDialog> {
  final _useCases = GetIt.instance<TripReservationsUseCases>();
  
  bool _isLoading = true;
  String? _errorMessage;
  String? _paypalOrderId;
  String? _approveUrl;
  
  int _step = 1; // 1: Cargar/Redirigir a PayPal, 2: Procesando verificación, 3: Éxito

  @override
  void initState() {
    super.initState();
    _initiatePaypalOrder();
  }

  Future<void> _initiatePaypalOrder() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _useCases.createPaypalOrder.run(widget.total);
    if (!mounted) return;

    if (response is Success) {
      final data = (response as Success<Map<String, dynamic>>).data;
      final id = data['id'];
      final url = data['approveUrl'];

      if (id != null && url != null) {
        setState(() {
          _paypalOrderId = id;
          _approveUrl = url;
          _isLoading = false;
        });
        // Intentar abrir la URL automáticamente
        _launchPaypalUrl(url);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No se obtuvo información de pago de PayPal.';
        });
      }
    } else if (response is ErrorData) {
      setState(() {
        _isLoading = false;
        _errorMessage = (response as ErrorData).message;
      });
    }
  }

  Future<void> _launchPaypalUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      final success = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!success) {
        Fluttertoast.showToast(msg: 'No se pudo abrir automáticamente. Usa el botón "Abrir PayPal".');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error al abrir PayPal: $e');
    }
  }

  Future<void> _verifyAndSubmitPayment() async {
    if (_paypalOrderId == null) return;
    setState(() {
      _step = 2;
      _isLoading = true;
    });

    // Enviar el ID de orden real de PayPal al backend para que capture el dinero y guarde la reserva
    final success = await widget.onCreateReservation(_paypalOrderId!);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (success) {
      setState(() {
        _step = 3;
      });
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) {
          Navigator.pop(context); // Cerrar diálogo de PayPal
          widget.onSuccess();
        }
      });
    } else {
      // Si falla, volvemos a la pantalla de confirmación para que el usuario pueda reintentar
      setState(() {
        _step = 1;
      });
      Fluttertoast.showToast(
        msg: 'No pudimos verificar tu pago. Asegúrate de haber completado la transacción en PayPal.',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.backgroundDarkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(28),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _step == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(color: Color(0xFF0079C1), strokeWidth: 4),
          ),
          const SizedBox(height: 24),
          const Text(
            'Generando orden de PayPal...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Conectando con servidores seguros',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 54),
          const SizedBox(height: 16),
          const Text(
            'Error de Pago',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.backgroundDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cerrar'),
          ),
        ],
      );
    }

    switch (_step) {
      case 1:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo Oficial de PayPal
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.paypal_rounded,
                  color: Color(0xFF0079C1),
                  size: 32,
                ),
                const SizedBox(width: 4),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                    children: [
                      TextSpan(text: 'Pay', style: TextStyle(color: Color(0xFF00457C))),
                      TextSpan(text: 'Pal', style: TextStyle(color: Color(0xFF0079C1))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Caja informativa
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a Pagar:',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${widget.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, color: AppTheme.accentColor, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.borderSubtle, height: 20),
                  const Text(
                    'Se ha abierto la plataforma de pagos de PayPal en tu navegador.',
                    style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Instrucciones
            const Text(
              '1. Inicia sesión y autoriza el pago en la ventana externa.\n2. Al finalizar, regresa a esta app y presiona el botón "Confirmar y Verificar Pago".',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Botón de abrir de nuevo por si se cerró
            OutlinedButton.icon(
              onPressed: () => _launchPaypalUrl(_approveUrl!),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Abrir PayPal de nuevo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: AppTheme.borderSubtle),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // Botón de Pagar (Amarillo PayPal oficial)
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _verifyAndSubmitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC439),
                  foregroundColor: const Color(0xFF003087),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Confirmar y Verificar Pago',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: AppTheme.textMuted),
              child: const Text('Cancelar y volver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        );
      case 2:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(color: Color(0xFF0079C1), strokeWidth: 3.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Verificando transacción...',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Capturando fondos y creando reserva',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 24),
          ],
        );
      case 3:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 54,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Pago Capturado con éxito!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'Orden: $_paypalOrderId',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu reserva ya ha sido aprobada',
              style: TextStyle(color: AppTheme.textFaint, fontSize: 12),
            ),
            const SizedBox(height: 24),
          ],
        );
      default:
        return const SizedBox();
    }
  }
}
