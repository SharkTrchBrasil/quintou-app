import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/models/booking_model.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final Booking booking;
  final bool isHostMode;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
    this.isHostMode = false,
  });

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return 'Confirmada';
      case 'pending': return 'Pendente';
      case 'cancelled': return 'Cancelada';
      case 'completed': return 'Concluída';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Space? space = booking.space;
    final primaryImage = space?.images.isNotEmpty == true 
        ? (space!.images.firstWhere((img) => img.isPrimary, orElse: () => space.images.first).url) 
        : null;

    final startDate = DateFormat('dd \'de\' MMMM, yyyy').format(booking.startTime);
    final endDate = DateFormat('dd \'de\' MMMM, yyyy').format(booking.endTime);
    final statusColor = _getStatusColor(booking.status);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalhes do Agendamento', style: TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do Espaço
            if (primaryImage != null)
              CachedNetworkImage(
                imageUrl: primaryImage,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  height: 220, color: Colors.grey[200], child: const Icon(Icons.broken_image),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 220,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status e Código
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusText(booking.status).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      Text(
                        'Reserva #${booking.id.substring(0, 8).toUpperCase()}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Título do Espaço
                  Text(
                    space?.title ?? 'Espaço Removido',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  if (space?.city != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${space!.city}, ${space.state}', style: TextStyle(color: Colors.grey.shade700)),
                      ],
                    ),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Divider(),
                  ),

                  // Informações da Reserva
                  const Text('Detalhes da Reserva', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  _buildDetailRow(Icons.calendar_today, 'Check-in', startDate),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.event_busy, 'Check-out', endDate),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.people_outline, 'Hóspedes', '${booking.numGuests} pessoas'),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Divider(),
                  ),

                  // Preço
                  const Text('Resumo do Pagamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total (BRL)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text(
                        'R\$ ${booking.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Divider(),
                  ),

                  // Perfil (Hóspede ou Anfitrião)
                  if (isHostMode && booking.guest != null) ...[
                    const Text('Hóspede', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildUserCard(booking.guest!.fullName, booking.guest!.avatarUrl),
                  ] else if (!isHostMode && space != null) ...[
                    const Text('Anfitrião', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildUserCard(space.hostName, space.hostAvatar.isNotEmpty ? space.hostAvatar : null),
                  ],

                  const SizedBox(height: 32),

                  // Ações
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implementar Mensagens
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A), // Roxo do Quintou
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Enviar Mensagem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  if (booking.status.toLowerCase() == 'pending' || booking.status.toLowerCase() == 'confirmed') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Implementar Cancelamento
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Cancelar Reserva', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildUserCard(String name, String? avatarUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
        ),
        const SizedBox(width: 16),
        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
