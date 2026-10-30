import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/case.dart';

class PopulateCases {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> populateWithSampleCases() async {
    try {
      print('🔥 PopulateCases: Starting to populate Firebase with sample cases...');

      final hasCases = await _checkIfCasesExist();
      if (hasCases) {
        print('ℹ️ PopulateCases: Cases already exist in Firebase');
        return;
      }

      final cases = _getSampleCases();

      for (final caseData in cases) {
        await _firestore.collection('cases').add(caseData);
      }

      print('✅ PopulateCases: Successfully added ${cases.length} sample cases to Firebase');
    } catch (e) {
      print('❌ PopulateCases: Error populating cases: $e');
      rethrow;
    }
  }

  static Future<bool> _checkIfCasesExist() async {
    try {
      final snapshot = await _firestore.collection('cases').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ PopulateCases: Error checking cases: $e');
      return false;
    }
  }

    static List<Map<String, dynamic>> _getSampleCases() {
    return [
      {
        'personName': 'Dr. Roxy Mathew Koll',
        'story': 'Indian Ocean warming, marine heatwaves, and changing monsoon rainfall extremes',
        'climateEvent': 'Ocean Warming & Cyclone Dynamics',
        'location': 'Pune, Maharashtra, India',
        'impact': 'IPCC Lead Author',
        'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'sourceUrl': 'https://rocksea.org/',
        'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&q=80',
        'severity': 'high',
        'source': 'IITM Pune',
        'isReviewed': true,
        'description': 'Climate scientist at the Indian Institute of Tropical Meteorology (IITM) Pune, leading pioneering studies on Indian Ocean surface temperature rise and supercharged cyclone forecasting.',
      },
      {
        'personName': 'Dr. Sunita Narain',
        'story': 'Pioneering clean air monitoring, water harvesting, and climate justice advocacy',
        'climateEvent': 'Air Quality & Water Governance',
        'location': 'New Delhi, India',
        'impact': 'Padma Shri Awardee',
        'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        'sourceUrl': 'https://www.cseindia.org/page/sunita-narain',
        'imageUrl': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=600&q=80',
        'severity': 'high',
        'source': 'Centre for Science and Environment',
        'isReviewed': true,
        'description': 'Director General of CSE and editor of Down To Earth magazine, championing grassroots decentralised rainwater harvesting and public transit emission policy.',
      },
      {
        'personName': 'Prof. Navroz K. Dubash',
        'story': 'India decarbonisation pathways, power sector reforms, and climate policy architecture',
        'climateEvent': 'Climate Policy & Energy Transition',
        'location': 'New Delhi, India',
        'impact': 'IPCC Coordinating Lead Author',
        'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
        'sourceUrl': 'https://sustainablefutures.org/',
        'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
        'severity': 'medium',
        'source': 'Sustainable Futures Collaborative',
        'isReviewed': true,
        'description': 'Senior Fellow at Sustainable Futures Collaborative and former CPR Professor, focusing on institutional frameworks for climate governance and green energy transitions.',
      },
      {
        'personName': 'Dr. Chirag Dhara',
        'story': 'Compound extreme weather analysis, wet-bulb heat thresholds, and regional climate modeling',
        'climateEvent': 'Heatwaves & Atmospheric Thermodynamics',
        'location': 'Sri City, Andhra Pradesh, India',
        'impact': 'MoES Assessment Author',
        'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 4))),
        'sourceUrl': 'https://krea.edu.in/faculty/chirag-dhara/',
        'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
        'severity': 'high',
        'source': 'Krea University',
        'isReviewed': true,
        'description': 'Climate physicist at Krea University and key author of India\'s first national climate assessment published by the Ministry of Earth Sciences (MoES).',
      },
      {
        'personName': 'Dr. Jagdish Krishnaswamy',
        'story': 'Western Ghats watershed ecohydrology, river basin dynamics, and tropical forest resilience',
        'climateEvent': 'Ecohydrology & Forest Catchments',
        'location': 'Bengaluru, Karnataka, India',
        'impact': 'IPCC Lead Author',
        'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
        'sourceUrl': 'https://iihs.co.in/',
        'imageUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=600&q=80',
        'severity': 'medium',
        'source': 'IIHS Bangalore',
        'isReviewed': true,
        'description': 'Dean of the School of Environment and Sustainability at IIHS Bangalore, analyzing hydrological changes in Western Ghats catchments and tropical riparian zones.',
      },
      {
        'personName': 'Dr. Priyadarsanan Dharma Rajan',
        'story': 'Ecosystem services, pollinator decline, and biodiversity conservation in fragile agricultural belts',
        'climateEvent': 'Biodiversity & Agro-Ecosystems',
        'location': 'Bengaluru, Karnataka, India',
        'impact': 'ATREE Senior Fellow',
        'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 6))),
        'sourceUrl': 'https://www.atree.org/',
        'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=600&q=80',
        'severity': 'medium',
        'source': 'ATREE India',
        'isReviewed': true,
        'description': 'Senior Fellow at ATREE, investigating pollinator declines, insect conservation, and canopy arthropods under changing regional microclimates.',
      },
    ];
  }

  static Future<void> clearAllCases() async {
    try {
      print('🗑️ PopulateCases: Clearing all cases...');
      final snapshot = await _firestore.collection('cases').get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('✅ PopulateCases: All cases cleared successfully');
    } catch (e) {
      print('❌ PopulateCases: Error clearing cases: $e');
      rethrow;
    }
  }

  static Future<int> getCaseCount() async {
    try {
      final snapshot = await _firestore.collection('cases').get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ PopulateCases: Error getting case count: $e');
      return 0;
    }
  }
}