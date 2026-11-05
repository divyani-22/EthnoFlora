import 'package:flutter/foundation.dart';
import '../models/swap_item.dart';

class BioRepositoryService extends ChangeNotifier {
  static final BioRepositoryService _instance = BioRepositoryService._internal();
  factory BioRepositoryService() => _instance;

  BioRepositoryService._internal() {
    _seedItems();
  }

  final List<SwapItem> _items = [];
  final List<String> _requestedItemIds = [];

  List<SwapItem> get items => List.unmodifiable(_items);

  List<SwapItem> get availableItems =>
      _items.where((item) => item.isAvailable).toList();

  List<SwapItem> get myListings =>
      _items.where((item) => item.donorId == 'current_user').toList();

  List<SwapItem> get myRequests =>
      _items.where((item) => _requestedItemIds.contains(item.id)).toList();

  double get totalWasteDivertedKg =>
      _items.where((i) => i.status == 'completed').fold(
            18.6, // Seed baseline in kg
            (sum, item) => sum + item.wasteDivertedKg,
          );

  double get totalCo2SavedKg =>
      _items.where((i) => i.status == 'completed').fold(
            41.2, // Seed baseline in kg CO2
            (sum, item) => sum + item.co2SavedKg,
          );

  void addItem({
    required String title,
    required String description,
    required SwapCategory category,
    required ItemCondition condition,
    required SwapType swapType,
    required String campusName,
    String? swapPreference,
    String? customImageUrl,
  }) {
    final waste = SwapItem.estimateWaste(category);
    final co2 = SwapItem.estimateCo2(category);

    final newItem = SwapItem(
      id: 'swap_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      category: category,
      condition: condition,
      swapType: swapType,
      campusName: campusName,
      swapPreference: swapPreference,
      wasteDivertedKg: waste,
      co2SavedKg: co2,
      donorName: 'You (EthnoFlora Student)',
      donorId: 'current_user',
      donorKarmaScore: 240,
      imageUrl: customImageUrl ?? _getDefaultImage(category),
      createdAt: DateTime.now(),
      isAvailable: true,
      status: 'available',
    );

    _items.insert(0, newItem);
    notifyListeners();
  }

  void requestItem(String itemId, String message) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index].status = 'requested';
      if (!_requestedItemIds.contains(itemId)) {
        _requestedItemIds.add(itemId);
      }
      notifyListeners();
    }
  }

  void markCompleted(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index].status = 'completed';
      _items[index].isAvailable = false;
      notifyListeners();
    }
  }

  List<SwapItem> filterItems({
    SwapCategory? category,
    String? campus,
    SwapType? swapType,
    String? searchQuery,
  }) {
    return _items.where((item) {
      if (category != null && item.category != category) return false;
      if (campus != null && campus.isNotEmpty && item.campusName != campus) return false;
      if (swapType != null && item.swapType != swapType) return false;
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(query);
        final matchesDesc = item.description.toLowerCase().contains(query);
        final matchesCampus = item.campusName.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc && !matchesCampus) return false;
      }
      return true;
    }).toList();
  }

  static String _getDefaultImage(SwapCategory category) {
    switch (category) {
      case SwapCategory.textbooks:
        return 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80';
      case SwapCategory.labEquipment:
        return 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=600&q=80';
      case SwapCategory.uniforms:
        return 'https://images.unsplash.com/photo-1578932750294-f5075e85f44a?auto=format&fit=crop&w=600&q=80';
      case SwapCategory.electronics:
        return 'https://images.unsplash.com/photo-1587145820266-a5951ee6f620?auto=format&fit=crop&w=600&q=80';
      case SwapCategory.notesStationery:
        return 'https://images.unsplash.com/photo-1585776245991-cf89dd7fc73a?auto=format&fit=crop&w=600&q=80';
      case SwapCategory.other:
        return 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=600&q=80';
    }
  }

  void _seedItems() {
    _items.addAll([
      SwapItem(
        id: 'seed_1',
        title: 'Higher Engineering Mathematics (B.S. Grewal 44th Ed.)',
        description:
            'Standard textbook for 1st & 2nd year engineering mathematics. Clean pages, no torn sheets, only light pencil annotations.',
        category: SwapCategory.textbooks,
        condition: ItemCondition.good,
        swapType: SwapType.itemSwap,
        campusName: 'Delhi Technological University (DTU)',
        swapPreference: 'Looking for Data Structures in C++ (Horowitz) or 100 Flora Coins',
        wasteDivertedKg: 1.6,
        co2SavedKg: 3.5,
        donorName: 'Aarav Sharma',
        donorId: 'donor_aarav',
        donorKarmaScore: 420,
        imageUrl:
            'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      SwapItem(
        id: 'seed_2',
        title: 'Casio FX-991EX ClassWiz Scientific Calculator',
        description:
            'High-resolution non-programmable scientific calculator permitted in all university exams. Battery in great health, solar panel works perfectly.',
        category: SwapCategory.electronics,
        condition: ItemCondition.likeNew,
        swapType: SwapType.freeGiveaway,
        campusName: 'IIT Bombay (Powai)',
        swapPreference: 'Free Giveaway to any junior in need!',
        wasteDivertedKg: 0.3,
        co2SavedKg: 1.8,
        donorName: 'Priya Iyer',
        donorId: 'donor_priya',
        donorKarmaScore: 590,
        imageUrl:
            'https://images.unsplash.com/photo-1587145820266-a5951ee6f620?auto=format&fit=crop&w=600&q=80',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      SwapItem(
        id: 'seed_3',
        title: 'Pure Cotton Chemistry Lab Coat (Size 38 / M)',
        description:
            'Washed and sterilized standard lab coat with deep pockets. Used for 1 semester in inorganic chemistry lab.',
        category: SwapCategory.uniforms,
        condition: ItemCondition.good,
        swapType: SwapType.freeGiveaway,
        campusName: "St. Stephen's College, Delhi",
        swapPreference: 'Free Giveaway',
        wasteDivertedKg: 0.6,
        co2SavedKg: 2.1,
        donorName: 'Rohan Deshmukh',
        donorId: 'donor_rohan',
        donorKarmaScore: 310,
        imageUrl:
            'https://images.unsplash.com/photo-1578932750294-f5075e85f44a?auto=format&fit=crop&w=600&q=80',
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      ),
      SwapItem(
        id: 'seed_4',
        title: 'Class 12 NCERT Physics & Chemistry Complete Bundle',
        description:
            'All 4 parts of NCERT Physics and Chemistry for CBSE / JEE Prep. Kept in plastic book covers, spotless.',
        category: SwapCategory.textbooks,
        condition: ItemCondition.likeNew,
        swapType: SwapType.freeGiveaway,
        campusName: 'Delhi Public School, R.K. Puram',
        swapPreference: 'Free for any 11th/12th aspirant',
        wasteDivertedKg: 2.4,
        co2SavedKg: 5.2,
        donorName: 'Ananya Verma',
        donorId: 'donor_ananya',
        donorKarmaScore: 680,
        imageUrl:
            'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=600&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SwapItem(
        id: 'seed_5',
        title: 'Borosilicate Glass Beakers & Pipette Set (Lab Grade)',
        description:
            'Three 250ml beakers, two 100ml conical flasks, and one 10ml calibrated pipette. Perfect for DIY projects or biotech practicals.',
        category: SwapCategory.labEquipment,
        condition: ItemCondition.likeNew,
        swapType: SwapType.itemSwap,
        campusName: 'BITS Pilani (Goa Campus)',
        swapPreference: 'Looking for breadboard / electronics jumper wires',
        wasteDivertedKg: 0.8,
        co2SavedKg: 1.9,
        donorName: 'Tanvi Nair',
        donorId: 'donor_tanvi',
        donorKarmaScore: 490,
        imageUrl:
            'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=600&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      ),
      SwapItem(
        id: 'seed_6',
        title: 'Handcrafted Environmental Science Mindmaps & Spiral Registers',
        description:
            'Colorful hand-drawn mindmaps covering COP28, Indian Environmental Acts, Western Ghats ecology, and climate treaties.',
        category: SwapCategory.notesStationery,
        condition: ItemCondition.likeNew,
        swapType: SwapType.freeGiveaway,
        campusName: 'St. Xavier’s College, Mumbai',
        swapPreference: 'Free share / PDF scan also available',
        wasteDivertedKg: 0.7,
        co2SavedKg: 1.5,
        donorName: 'Karan Mehra',
        donorId: 'donor_karan',
        donorKarmaScore: 350,
        imageUrl:
            'https://images.unsplash.com/photo-1585776245991-cf89dd7fc73a?auto=format&fit=crop&w=600&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      SwapItem(
        id: 'seed_7',
        title: 'Arduino Uno R3 Starter Kit with Sensors',
        description:
            'Original Uno board with soil moisture sensor, DHT11 temperature/humidity sensor, and ultrasonic distance sensor for eco-automation projects.',
        category: SwapCategory.electronics,
        condition: ItemCondition.good,
        swapType: SwapType.itemSwap,
        campusName: 'IIT Delhi (Hauz Khas)',
        swapPreference: 'Swap for Raspberry Pi Zero or give away to eco-project team',
        wasteDivertedKg: 0.5,
        co2SavedKg: 3.2,
        donorName: 'Devansh Joshi',
        donorId: 'donor_devansh',
        donorKarmaScore: 540,
        imageUrl:
            'https://images.unsplash.com/photo-1553406830-ef2513450d76?auto=format&fit=crop&w=600&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 12)),
      ),
      SwapItem(
        id: 'seed_8',
        title: 'Kendriya Vidyalaya House Uniform Track Suit (Size 36)',
        description:
            'Tagore House (Green House) sports track jacket and trousers in excellent condition. Ideal for upcoming annual sports day.',
        category: SwapCategory.uniforms,
        condition: ItemCondition.good,
        swapType: SwapType.freeGiveaway,
        campusName: 'Kendriya Vidyalaya IIT Powai',
        swapPreference: 'Free Giveaway',
        wasteDivertedKg: 0.8,
        co2SavedKg: 2.8,
        donorName: 'Meera Pillai',
        donorId: 'donor_meera',
        donorKarmaScore: 290,
        imageUrl:
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=600&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);
  }
}


