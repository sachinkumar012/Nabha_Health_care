import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../auth/domain/models/user.dart';

class CompleteProfilePage extends ConsumerStatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  ConsumerState<CompleteProfilePage> createState() =>
      _CompleteProfilePageState();
}

class _CompleteProfilePageState extends ConsumerState<CompleteProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Personal Information Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _locationController = TextEditingController();

  // Medical Information Controllers
  final _allergiesController = TextEditingController();
  final _currentMedicationsController = TextEditingController();
  final _pastMedicationsController = TextEditingController();
  final _chronicDiseasesController = TextEditingController();
  final _injuriesController = TextEditingController();
  final _surgeriesController = TextEditingController();

  // Lifestyle Information Controllers
  final _occupationController = TextEditingController();

  // Selected values
  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedMaritalStatus;
  String? _selectedSmokingHabits;
  String? _selectedAlcoholConsumption;
  String? _selectedActivityLevel;
  String? _selectedFoodPreference;

  // Options for dropdowns
  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say'
  ];
  final List<String> _bloodGroupOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  final List<String> _maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed'
  ];
  final List<String> _smokingHabitsOptions = [
    'Never',
    'Former',
    'Occasional',
    'Regular'
  ];
  final List<String> _alcoholConsumptionOptions = [
    'Never',
    'Occasional',
    'Social',
    'Regular'
  ];
  final List<String> _activityLevelOptions = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active'
  ];
  final List<String> _foodPreferenceOptions = [
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'Eggetarian'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(userProvider);
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _addressController.text = user.address ?? '';
      _dobController.text = user.dateOfBirth ?? '';
      _heightController.text = user.height ?? '';
      _weightController.text = user.weight ?? '';
      _emergencyContactController.text = user.emergencyContact ?? '';
      _locationController.text = user.location ?? '';

      // Medical Information
      _allergiesController.text = user.allergies?.join(', ') ?? '';
      _currentMedicationsController.text =
          user.currentMedications?.join(', ') ?? '';
      _pastMedicationsController.text = user.pastMedications?.join(', ') ?? '';
      _chronicDiseasesController.text = user.chronicDiseases?.join(', ') ?? '';
      _injuriesController.text = user.injuries?.join(', ') ?? '';
      _surgeriesController.text = user.surgeries?.join(', ') ?? '';

      // Lifestyle Information
      _occupationController.text = user.occupation ?? '';

      // Selected values
      _selectedGender = user.gender;
      _selectedBloodGroup = user.bloodGroup;
      _selectedMaritalStatus = user.maritalStatus;
      _selectedSmokingHabits = user.smokingHabits;
      _selectedAlcoholConsumption = user.alcoholConsumption;
      _selectedActivityLevel = user.activityLevel;
      _selectedFoodPreference = user.foodPreference;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose all controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emergencyContactController.dispose();
    _locationController.dispose();
    _allergiesController.dispose();
    _currentMedicationsController.dispose();
    _pastMedicationsController.dispose();
    _chronicDiseasesController.dispose();
    _injuriesController.dispose();
    _surgeriesController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Personal'),
            Tab(text: 'Medical'),
            Tab(text: 'Lifestyle'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPersonalTab(user),
            _buildMedicalTab(user),
            _buildLifestyleTab(user),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_tabController.index > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _tabController.animateTo(_tabController.index - 1);
                  },
                  child: const Text('Previous'),
                ),
              ),
            if (_tabController.index > 0) const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _tabController.index == 2 ? 'Save Profile' : 'Save & Next',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTab(User? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile completion indicator
          _buildCompletionIndicator(user),
          const SizedBox(height: 24),

          // Profile Image Section
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: user?.profileImageUrl?.isNotEmpty == true
                    ? ClipOval(
                        child: Image.network(
                          user!.profileImageUrl!,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primary,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: AppColors.primary,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Tap to add photo',
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Personal Information Fields
          _buildTextField('Name', _nameController, Icons.person,
              isRequired: true),
          const SizedBox(height: 16),

          _buildTextField('Contact Number', _phoneController, Icons.phone,
              isRequired: true, readOnly: true),
          const SizedBox(height: 16),

          _buildTextField('Email ID', _emailController, Icons.email,
              isRequired: true, readOnly: true),
          const SizedBox(height: 16),

          _buildDropdownField('Gender', _selectedGender, _genderOptions,
              (value) {
            setState(() {
              _selectedGender = value;
            });
          }),
          const SizedBox(height: 16),

          _buildDateField('Date of Birth', _dobController),
          const SizedBox(height: 16),

          _buildDropdownField(
              'Blood Group', _selectedBloodGroup, _bloodGroupOptions, (value) {
            setState(() {
              _selectedBloodGroup = value;
            });
          }),
          const SizedBox(height: 16),

          _buildDropdownField(
              'Marital Status', _selectedMaritalStatus, _maritalStatusOptions,
              (value) {
            setState(() {
              _selectedMaritalStatus = value;
            });
          }),
          const SizedBox(height: 16),

          _buildTextField('Height (cm)', _heightController, Icons.height),
          const SizedBox(height: 16),

          _buildTextField(
              'Weight (kg)', _weightController, Icons.monitor_weight),
          const SizedBox(height: 16),

          _buildTextField('Emergency Contact', _emergencyContactController,
              Icons.emergency),
          const SizedBox(height: 16),

          _buildTextField('Location', _locationController, Icons.location_on),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMedicalTab(User? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medical Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Allergies', _allergiesController, Icons.warning,
              hintText: 'Enter allergies separated by commas'),
          const SizedBox(height: 16),
          _buildTextField('Current Medications', _currentMedicationsController,
              Icons.medication,
              hintText: 'Enter medications separated by commas'),
          const SizedBox(height: 16),
          _buildTextField(
              'Past Medications', _pastMedicationsController, Icons.history,
              hintText: 'Enter past medications separated by commas'),
          const SizedBox(height: 16),
          _buildTextField('Chronic Diseases', _chronicDiseasesController,
              Icons.local_hospital,
              hintText: 'Enter chronic diseases separated by commas'),
          const SizedBox(height: 16),
          _buildTextField('Injuries', _injuriesController, Icons.healing,
              hintText: 'Enter past injuries separated by commas'),
          const SizedBox(height: 16),
          _buildTextField(
              'Surgeries', _surgeriesController, Icons.medical_services,
              hintText: 'Enter past surgeries separated by commas'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLifestyleTab(User? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lifestyle Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
              'Smoking Habits', _selectedSmokingHabits, _smokingHabitsOptions,
              (value) {
            setState(() {
              _selectedSmokingHabits = value;
            });
          }),
          const SizedBox(height: 16),
          _buildDropdownField('Alcohol Consumption',
              _selectedAlcoholConsumption, _alcoholConsumptionOptions, (value) {
            setState(() {
              _selectedAlcoholConsumption = value;
            });
          }),
          const SizedBox(height: 16),
          _buildDropdownField(
              'Activity Level', _selectedActivityLevel, _activityLevelOptions,
              (value) {
            setState(() {
              _selectedActivityLevel = value;
            });
          }),
          const SizedBox(height: 16),
          _buildDropdownField('Food Preference', _selectedFoodPreference,
              _foodPreferenceOptions, (value) {
            setState(() {
              _selectedFoodPreference = value;
            });
          }),
          const SizedBox(height: 16),
          _buildTextField('Occupation', _occupationController, Icons.work),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCompletionIndicator(User? user) {
    final completionPercentage = user?.profileCompletionPercentage ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Completion',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: completionPercentage / 100,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$completionPercentage%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isRequired = false, bool readOnly = false, String? hintText}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        hintText: hintText ?? 'Add $label',
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> options,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Add $label',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'yyyy mm dd',
        prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            controller.text =
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          });
        }
      },
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Here you would upload the image and update the user profile
      // For now, we'll just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image selected! Save profile to update.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final currentUser = ref.read(userProvider);
        if (currentUser == null) return;

        // Create updated user with all the new information
        final updatedUser = currentUser.copyWith(
          name: _nameController.text,
          address:
              _addressController.text.isEmpty ? null : _addressController.text,
          dateOfBirth: _dobController.text.isEmpty ? null : _dobController.text,
          gender: _selectedGender,
          bloodGroup: _selectedBloodGroup,
          maritalStatus: _selectedMaritalStatus,
          height:
              _heightController.text.isEmpty ? null : _heightController.text,
          weight:
              _weightController.text.isEmpty ? null : _weightController.text,
          emergencyContact: _emergencyContactController.text.isEmpty
              ? null
              : _emergencyContactController.text,
          location: _locationController.text.isEmpty
              ? null
              : _locationController.text,
          // Medical Information
          allergies: _allergiesController.text.isEmpty
              ? null
              : _allergiesController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
          currentMedications: _currentMedicationsController.text.isEmpty
              ? null
              : _currentMedicationsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
          pastMedications: _pastMedicationsController.text.isEmpty
              ? null
              : _pastMedicationsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
          chronicDiseases: _chronicDiseasesController.text.isEmpty
              ? null
              : _chronicDiseasesController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
          injuries: _injuriesController.text.isEmpty
              ? null
              : _injuriesController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
          surgeries: _surgeriesController.text.isEmpty
              ? null
              : _surgeriesController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
          // Lifestyle Information
          smokingHabits: _selectedSmokingHabits,
          alcoholConsumption: _selectedAlcoholConsumption,
          activityLevel: _selectedActivityLevel,
          foodPreference: _selectedFoodPreference,
          occupation: _occupationController.text.isEmpty
              ? null
              : _occupationController.text,
        );

        // Update user profile
        await ref.read(userProvider.notifier).updateUser(updatedUser);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to next tab or close
        if (_tabController.index < 2) {
          _tabController.animateTo(_tabController.index + 1);
        } else {
          Navigator.of(context)
              .pop(true); // Return true to indicate profile was updated
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
