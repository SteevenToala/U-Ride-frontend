import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/Report.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/reports/bloc/AdminReportsBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/reports/bloc/AdminReportsEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class AdminReportItem extends StatelessWidget {
  final Report report;

  const AdminReportItem(this.report, {super.key});

  // ── Status helpers ───────────────────────────────────────────────────────

  Color _statusColor() {
    switch (report.status) {
      case ReportStatus.OPEN:           return Colors.orange;
      case ReportStatus.REVIEWED:       return Colors.blue;
      case ReportStatus.WARNED:         return Colors.amber;
      case ReportStatus.ACTION_APPLIED: return Colors.redAccent;
      case ReportStatus.DISMISSED:      return Colors.grey;
    }
  }

  String _statusLabel() {
    switch (report.status) {
      case ReportStatus.OPEN:           return 'Abierto';
      case ReportStatus.REVIEWED:       return 'En revisión';
      case ReportStatus.WARNED:         return 'Advertido';
      case ReportStatus.ACTION_APPLIED: return 'Suspendido';
      case ReportStatus.DISMISSED:      return 'Desestimado';
    }
  }

  IconData _statusIcon() {
    switch (report.status) {
      case ReportStatus.OPEN:           return Icons.inbox_rounded;
      case ReportStatus.REVIEWED:       return Icons.search_rounded;
      case ReportStatus.WARNED:         return Icons.warning_amber_rounded;
      case ReportStatus.ACTION_APPLIED: return Icons.block_rounded;
      case ReportStatus.DISMISSED:      return Icons.do_not_disturb_rounded;
    }
  }

  bool get _isResolvable =>
      report.status == ReportStatus.OPEN || report.status == ReportStatus.REVIEWED;

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // ── Header strip ────────────────────────────────────────────────
          _buildHeader(color),
          // ── Body ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _userTile(label: 'Reportado por', user: report.reporter, userId: report.reporterUserId)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: AppTheme.textFaint, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: _userTile(label: 'Reportado', user: report.reported, userId: report.reportedUserId, highlighted: true)),
                  ],
                ),
                const SizedBox(height: 14),
                // Reason
                _sectionLabel('Motivo del reporte'),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Text(report.reason, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                ),
                // Admin notes (if any)
                if (report.adminNotes != null && report.adminNotes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sectionLabel('Notas del administrador'),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.sticky_note_2_outlined, size: 14, color: color),
                        const SizedBox(width: 8),
                        Expanded(child: Text(report.adminNotes!, style: TextStyle(color: color, fontSize: 12, height: 1.4))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Date + evidence
                Row(
                  children: [
                    if (report.createdAt != null) ...[
                      const Icon(Icons.access_time_rounded, size: 12, color: AppTheme.textFaint),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(report.createdAt!),
                        style: const TextStyle(color: AppTheme.textFaint, fontSize: 11),
                      ),
                    ],
                    const Spacer(),
                    if (report.evidenceUrl != null && report.evidenceUrl!.isNotEmpty)
                      Chip(
                        label: const Text('Con evidencia', style: TextStyle(fontSize: 10, color: Colors.white)),
                        avatar: const Icon(Icons.attachment_rounded, size: 12, color: Colors.white),
                        backgroundColor: Colors.green.withOpacity(0.25),
                        side: BorderSide(color: Colors.green.withOpacity(0.4)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                      ),
                  ],
                ),
                // ── Action buttons ───────────────────────────────────────
                if (_isResolvable) ...[
                  const SizedBox(height: 14),
                  const Divider(color: AppTheme.borderSubtle),
                  const SizedBox(height: 10),
                  _buildActionButtons(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(_statusIcon(), color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            'Reporte #${report.id}',
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const Spacer(),
          _StatusBadge(label: _statusLabel(), color: color, icon: _statusIcon()),
        ],
      ),
    );
  }

  Widget _userTile({required String label, User? user, required int userId, bool highlighted = false}) {
    final name = user != null ? '${user.name} ${user.lastname}' : 'ID $userId';
    final subtitle = user?.career ?? user?.email ?? '';
    final accentColor = highlighted ? Colors.redAccent : AppTheme.accentColor;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: highlighted ? Colors.redAccent.withOpacity(0.3) : AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: accentColor.withOpacity(0.12),
            backgroundImage: user?.image != null ? NetworkImage(user!.image!) : null,
            child: user?.image == null
                ? Icon(Icons.person, color: accentColor, size: 18)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textFaint, fontSize: 10)),
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12), overflow: TextOverflow.ellipsis),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5));
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCIONES DISPONIBLES',
          style: TextStyle(color: AppTheme.textFaint, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Mark as reviewing
            Expanded(
              child: _actionBtn(
                label: 'Revisar',
                icon: Icons.search_rounded,
                color: Colors.blue,
                onTap: () => _resolveWithStatus(context, 'REVIEWED'),
              ),
            ),
            const SizedBox(width: 8),
            // Warn
            Expanded(
              child: _actionBtn(
                label: 'Advertir',
                icon: Icons.warning_amber_rounded,
                color: Colors.amber,
                onTap: () => _showWarnDialog(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Suspend
            Expanded(
              child: _actionBtn(
                label: 'Suspender',
                icon: Icons.block_rounded,
                color: Colors.redAccent,
                filled: true,
                onTap: () => _showSuspendDialog(context),
              ),
            ),
            const SizedBox(width: 8),
            // Dismiss
            Expanded(
              child: _actionBtn(
                label: 'Desestimar',
                icon: Icons.do_not_disturb_rounded,
                color: Colors.grey,
                onTap: () => _resolveWithStatus(context, 'DISMISSED'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? color.withOpacity(0.15) : AppTheme.inputFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(filled ? 0.5 : 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ── Dialog helpers ───────────────────────────────────────────────────────

  int _getAdminId(BuildContext context) =>
      context.read<ProfileInfoBloc>().state.user?.id ?? 0;

  void _resolveWithStatus(BuildContext context, String status, {String? notes, String? suspendUntil}) {
    context.read<AdminReportsBloc>().add(ResolveReport(
      reportId: report.id!,
      status: status,
      adminNotes: notes,
      suspendUntil: suspendUntil,
      adminUserId: _getAdminId(context),
    ));
  }

  void _showWarnDialog(BuildContext context) {
    final notesCtrl = TextEditingController();
    final adminId = _getAdminId(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 22),
            SizedBox(width: 8),
            Text('Emitir Advertencia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enviarás una advertencia formal al usuario reportado. Esta acción quedará registrada.',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Mensaje de advertencia',
                labelStyle: const TextStyle(color: AppTheme.textMuted),
                hintText: 'Describe el motivo de la advertencia...',
                hintStyle: const TextStyle(color: AppTheme.textFaint, fontSize: 12),
                filled: true,
                fillColor: AppTheme.inputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.amber)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.warning_amber_rounded, size: 16),
            label: const Text('Advertir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminReportsBloc>().add(ResolveReport(
                reportId: report.id!,
                status: 'WARNED',
                adminNotes: notesCtrl.text.trim().isEmpty ? 'Advertencia emitida por conducta inapropiada.' : notesCtrl.text.trim(),
                adminUserId: adminId,
              ));
            },
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(BuildContext context) {
    final notesCtrl = TextEditingController();
    DateTime? suspendUntil;
    final adminId = _getAdminId(context);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.backgroundDarkCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: const [
              Icon(Icons.block_rounded, color: Colors.redAccent, size: 22),
              SizedBox(width: 8),
              Text('Suspender Usuario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'El usuario no podrá acceder a la plataforma hasta la fecha indicada.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 14),
                // Date picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(primary: Colors.redAccent),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setDialogState(() => suspendUntil = picked);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.inputFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: suspendUntil == null ? Colors.redAccent.withOpacity(0.4) : Colors.redAccent),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          suspendUntil == null
                              ? 'Seleccionar fecha de suspensión *'
                              : 'Suspendido hasta: ${_formatDate(suspendUntil!)}',
                          style: TextStyle(
                            color: suspendUntil == null ? AppTheme.textMuted : Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Motivo de suspensión (opcional)',
                    labelStyle: const TextStyle(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.block_rounded, size: 16),
              label: const Text('Suspender'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: suspendUntil == null
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      context.read<AdminReportsBloc>().add(ResolveReport(
                        reportId: report.id!,
                        status: 'ACTION_APPLIED',
                        adminNotes: notesCtrl.text.trim().isEmpty ? 'Suspensión temporal aplicada.' : notesCtrl.text.trim(),
                        suspendUntil: suspendUntil!.toIso8601String(),
                        adminUserId: adminId,
                      ));
                    },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

// ── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
