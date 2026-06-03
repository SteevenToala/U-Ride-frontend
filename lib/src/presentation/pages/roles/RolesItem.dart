import 'package:flutter/material.dart';
import 'package:indriver_clone_flutter/src/domain/models/Role.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class RolesItem extends StatelessWidget {
  final Role role;

  const RolesItem(this.role, {super.key});

  bool get _isPassenger => role.id == 'STUDENT';

  Color get _color => _isPassenger ? AppTheme.passengerColor : AppTheme.driverColor;
  Color get _colorLight => _isPassenger ? AppTheme.passengerColorLight : AppTheme.driverColorLight;
  LinearGradient get _gradient => _isPassenger ? AppTheme.passengerGradient : AppTheme.driverGradient;
  IconData get _icon => _isPassenger ? Icons.person_rounded : Icons.directions_car_rounded;
  String get _badge => _isPassenger ? 'PASAJERO' : 'CONDUCTOR';
  String get _subtitle => _isPassenger
      ? 'Busca y reserva viajes compartidos'
      : 'Publica rutas y genera ingresos';
  String get _feature1 => _isPassenger ? 'Reserva en segundos' : 'Publica tu ruta';
  String get _feature2 => _isPassenger ? 'Paga la tarifa justa' : 'Tú defines el precio';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamedAndRemoveUntil(context, role.route, (route) => false);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _color.withValues(alpha: 0.22),
              _colorLight.withValues(alpha: 0.10),
            ],
          ),
          border: Border.all(color: _color.withValues(alpha: 0.55), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _color.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              _backgroundDecoration(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topRow(),
                    const SizedBox(height: 14),
                    _divider(),
                    const SizedBox(height: 12),
                    _featureRow(),
                    const SizedBox(height: 16),
                    _ctaButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backgroundDecoration() {
    return Positioned(
      right: -30,
      top: -30,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _color.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  Widget _topRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: _gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _color.withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(_icon, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                role.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios_rounded, color: _colorLight, size: 18),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }

  Widget _featureRow() {
    return Row(
      children: [
        _featureChip(Icons.check_circle_outline_rounded, _feature1),
        const SizedBox(width: 10),
        _featureChip(Icons.monetization_on_outlined, _feature2),
      ],
    );
  }

  Widget _featureChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: _colorLight),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctaButton() {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'ENTRAR COMO $_badge',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
