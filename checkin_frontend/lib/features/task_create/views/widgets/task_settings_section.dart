import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import enum pre subtaskMode už tu nepotrebujeme

class TaskSettingsSection extends StatelessWidget {
  final DateTime? selectedDeadline;
  final bool requiresAuth;

  final VoidCallback onDateTap;
  final VoidCallback onAuthToggle;

  const TaskSettingsSection({
    super.key,
    required this.selectedDeadline,
    required this.requiresAuth,
    required this.onDateTap,
    required this.onAuthToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row( // Zmenené z Column na Row
      crossAxisAlignment: CrossAxisAlignment.start, // Zarovnaj hore
      children: [
        // 1. Dátum (50%)
        Expanded(
          child: InkWell(
            onTap: onDateTap,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Deadline",
                border: OutlineInputBorder(),
                isDense: true, // Kompaktnejšie
                suffixIcon: Icon(Icons.calendar_today, size: 20),
              ),
              child: Text(
                selectedDeadline == null
                    ? "Select"
                    : DateFormat('dd.MM.yyyy').format(selectedDeadline!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12), // Medzera

        // 2. Auth Toggle (50%)
        Expanded(
          child: SizedBox(
            height: 50, // Nastavíme výšku, aby ladila s Inputom vedľa
            child: FloatingActionButton.extended(
              heroTag: "authSettingsBtn", // Dôležité: Unikátny tag
              elevation: 0, // 0 vyzerá lepšie vedľa inputu (bez tieňa), ale môžeš zmazať

              onPressed: onAuthToggle, // Voláme funkciu od rodiča

              foregroundColor: requiresAuth ? Colors.blue : Colors.grey,
              backgroundColor: requiresAuth ? Colors.blue[50] : Colors.white,

              // Pridáme orámovanie, aby to ladilo s Dátumom vedľa
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // Rovnaké rohy ako Input
                side: const BorderSide(color: Colors.white24),

              ),

              icon: Icon(requiresAuth ? Icons.lock : Icons.lock_open),
              label: Text(
                requiresAuth ? "Verified Only" : "Public",
                // Tu už nedávame SizedBox width 190, lebo sme v Expanded
                // a chceme využiť dostupné miesto
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}