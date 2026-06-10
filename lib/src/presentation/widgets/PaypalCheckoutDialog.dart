import 'dart:math';
import 'package:flutter/material.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

/// Diálogo de checkout de PayPal para el pago de reservas de viaje.
/// [onCreateReservation] recibe el id de orden de PayPal generado y debe
/// crear la reserva contra el backend, devolviendo true si fue exitosa.
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
  int _step = 1; // 1: Login, 2: Procesando, 3: Éxito
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final String _orderId;

  @override
  void initState() {
    super.initState();
    _orderId = _generateOrderId();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _generateOrderId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    final suffix = List.generate(11, (_) => chars[rnd.nextInt(chars.length)]).join();
    return 'PAY-$suffix';
  }

  void _startPaymentProcess() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _step = 2);

    // Simular el procesamiento del pago en PayPal
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      setState(() => _step = 3);

      final success = await widget.onCreateReservation(_orderId);

      if (success) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pop(context); // Cerrar diálogo PayPal
            widget.onSuccess();
          }
        });
      } else {
        if (mounted) {
          Navigator.pop(context); // Cerrar diálogo PayPal
        }
      }
    });
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
    switch (_step) {
      case 1:
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo de PayPal (Estilo Dual Logo Oficial)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.paypal_rounded,
                    color: Color(0xFF00457C),
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

              // Caja de detalles del cobro
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comercio:',
                          style: TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'U-Ride Trip Reservation',
                          style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total a Pagar:',
                          style: TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${widget.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Correo electrónico',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'ejemplo@paypal.com',
                  hintStyle: const TextStyle(color: AppTheme.textFaint, fontWeight: FontWeight.normal),
                  prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppTheme.textMuted, size: 18),
                  filled: true,
                  fillColor: AppTheme.backgroundDark,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0079C1), width: 1.5)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu correo';
                  }
                  if (!value.contains('@')) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'Contraseña de PayPal',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: AppTheme.textFaint, fontWeight: FontWeight.normal),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textMuted, size: 18),
                  filled: true,
                  fillColor: AppTheme.backgroundDark,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0079C1), width: 1.5)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Botón de Pagar (Amarillo PayPal oficial)
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _startPaymentProcess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC439),
                    foregroundColor: const Color(0xFF003087),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Iniciar sesión para pagar',
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
          ),
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
              'Procesando pago seguro...',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'No cierres la aplicación',
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
            // Círculo verde de éxito
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
              '¡Pago Autorizado!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'Transacción: $_orderId',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Confirmando reserva...',
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
