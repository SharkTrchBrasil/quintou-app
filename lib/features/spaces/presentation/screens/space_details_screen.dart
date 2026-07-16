import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';

import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/features/spaces/presentation/widgets/space_grid_card.dart';
import 'package:quintou_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:quintou_app/features/bookings/presentation/screens/booking_setup_screen.dart';
import 'package:quintou_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:quintou_app/features/chat/presentation/providers/chat_provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:quintou_app/core/providers/providers.dart';

const Color themeColor = Color(0xFF00AEEF); // Quintou blue instead of Swappy purple

class SpaceDetailsScreen extends ConsumerStatefulWidget {
  final Space space;

  const SpaceDetailsScreen({
    super.key,
    required this.space,
  });

  @override
  ConsumerState<SpaceDetailsScreen> createState() => _SpaceDetailsScreenState();
}

class _SpaceDetailsScreenState extends ConsumerState<SpaceDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;
  bool _isAmenitiesExpanded = false;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(hostRepositoryProvider).incrementSpaceViews(widget.space.id);
    });
  }

  String _formatPrice(double price) {
    if (price == price.truncateToDouble()) {
      final str = price.toInt().toString();
      String result = '';
      for (int i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) {
          result += '.';
        }
        result += str[i];
      }
      return 'R\$ $result';
    } else {
      final str = price.toStringAsFixed(2).replaceAll('.', ',');
      final parts = str.split(',');
      String result = '';
      for (int i = 0; i < parts[0].length; i++) {
        if (i > 0 && (parts[0].length - i) % 3 == 0) {
          result += '.';
        }
        result += parts[0][i];
      }
      return 'R\$ $result,${parts[1]}';
    }
  }

  String _getLocation(Space space) {
    final parts = <String>[];
    if (space.neighborhood.isNotEmpty) parts.add(space.neighborhood);
    if (space.city.isNotEmpty) parts.add(space.city);
    if (space.state.isNotEmpty) parts.add(space.state);
    if (space.zipCode.isNotEmpty) {
      String zip = space.zipCode;
      if (zip.length == 8) {
        zip = '${zip.substring(0, 5)}-${zip.substring(5)}';
      }
      parts.add(zip);
    }
    return parts.isEmpty ? 'Endereço indisponível' : parts.join(', ');
  }

  Widget _buildBenefitRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black87, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageGallery(BuildContext context, List<SpaceImage> images, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.8,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  initialPage: initialIndex,
                ),
                items: images.map((image) {
                  return Builder(
                    builder: (BuildContext context) {
                      return InteractiveViewer(
                        child: CachedNetworkImage(
                          imageUrl: image.url,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: themeColor),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.black87),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(Space space) {
    final details = <Map<String, dynamic>>[];
    
    if (space.category.isNotEmpty) {
      details.add({
        'icon': Icons.grid_view_outlined,
        'label': 'Categoria',
        'value': space.category,
      });
    }
    
    if (space.spaceType.isNotEmpty) {
      details.add({
        'icon': Icons.pool_outlined,
        'label': 'Tipo',
        'value': space.spaceType,
      });
    }
    
    if (space.sizeLength > 0 && space.sizeWidth > 0) {
      details.add({
        'icon': Icons.aspect_ratio_outlined,
        'label': 'Tamanho',
        'value': '${space.sizeLength}m x ${space.sizeWidth}m',
      });
    }
    
    details.add({
      'icon': Icons.people_outline,
      'label': 'Capacidade',
      'value': 'Até ${space.maxGuests} pessoas',
    });
    
    if (space.hasRestroom) {
      details.add({
        'icon': Icons.wc,
        'label': 'Banheiro',
        'value': 'Disponível',
      });
    }
    
    if (space.hasParking) {
      details.add({
        'icon': Icons.directions_car,
        'label': 'Estacionamento',
        'value': space.parkingCapacity != null && space.parkingCapacity! > 0 ? '${space.parkingCapacity} vagas' : 'Disponível',
      });
    }
    
    details.add({
      'icon': space.isOutdoor ? Icons.park_outlined : Icons.home_outlined,
      'label': 'Ambiente',
      'value': space.isOutdoor ? 'Ao ar livre' : 'Interno',
    });

    if (space.isAdaFriendly) {
      details.add({
        'icon': Icons.accessible_forward,
        'label': 'Acessibilidade',
        'value': 'Acessível',
      });
    }

    if (space.hasHeatedPool) {
      details.add({
        'icon': Icons.hot_tub,
        'label': 'Piscina',
        'value': 'Aquecida',
      });
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalhes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final double itemWidth = (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: details.map((item) {
                return SizedBox(
                  width: itemWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item['icon'] as IconData, color: Colors.grey[700], size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['value'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.space;
    final favState = ref.watch(favoritesProvider);
    final authState = ref.watch(authProvider);
    final isFavorited = favState.isFavorited(ad.id);
    final currentUser = ref.watch(authProvider).user;
    final isOwner = currentUser?.id == ad.hostId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          if (!isOwner)
            Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border, 
                  color: isFavorited ? Colors.red : Colors.black87
                ),
                onPressed: () {
                  if (authState.user == null) {
                    BotToast.showText(text: 'Faça login para favoritar');
                    context.push('/login');
                    return;
                  }
                  ref.read(favoritesProvider.notifier).toggleFavorite(ad.id, space: ad);
                },
              ),
            ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.black87),
              onPressed: () {},
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ad.images.isEmpty)
              Container(
                height: 350,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
              )
            else
              GestureDetector(
                onTap: () {
                  _showImageGallery(context, ad.images, _currentImageIndex);
                },
                child: Stack(
                  children: [
                    CarouselSlider(
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        height: 350,
                        viewportFraction: 1.0,
                        enlargeCenterPage: false,
                        enableInfiniteScroll: ad.images.length > 1,
                        onPageChanged: (index, reason) {
                          setState(() => _currentImageIndex = index);
                        },
                      ),
                      items: ad.images.map((image) {
                        return CachedNetworkImage(
                          imageUrl: image.url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator(color: themeColor)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          ),
                        );
                      }).toList(),
                    ),
                    if (ad.images.length > 1)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/${ad.images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        ad.averageRating > 0 ? ad.averageRating.toStringAsFixed(1) : 'Novo',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      if (ad.totalReviews > 0) ...[
                        Text(
                          ' (${ad.totalReviews} avaliações)',
                          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                        ),
                      ],
                      if (ad.isFeatured) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Destaque', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ad.hostAvatar.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: ad.hostAvatar,
                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                radius: 18,
                                backgroundImage: imageProvider,
                              ),
                              placeholder: (context, url) => CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey[200],
                              ),
                              errorWidget: (context, url, error) => CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey[200],
                                child: Icon(Icons.person, color: Colors.grey[500], size: 22),
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              radius: 18,
                              child: Icon(Icons.person, color: Colors.grey[500], size: 22),
                            ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  ad.hostName.isNotEmpty ? ad.hostName : 'Anfitrião',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (ad.isVerifiedHost) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, color: Colors.blue, size: 14),
                                ],
                              ],
                            ),
                            Text(
                              '${ad.hostTotalReviews} avaliações',
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (ad.instantBook)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flash_on, size: 14, color: Colors.blue),
                              SizedBox(width: 4),
                              Text('Reserva Instantânea', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue)),
                            ],
                          ),
                        ),
                      if (ad.cancellationPolicy != 'STRICT')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.event_available, size: 14, color: Color(0xFF2E7D32)),
                              SizedBox(width: 4),
                              Text('Cancelamento Flexível', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: Color(0xFF6A1B9A)),
                            SizedBox(width: 4),
                            Text('Reserva Garantida', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6A1B9A))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    _formatPrice(ad.price),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: -1.0,
                    ),
                  ),
                  Text(
                    ad.pricingType == 'PER_HOUR' ? 'por hora' : 'por dia',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text('Destaques da Reserva', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),

                  _buildFeatureRow(
                    Icons.people_outline,
                    'Até ${ad.maxGuests} convidados',
                    'Todas as idades. ${ad.allowsPets ? "Permite pets" : "Não permite pets"}.',
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureRow(
                    Icons.sensor_door_outlined,
                    'Check-in',
                    'Seu anfitrião ${ad.hostName.isNotEmpty ? ad.hostName : "Dani"} vai te receber',
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureRow(
                    Icons.calendar_today_outlined,
                    ad.cancellationPolicy == 'FLEXIBLE' ? 'Cancelamento grátis' : 'Política de cancelamento',
                    ad.cancellationPolicy == 'FLEXIBLE' 
                        ? 'Receba reembolso total se cancelar até 24 horas antes.'
                        : 'Revise a política de cancelamento para detalhes.',
                  ),
                  if (ad.hasRestroom) ...[
                    const SizedBox(height: 24),
                    _buildFeatureRow(
                      Icons.wc_outlined,
                      'Banheiro disponível',
                      ad.restroomDescription ?? 'Banheiro na residência no local',
                    ),
                  ],
                  if (ad.hasParking) ...[
                    const SizedBox(height: 24),
                    _buildFeatureRow(
                      Icons.directions_car_outlined,
                      'Estacionamento',
                      ad.parkingDescription ?? 'Estacionamento no local disponível.',
                    ),
                  ],
                  const SizedBox(height: 40),
                  _buildDetailsGrid(ad),
                  
                  const SizedBox(height: 40),

                  if (ad.description.isEmpty || ad.description.length <= 250)
                    Text(
                      ad.description.isEmpty ? 'Sem descrição.' : ad.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: _isDescriptionExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          firstChild: ShaderMask(
                            shaderCallback: (rect) => const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                              stops: [0.5, 1.0],
                            ).createShader(rect),
                            blendMode: BlendMode.dstIn,
                            child: Text(
                              ad.description,
                              maxLines: 5,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                            ),
                          ),
                          secondChild: Text(
                            ad.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                        ),
                        if (!_isDescriptionExpanded)
                          Center(
                            child: GestureDetector(
                              onTap: () => setState(() => _isDescriptionExpanded = true),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Ver descrição completa',
                                  style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 40),

                  if (ad.amenities.isNotEmpty) ...[
                    Builder(
                      builder: (context) {
                        final displayAmenities = _isAmenitiesExpanded
                            ? ad.amenities
                            : ad.amenities.take(6).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final double itemWidth = (constraints.maxWidth - 16) / 2;
                                return Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: displayAmenities.map((amenity) {
                                    return SizedBox(
                                      width: itemWidth,
                                      child: Row(
                                        children: [
                                          Icon(Icons.star_border, size: 20, color: Colors.grey[800]),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              amenity,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey[800],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            if (ad.amenities.length > 6) ...[
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _isAmenitiesExpanded = !_isAmenitiesExpanded;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: Text(
                                  _isAmenitiesExpanded ? 'Ver menos' : 'Ver todas as ${ad.amenities.length} comodidades',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],

                  if (ad.tags.isNotEmpty) ...[
                    const SizedBox(height: 40),
                    const Text(
                      'O que o torna especial',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ad.tags.length,
                        itemBuilder: (context, index) {
                          final tag = ad.tags[index];
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star_border, color: Colors.black87, size: 28),
                                const Spacer(),
                                Text(
                                  tag,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                  const Text(
                    'Localização',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_city, color: themeColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${ad.city}, ${ad.state}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Localização exata fornecida após a reserva.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    'Sobre o proprietário',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [themeColor, Colors.blue],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: ad.hostAvatar.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: ad.hostAvatar,
                                          imageBuilder: (context, imageProvider) => CircleAvatar(
                                            radius: 32,
                                            backgroundImage: imageProvider,
                                          ),
                                          placeholder: (context, url) => CircleAvatar(
                                            radius: 32,
                                            backgroundColor: Colors.grey[200],
                                          ),
                                          errorWidget: (context, url, error) => CircleAvatar(
                                            radius: 32,
                                            backgroundColor: Colors.grey[200],
                                            child: Icon(Icons.person, color: Colors.grey[400], size: 40),
                                          ),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.grey[200],
                                          radius: 32,
                                          child: Icon(Icons.person, color: Colors.grey[400], size: 40),
                                        ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (ad.isVerifiedHost)
                                    Row(
                                      children: [
                                        Text(
                                          'CONTA VERIFICADA',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified, color: Colors.blue, size: 14),
                                      ],
                                    ),
                                  if (ad.isVerifiedHost) const SizedBox(height: 2),
                                  Text(
                                    ad.hostName.isNotEmpty ? ad.hostName : 'Proprietário',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Último acesso recentemente',
                                    style: TextStyle(
                                      color: Colors.grey[600], 
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black54),
                            const SizedBox(width: 12),
                            Text(
                              'No Quintou desde 2022',
                              style: TextStyle(color: Colors.grey[800], fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
                            const SizedBox(width: 12),
                            Text(
                              '${ad.city}, ${ad.state}',
                              style: TextStyle(color: Colors.grey[800], fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Informações verificadas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.check, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text('Identidade', style: TextStyle(color: Colors.grey[800], fontSize: 15)),
                            const SizedBox(width: 24),
                            const Icon(Icons.check, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text('Telefone', style: TextStyle(color: Colors.grey[800], fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.check, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text('E-mail', style: TextStyle(color: Colors.grey[800], fontSize: 15)),
                          ],
                        ),
                        if (!isOwner) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                print('DEBUG: Botão de chat clicado');
                                if (currentUser == null) {
                                  print('DEBUG: currentUser is null, abrindo /login');
                                  context.push('/login');
                                  return;
                                }
                                
                                try {
                                  print('DEBUG: Iniciando startConversationBySpace com spaceId: ${ad.id}');
                                  final repo = ref.read(featureChatRepositoryProvider);
                                  final conv = await repo.startConversationBySpace(ad.id);
                                  
                                  print('DEBUG: startConversationBySpace retornou sucesso: ${conv.id}');
                                  if (context.mounted) {
                                    print('DEBUG: context.mounted true, push /chat/${conv.id}');
                                    context.push('/chat/${conv.id}', extra: conv);
                                  }
                                } catch (e, stackTrace) {
                                  print('DEBUG: Erro em startConversationBySpace: $e');
                                  print('DEBUG: StackTrace: $stackTrace');
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erro ao iniciar chat: $e')),
                                    );
                                  }
                                }
                              },
                                child: const Text(
                                  'Falar com o proprietário',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  
                  const Text(
                    'Condições de Reserva',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildFeatureRow(
                    Icons.access_time,
                    'Duração da reserva',
                    'Mínimo de ${ad.minHours} ${ad.minHours == 1 ? "hora" : "horas"}. Máximo de ${ad.maxHours} ${ad.maxHours == 1 ? "hora" : "horas"}.',
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureRow(
                    ad.requiresApproval ? Icons.hourglass_empty : Icons.flash_on,
                    ad.requiresApproval ? 'Requer aprovação' : 'Reserva instantânea',
                    ad.requiresApproval 
                        ? 'O anfitrião tem até 24h para aprovar seu pedido.'
                        : 'Você confirma a reserva imediatamente, sem esperar aprovação.',
                  ),
                  if (ad.securityDeposit > 0) ...[
                    const SizedBox(height: 20),
                    _buildFeatureRow(
                      Icons.security,
                      'Depósito de segurança',
                      'Uma retenção de ${_formatPrice(ad.securityDeposit)} será feita no seu cartão e devolvida após o evento se não houver danos.',
                    ),
                  ],

                  const SizedBox(height: 40),

                  const Text(
                    'Regras do Espaço',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Privacidade',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ad.privacyLevel.isNotEmpty ? ad.privacyLevel : 'Privado',
                    style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ad.privacyDescription ?? 'O espaço é de uso exclusivo seu durante a reserva.',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Permissões',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final rules = [
                        {'name': 'Álcool', 'allowed': ad.allowsAlcohol},
                        {'name': 'Fumar', 'allowed': ad.allowsSmoking},
                        {'name': 'Festas', 'allowed': ad.allowsParties},
                        {'name': 'Música alta', 'allowed': ad.allowsLoudMusic},
                        {'name': 'Pets', 'allowed': ad.allowsPets},
                        {'name': 'Crianças', 'allowed': (ad.allowsChildren || ad.allowsInfants)},
                        {'name': 'Uso comercial', 'allowed': ad.allowsCommercial},
                      ];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rules.map((rule) {
                          final allowed = rule['allowed'] as bool;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  rule['name'] as String,
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                                ),
                                Text(
                                  allowed ? 'Sim' : 'Não',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  if (ad.allowsPets && ad.petRules != null && ad.petRules!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.pets, size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Regras para pets', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(ad.petRules!, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (ad.rules != null && ad.rules!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Regras adicionais',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ad.rules!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Text(
                    'Segurança',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pode haver câmeras de segurança e dispositivos de gravação na propriedade.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: isOwner ? const SizedBox.shrink() : Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatPrice(ad.price),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'por ${ad.pricingType == 'PER_HOUR' ? 'hora' : 'dia'}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (currentUser == null) {
                    context.push('/login');
                  } else {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: BookingSetupScreen(space: ad),
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Agendar', style: TextStyle(fontSize: 18, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
