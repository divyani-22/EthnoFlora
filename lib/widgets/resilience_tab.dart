import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/disaster_event.dart';
import '../services/news_service.dart';
import '../widgets/disaster_event_card.dart';

class ResilienceTab extends StatefulWidget {
  @override
  _ResilienceTabState createState() => _ResilienceTabState();
}

class _ResilienceTabState extends State<ResilienceTab> {
  List<DisasterEvent> _disasterEvents = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDisasterEvents();
  }

  Future<void> _loadDisasterEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Loading real-time climate news...');
      final events = await NewsService.fetchClimateNews()
          .timeout(Duration(seconds: 10), onTimeout: () {
        print('⏰ News loading timeout, using fallback data');
        return _getFallbackDisasterEvents();
      });

      if (mounted) {
        setState(() {
          _disasterEvents = events;
          _isLoading = false;
        });
        print('✅ Loaded ${events.length} climate events');
      }
    } catch (e) {
      print('❌ Error loading disaster events: $e');
      if (mounted) {
        setState(() {
          _disasterEvents = _getFallbackDisasterEvents();
          _isLoading = false;
        });
      }
    }
  }

    List<DisasterEvent> _getFallbackDisasterEvents() {
    return [
      DisasterEvent(
        id: 'in_1',
        title: 'IMD Alert: Western Disturbance Heavy Precipitation Warning',
        description: 'India Meteorological Department issues orange alert for intense rainfall, flash floods, and cloudburst vulnerability across Western Himalayan catchments.',
        location: 'Himachal Pradesh & Uttarakhand, India',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'FLOOD',
        casualties: 'Settlements Alerted',
        damage: 'Hill road transit disrupted',
        imageUrl: 'https://images.unsplash.com/photo-1547683905-f686c993aae5?auto=format&fit=crop&w=800&q=80',
        sourceUrl: 'https://mausam.imd.gov.in/',
      ),
      DisasterEvent(
        id: 'in_2',
        title: 'CPCB Air Quality Bulletin: Severe Winter Smog & Particulate Spike',
        description: 'Central Pollution Control Board records AQI exceeding 380 across Indo-Gangetic plains; Stage-IV GRAP mitigation protocols activated.',
        location: 'Delhi-NCR & Northern Plains, India',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        type: 'AIR QUALITY',
        casualties: 'Severe Advisory',
        damage: 'Construction activities restricted',
        imageUrl: 'https://images.unsplash.com/photo-1576487246293-1383329b35b6?auto=format&fit=crop&w=800&q=80',
        sourceUrl: 'https://cpcb.nic.in/',
      ),
      DisasterEvent(
        id: 'in_3',
        title: 'NDMA Advisory: Western Ghats Slopes & Landslide Vulnerability',
        description: 'National Disaster Management Authority releases geotechnical slope stability report and early warning evacuation protocols for fragile ghat valleys.',
        location: 'Wayanad & Idukki, Kerala, India',
        date: DateTime.now().subtract(const Duration(hours: 9)),
        type: 'LANDSLIDE',
        casualties: 'Guidelines Issued',
        damage: 'Topsoil saturation monitoring',
        imageUrl: 'https://images.unsplash.com/photo-1545645591-6671c6670876?auto=format&fit=crop&w=800&q=80',
        sourceUrl: 'https://ndma.gov.in/Natural-Hazards/Landslide',
      ),
      DisasterEvent(
        id: 'in_4',
        title: 'Bay of Bengal Cyclonic Storm Watch & Coastal Preparedness',
        description: 'Deep depression in Bay of Bengal tracked heading toward eastern seaboard. Fishermen advised against venture; coastal district NDRF units deployed.',
        location: 'Odisha & Andhra Pradesh Coastline, India',
        date: DateTime.now().subtract(const Duration(hours: 14)),
        type: 'TYPHOON',
        casualties: '12 Shelters Active',
        damage: 'Embankments reinforced',
        imageUrl: 'https://images.unsplash.com/photo-1527482797697-8795b05a13fe?auto=format&fit=crop&w=800&q=80',
        sourceUrl: 'https://ndma.gov.in/Natural-Hazards/Cyclone',
      ),
      DisasterEvent(
        id: 'in_5',
        title: 'Down To Earth Special Report: High-Altitude GLOF Risk Mapping',
        description: 'Comprehensive satellite analysis reveals rapid expansion of glacial moraine dams in Eastern Himalayas, prompting automated early warning sensor installations.',
        location: 'Sikkim & Ladakh, India',
        date: DateTime.now().subtract(const Duration(hours: 20)),
        type: 'CLIMATE EVENT',
        casualties: 'River Gauges Alerted',
        damage: 'Diversion tunnels checked',
        imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80',
        sourceUrl: 'https://www.downtoearth.org.in/',
      ),
    ];
  }

  List<DisasterEvent> get _filteredEvents {
    if (_searchQuery.isEmpty) {
      return _disasterEvents;
    }
    return _disasterEvents.where((event) {
      return event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             event.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             event.type.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Map<String, List<DisasterEvent>> get _groupedEvents {
    final grouped = <String, List<DisasterEvent>>{};

    for (final event in _filteredEvents) {
      final date = event.date;
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));

      String groupKey;
      if (date.year == today.year && date.month == today.month && date.day == today.day) {
        groupKey = 'Today';
      } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
        groupKey = 'Yesterday';
      } else {
        groupKey = DateFormat('EEEE, MMMM d').format(date);
      }

      grouped.putIfAbsent(groupKey, () => []).add(event);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildSearchBar(),

          Expanded(
            child: _isLoading
                ? _buildLoadingIndicator()
                : _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search disasters...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
          Icon(Icons.filter_list, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          SizedBox(height: 16),
          Text(
            'Fetching real-time climate news...',
            style: GoogleFonts.questrial(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: GoogleFonts.questrial(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No disaster events found' : 'No events match your search',
              style: GoogleFonts.questrial(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: Text('Clear search'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDisasterEvents,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 0),
        itemCount: _groupedEvents.length,
        itemBuilder: (context, index) {
          final groupKey = _groupedEvents.keys.elementAt(index);
          final events = _groupedEvents[groupKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Text(
                  groupKey,
                  style: GoogleFonts.questrial(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              ...events.map((event) => _buildEventCard(event)).toList(),
              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

    Widget _buildEventCard(DisasterEvent event) {
    Color tagBg = AppColors.butterYellow;
    IconData iconData = Icons.warning_amber_rounded;
    switch (event.type.toUpperCase()) {
      case 'LANDSLIDE':
        tagBg = AppColors.dustyCoral;
        iconData = Icons.terrain_rounded;
        break;
      case 'FLOOD':
      case 'FLOOD: HEAVY RAIN':
        tagBg = AppColors.softSky;
        iconData = Icons.water_drop_rounded;
        break;
      case 'TYPHOON':
        tagBg = AppColors.softSky;
        iconData = Icons.cyclone_rounded;
        break;
      case 'AIR QUALITY':
        tagBg = AppColors.dustyCoral;
        iconData = Icons.air_rounded;
        break;
      default:
        tagBg = AppColors.mintGreen;
        iconData = Icons.warning_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.solidBlack, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.solidBlack,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.solidBlack, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconData, size: 13, color: AppColors.solidBlack),
                    const SizedBox(width: 4),
                    Text(
                      event.type.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.solidBlack,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Updated: ${DateFormat('h:mm a').format(event.date)}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.solidBlack.withValues(alpha: 0.6),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.solidBlack,
              height: 1.3,
            ),
          ),
          if (event.casualties.isNotEmpty || event.damage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.solidBlack),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      [
                        if (event.casualties.isNotEmpty) event.casualties,
                        if (event.damage.isNotEmpty) event.damage,
                      ].join(' • '),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.solidBlack.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (event.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                event.description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: AppColors.solidBlack.withValues(alpha: 0.75),
                  height: 1.4,
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.solidBlack, thickness: 1.5, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.solidBlack),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.solidBlack.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => NewsService.launchSourceUrl(event.sourceUrl),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.butterYellow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.solidBlack, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.solidBlack,
                        offset: Offset(1.5, 1.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Live Bulletin',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.solidBlack,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 13,
                        color: AppColors.solidBlack,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEventDetails(DisasterEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getEventTypeColor(event.type),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.type,
                        style: GoogleFonts.questrial(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      event.title,
                      style: GoogleFonts.questrial(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),

                    SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                        SizedBox(width: 4),
                        Text(
                          event.location,
                          style: GoogleFonts.questrial(
                            color: Colors.grey[600],
                          ),
                        ),
                        Spacer(),
                        Text(
                          DateFormat('MMM d, y').format(event.date),
                          style: GoogleFonts.questrial(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    if (event.casualties.isNotEmpty) ...[
                      _buildInfoRow('Casualties', event.casualties),
                      SizedBox(height: 8),
                    ],
                    if (event.damage.isNotEmpty) ...[
                      _buildInfoRow('Damage', event.damage),
                      SizedBox(height: 16),
                    ],

                    Text(
                      'Description',
                      style: GoogleFonts.questrial(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      event.description,
                      style: GoogleFonts.questrial(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                            },
                            icon: Icon(Icons.share),
                            label: Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              try {
                                await NewsService.launchSourceUrl(event.sourceUrl);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Unable to open link: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.open_in_new),
                            label: Text('Read More'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF4CAF50),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.questrial(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.questrial(
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Color _getEventTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'LANDSLIDE':
        return Colors.red;
      case 'FLOOD':
      case 'FLOOD: HEAVY RAIN':
        return Colors.blue;
      case 'TYPHOON':
        return Colors.purple;
      case 'EARTHQUAKE':
        return Colors.orange;
      case 'WILDFIRE':
        return Colors.deepOrange;
      default:
        return Color(0xFF4CAF50);
    }
  }
}