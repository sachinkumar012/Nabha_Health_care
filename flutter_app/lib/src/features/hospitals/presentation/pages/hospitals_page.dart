import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

// Hospital model
class Hospital {
  final String name;
  final String address;
  final String phone;
  final List<String> alternateNumbers;
  final String timing;
  final List<String> services;
  final String directions;
  final bool is24x7;
  final String? specialNote;

  Hospital({
    required this.name,
    required this.address,
    required this.phone,
    this.alternateNumbers = const [],
    required this.timing,
    required this.services,
    required this.directions,
    this.is24x7 = false,
    this.specialNote,
  });
}

class HospitalsPage extends StatefulWidget {
  const HospitalsPage({super.key});

  @override
  State<HospitalsPage> createState() => _HospitalsPageState();
}

class _HospitalsPageState extends State<HospitalsPage> {
  String _searchQuery = '';
  
  final List<Hospital> _hospitals = [
    Hospital(
      name: 'Sawhney Hospital & Maternity Home',
      address: 'Ripudaman Pura, Nabha, Patiala Gate, Nabha, Punjab – 147201\nNear Gurdwara Akalgarh, Sham Bagh Enclave, Opposite Mata Rani Mandir',
      phone: '+91-1765-229611',
      alternateNumbers: ['+91-98142-20652', '+91-98557-20652', '+91-98146-64201'],
      timing: '24×7 (Open all days)',
      is24x7: true,
      services: [
        'Maternity / Obstetrics & Gynecology',
        'General Medicine',
        'Pulmonology',
        'Orthopedics',
        'Neurology',
        'Anesthesiology',
        'Laboratory & Radiology',
        'Diagnostic Services'
      ],
      directions: 'Navigate towards Patiala Gate area of Nabha, then look for Ripudaman Pura / Sham Bagh Enclave, or follow signs for Gurdwara Akalgarh.',
      specialNote: 'Key landmark: Gurdwara Akalgarh is nearby',
    ),
    
    Hospital(
      name: 'Goyal Health Care Hospital',
      address: 'Nabha, Patiala district, Punjab\nNear Sahmane Dhanetha Hospital and Ekjyot Eye Hospital',
      phone: 'Contact for phone number',
      timing: 'Contact for timings',
      services: [
        'General Medicine',
        'Surgery',
        'Emergency Services',
        'Multi-specialty care'
      ],
      directions: 'Located in the local hospital cluster in Nabha, near Bansal Hospital & Laparoscopic Centre, Ekjyot Eye Hospital, and Aneja Children & Maternity Hospital.',
      specialNote: 'GPS: Latitude ~ 30.37669°, Longitude ~ 76.16144°',
    ),
    
    Hospital(
      name: 'Bansal Hospital & Laparoscopic Centre',
      address: 'Circular Road, Nabha, Punjab',
      phone: 'Contact for phone number',
      timing: 'Contact for timings',
      services: [
        'Laparoscopic Surgery',
        'General Surgery',
        'Gastroenterology',
        'Endoscopy',
        'OPD Services'
      ],
      directions: 'Located on Circular Road in Nabha\'s central area. Close to Goyal Health Care Hospital and other hospitals in the cluster.',
    ),
    
    Hospital(
      name: 'Veenu Goyal Hospital',
      address: 'Bouran Gate, Nabha, Punjab',
      phone: 'Contact for phone number',
      timing: 'Contact for timings',
      services: [
        'General Medicine',
        'Surgery',
        'Emergency Services'
      ],
      directions: 'Located at Bouran Gate area of Nabha. Use navigation apps with "Veenu Goyal Hospital, Nabha" for exact location.',
    ),
    
    Hospital(
      name: 'Nabha Medicare Hospital',
      address: 'Nabha, Punjab',
      phone: 'Contact for phone number',
      timing: '24/7 Emergency Services',
      is24x7: true,
      services: [
        'Multi-specialty care',
        '24/7 Emergency',
        'General Medicine',
        'Surgery',
        'ICU Services'
      ],
      directions: 'Use "Nabha Medicare Hospital, Nabha" in navigation apps to locate.',
    ),
    
    Hospital(
      name: 'Ekjyot Eye Hospital',
      address: 'Sangatpura Colony, Nabha, Punjab',
      phone: 'Contact for phone number',
      timing: 'Contact for timings',
      services: [
        'Ophthalmology',
        'Eye Surgery',
        'Retina Treatment',
        'Eye Checkups',
        'Vision Care'
      ],
      directions: 'Navigate toward Sangatpura in Nabha. Close to Goyal Health Care Hospital and Bansal Hospital & Laparoscopic Centre.',
    ),
    
    Hospital(
      name: 'Aneja Children & Maternity Hospital',
      address: 'Hira Mahal Colony, Nabha, Punjab',
      phone: 'Contact for phone number',
      timing: 'Contact for timings',
      services: [
        'Pediatrics',
        'Maternity Services',
        'Neonatology',
        'NICU Services',
        'Child Care'
      ],
      directions: 'Located in Hira Mahal Colony area. Use "Aneja Children & Maternity Hospital, Nabha" in map apps.',
    ),
    
    Hospital(
      name: 'Garg Surgical & Children Hospital',
      address: 'Circular Road, Nabha, Punjab',
      phone: 'Contact for phone number',
      timing: 'Contact for timings',
      services: [
        'General Surgery',
        'Pediatrics',
        'Orthopedics',
        'Child Surgery',
        'Emergency Care'
      ],
      directions: 'Located on Circular Road in Nabha. Look for hospital signage when you reach Circular Road area.',
    ),
  ];

  List<Hospital> get _filteredHospitals {
    if (_searchQuery.isEmpty) {
      return _hospitals;
    }
    return _hospitals.where((hospital) {
      return hospital.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             hospital.services.any((service) => service.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospitals Directory'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and header section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search hospitals or services...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Nabha, Punjab',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_filteredHospitals.length} Hospitals',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Hospitals list
          Expanded(
            child: _filteredHospitals.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredHospitals.length,
                    itemBuilder: (context, index) {
                      final hospital = _filteredHospitals[index];
                      return _buildHospitalCard(hospital);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.grey400,
          ),
          SizedBox(height: 16),
          Text(
            'No hospitals found',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(Hospital hospital) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hospital name and 24x7 badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    hospital.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (hospital.is24x7)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '24×7',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            if (hospital.specialNote != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hospital.specialNote!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Address
            _buildInfoRow(Icons.location_on, 'Address', hospital.address),
            const SizedBox(height: 8),
            
            // Phone
            _buildInfoRow(Icons.phone, 'Phone', hospital.phone, isClickable: true),
            
            // Alternate numbers
            if (hospital.alternateNumbers.isNotEmpty) ...[
              const SizedBox(height: 4),
              _buildInfoRow(Icons.phone_android, 'Alternate Numbers', 
                hospital.alternateNumbers.join(', '), isClickable: true),
            ],
            
            const SizedBox(height: 8),
            
            // Timing
            _buildInfoRow(Icons.access_time, 'Timing', hospital.timing),
            const SizedBox(height: 12),
            
            // Services
            const Text(
              'Services:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hospital.services.map((service) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.grey300),
                  ),
                  child: Text(
                    service,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // Directions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.directions, color: AppColors.primary, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Directions:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hospital.directions,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openInMaps(hospital.name),
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text('Get Directions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hospital.phone.contains('+91') 
                        ? () => _makePhoneCall(hospital.phone)
                        : null,
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hospital.phone.contains('+91') 
                          ? AppColors.success
                          : AppColors.grey400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isClickable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.grey600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isClickable ? AppColors.primary : AppColors.grey700,
              decoration: isClickable ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }

  void _openInMaps(String hospitalName) async {
    final query = Uri.encodeComponent('$hospitalName, Nabha, Punjab');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps. Please try again.'),
          ),
        );
      }
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not make phone call. Please try again.'),
          ),
        );
      }
    }
  }
}