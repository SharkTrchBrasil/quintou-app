import 'package:flutter/material.dart';
import 'package:quintou_app/core/models/booking_model.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  final bool isHostMode;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.isHostMode = false,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmada';
      case 'pending':
        return 'Pendente';
      case 'cancelled':
        return 'Cancelada';
      case 'completed':
        return 'Concluída';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final space = booking.space;
    final primaryImage = space?.images.isNotEmpty == true
        ? (space!.images.firstWhere((img) => img.isPrimary, orElse: () => space.images.first).url)
        : null;

    final start = DateFormat('dd/MM').format(booking.startTime);
    final end = DateFormat('dd/MM').format(booking.endTime);
    final year = DateFormat('yyyy').format(booking.startTime);
    
    final statusColor = _getStatusColor(booking.status);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem quadrada À esquerda
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 90,
                height: 90,
                color: Colors.grey[200],
                child: primaryImage != null
                    ? CachedNetworkImage(
                        imageUrl: primaryImage,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 14),
            // Informações À direita
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusText(booking.status).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      Text(
                        'R\$ ${booking.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Título do Espaço
                  Text(
                    space?.title ?? 'Espaço não encontrado',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Datas e Hóspedes
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$start - $end, $year',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${booking.numGuests}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
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
