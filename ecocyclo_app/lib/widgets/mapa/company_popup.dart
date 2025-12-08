import 'package:flutter/material.dart';
import '../../models/disposal_point.dart';
class CompanyPopupCard extends StatelessWidget {
  final DisposalPoint enterprise;
  final VoidCallback onClose;
  final VoidCallback onDetails;
  final Color categoryColor;
  final IconData categoryIcon;

  const CompanyPopupCard({
    super.key,
    required this.enterprise,
    required this.onClose,
    required this.onDetails,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(enterprise.name, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(onTap: onClose, child: const Icon(Icons.close, size: 20)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(categoryIcon, color: categoryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(enterprise.company_description, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            if (enterprise.distance != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("${enterprise.distance!.toStringAsFixed(1)} km de distância",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            TextButton(
              onPressed: onDetails,
              child: const Text('Ver detalhes'),
            )
          ],
        ),
      ),
    );
  }
}