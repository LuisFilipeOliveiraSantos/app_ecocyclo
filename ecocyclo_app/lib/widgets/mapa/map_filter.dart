import 'package:ecocyclo_app/widgets/mapa/map_search_bar.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
// Importe seus widgets originais de Card e Chip aqui:
// import 'selectable_filter_card.dart'; 
// import 'filter_chip.dart';

class MapFilterSheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<String> availableFilters;
  final List<String> selectedFilters;
  final Function(String) onToggleFilter;
  final VoidCallback onClearFilters;
  final VoidCallback onApply;
  final Map<String, Color> filterColors; // Para saber a cor de cada filtro

  const MapFilterSheet({
    super.key,
    required this.scrollController,
    required this.availableFilters,
    required this.selectedFilters,
    required this.onToggleFilter,
    required this.onClearFilters,
    required this.onApply,
    required this.filterColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(blurRadius: 6, color: Colors.black26, offset: Offset(0, -3))
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle (Puxador cinza)
            Center(
              child: Container(
                width: 40, height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),

            // 1. Barra de Busca Refatorada
            const MapSearchBar(),

            const SizedBox(height: 24),

            // Título
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Filtros", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                if (selectedFilters.isNotEmpty)
                  TextButton(
                    onPressed: onClearFilters,
                    child: const Text("Limpar", style: TextStyle(color: AppColors.secondary)),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),

            // Texto de ajuda (pode ser outro widget se quiser, mas aqui está ok)
            const Text(
              "Selecione as categorias abaixo para encontrar o ponto ideal.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            // 2. Lista de Cards Selecionáveis (Grid)
            // Aqui substituímos aquele monte de .map() no código principal
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Scroll é gerenciado pelo Sheet
              itemCount: availableFilters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final filterName = availableFilters[index];
                final isSelected = selectedFilters.contains(filterName);
                final color = filterColors[filterName] ?? AppColors.secondary;

                // Usando um ListTile simples caso não tenha o SelectableFilterCard
                // Se tiver o widget original, use: return SelectableFilterCard(...)
                return InkWell(
                  onTap: () => onToggleFilter(filterName),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.1) : Colors.white,
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade300,
                        width: 2
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? color : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          filterName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Botão Aplicar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Aplicar Filtros",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}