import 'dart:async';
import 'package:checkin_frontend/core/providers/invitation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/enums/task_enums.dart';
import '../../../../core/providers/task_create/task_create_provider.dart';

class TaskSettingsSection extends ConsumerStatefulWidget {
  final DateTime? selectedDeadline;
  final bool requiresAuth;
  final SubtaskMode currentMode;

  final VoidCallback onDateTap;
  final ValueChanged<DateTime> onDateQuickSelect;
  final ValueChanged<bool> onAuthChanged;
  final ValueChanged<SubtaskMode> onModeChanged;
  final ValueChanged<String?> onDomainChanged;

  const TaskSettingsSection({
    super.key,
    required this.selectedDeadline,
    required this.requiresAuth,
    required this.currentMode,
    required this.onDateTap,
    required this.onDateQuickSelect,
    required this.onAuthChanged,
    required this.onModeChanged,
    required this.onDomainChanged,
  });

  @override
  // OPRAVA 1: Zmenené na ConsumerState
  ConsumerState<TaskSettingsSection> createState() => _TaskSettingsSectionState();
}

// OPRAVA 2: Dedenie z ConsumerState namiesto State
class _TaskSettingsSectionState extends ConsumerState<TaskSettingsSection> {
  bool _isDomainRestricted = false;
  final TextEditingController _domainController = TextEditingController();

  Timer? _debounce;
  bool? _isDomainValid;
  bool _isValidating = false;

  void _onDomainChanged(String value) {
    // 1. Zrušíme predchádzajúci časovač
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 2. Ak je pole prázdne, resetujeme stavy
    if (value.isEmpty) {
      setState(() {
        _isDomainValid = null;
        _isValidating = false;
      });
      widget.onDomainChanged(null);
      ref.read(taskCreateProvider.notifier).setDomainValidation(null);
      return;
    }

    // 3. Spustíme nový časovač (Debounce 500ms)
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      setState(() => _isValidating = true);

      try {
        final api = ref.read(invitationApiServiceProvider);
        // Tu vzniká premenná isValid po zavolaní API
        final isValid = await api.validateDomain(value);

        if (mounted) {
          setState(() {
            _isDomainValid = isValid;
            _isValidating = false;
          });

          // UPDATE PROVIDERA: Tu už isValid existuje a môžeme ho poslať do globálneho stavu
          widget.onDomainChanged(value);
          ref.read(taskCreateProvider.notifier).setDomainValidation(isValid);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isValidating = false;
            _isDomainValid = false; // Pri chybe siete to môžeme označiť za neoverené
          });
          ref.read(taskCreateProvider.notifier).setDomainValidation(false);
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _domainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // L'AVÝ STĹPEC
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel(cs, "Subtask Mode"), // context.l10n...
                const SizedBox(height: 8),
                _OptionButton(
                  title: "Collaborative",
                  subtitle: "Everyone shares one list",
                  icon: Icons.groups_outlined,
                  isSelected: widget.currentMode == SubtaskMode.shared,
                  onTap: () => widget.onModeChanged(SubtaskMode.shared),
                ),
                const SizedBox(height: 8),
                _OptionButton(
                  title: "Independent",
                  subtitle: "Everyone gets their own copy",
                  icon: Icons.person_outline,
                  isSelected: widget.currentMode == SubtaskMode.individual,
                  onTap: () => widget.onModeChanged(SubtaskMode.individual),
                ),
                const SizedBox(height: 24),
                _buildLabel(cs, "Deadline"),
                const SizedBox(height: 8),
                _buildDeadlineTrigger(cs),
                const SizedBox(height: 8),
                _buildQuickChips(cs),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // PRAVÝ STĹPEC
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel(cs, "Visibility & Access"),
                const SizedBox(height: 8),
                _OptionButton(
                  title: "Anyone with a link",
                  subtitle: "Public access, no login required",
                  icon: Icons.public,
                  isSelected: !widget.requiresAuth,
                  onTap: () => widget.onAuthChanged(false),
                ),
                const SizedBox(height: 8),
                _OptionButton(
                  title: "Only Google signed-in",
                  subtitle: "Private, identity verification required",
                  icon: Icons.account_circle_outlined,
                  isSelected: widget.requiresAuth,
                  onTap: () => widget.onAuthChanged(true),
                ),

                // Podmienený panel pre Private/Google access
                if (widget.requiresAuth) ...[
                  const SizedBox(height: 12),
                  _buildDomainSubPanel(cs),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(ColorScheme cs, String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: cs.onSurfaceVariant.withAlpha(180),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDeadlineTrigger(ColorScheme cs) {
    return InkWell(
      onTap: widget.onDateTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.selectedDeadline == null
                    ? "Set deadline"
                    : DateFormat('dd MMM yyyy').format(widget.selectedDeadline!),
                style: TextStyle(fontSize: 14, color: cs.onSurface),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChips(ColorScheme cs) {
    return Row(
      children: [
        _buildChip("1 Day", 1, cs),
        const SizedBox(width: 4),
        _buildChip("1 Week", 7, cs),
        const SizedBox(width: 4),
        _buildChip("1 Month", 30, cs),
      ],
    );
  }

  Widget _buildChip(String label, int days, ColorScheme cs) {
    return Expanded(
      child: InkWell(
        onTap: () => widget.onDateQuickSelect(DateTime.now().add(Duration(days: days))),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh.withAlpha(150),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface),
          ),
        ),
      ),
    );
  }

  Widget _buildDomainSubPanel(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isDomainValid == false ? cs.error : cs.primary.withAlpha(50),),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Domain restriction", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Switch(
                value: _isDomainRestricted,
                onChanged: (val) => setState(() => _isDomainRestricted = val),
              ),
            ],
          ),
          if (_isDomainRestricted) ...[
            const SizedBox(height: 4),
            TextField(
              controller: _domainController,
              // --- PRIDANÝ TENTO RIADOK ---
              onChanged: _onDomainChanged,
              style: TextStyle(
                color: _isDomainValid == false ? cs.error : cs.onSurface,
              ),
              decoration: InputDecoration(
                hintText: "vutbr.cz",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text("@", style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isDomainValid == false ? cs.error : cs.primary
                  )),
                ),
                // --- PRIDANÉ IKONY STAVU ---
                suffixIcon: _isValidating
                    ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : _isDomainValid == null
                    ? null
                    : Icon(
                  _isDomainValid! ? Icons.check_circle : Icons.error,
                  color: _isDomainValid! ? Colors.green : cs.error,
                ),
                isDense: true,
                filled: true,
                fillColor: cs.surface,
                // Červený border pri chybe
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _isDomainValid == false ? cs.error : cs.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _isDomainValid == false ? cs.error : cs.primary, width: 2),
                ),
              ),
            ),
            if (_isDomainValid == false)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  "Invalid domain or no mail servers found",
                  style: TextStyle(color: cs.error, fontSize: 11),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withAlpha(20) : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? cs.primary : cs.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}