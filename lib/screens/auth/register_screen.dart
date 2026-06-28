import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/skill_model.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/neumorphic_container.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  final _formKeyStep1 = GlobalKey<FormState>();

  // Step 1 Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  final _collegeController = TextEditingController();
  final _deptController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _profileImage;

  // Step 2 Data
  final List<OfferedSkill> _skillsToTeach = [];
  final List<OfferedSkill> _skillsToLearn = [];
  String _classAccessPreference = 'All Classes';

  // Constants
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];
  final UserRole _selectedRole = UserRole.learner; // Default role after selector removal

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _collegeController.dispose();
    _deptController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (picked != null) {
        setState(() {
          _profileImage = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKeyStep1.currentState!.validate()) return;
      if (_profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a profile picture.'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
        );
        return;
      }
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _prevStep() {
    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
      });
    }
  }

  void _showAddSkillDialog({required bool isTeaching}) {
    final theme = Theme.of(context);
    final nameCtrl = TextEditingController();
    String selectedCategory = skillCategories.first;
    String selectedLevel = _levels.first;
    final expCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
              title: Text(isTeaching ? 'Add Skill to Teach' : 'Add Skill to Learn', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Skill Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                    const SizedBox(height: 6.0),
                    NeumorphicContainer(
                      isInset: true,
                      borderRadius: 12.0,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                      child: TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Python, Figma, Spanish',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                    const SizedBox(height: 6.0),
                    NeumorphicContainer(
                      isInset: true,
                      borderRadius: 12.0,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          dropdownColor: theme.scaffoldBackgroundColor,
                          items: skillCategories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat, style: TextStyle(color: theme.colorScheme.onSurface)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedCategory = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text('Proficiency Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                    const SizedBox(height: 6.0),
                    NeumorphicContainer(
                      isInset: true,
                      borderRadius: 12.0,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedLevel,
                          isExpanded: true,
                          dropdownColor: theme.scaffoldBackgroundColor,
                          items: _levels.map((lvl) {
                            return DropdownMenuItem(
                              value: lvl,
                              child: Text(lvl, style: TextStyle(color: theme.colorScheme.onSurface)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedLevel = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    if (isTeaching) ...[
                      const SizedBox(height: 16.0),
                      const Text('Years of Experience (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                      const SizedBox(height: 6.0),
                      NeumorphicContainer(
                        isInset: true,
                        borderRadius: 12.0,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                        child: TextField(
                          controller: expCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'e.g. 2',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                NeumorphicContainer(
                  borderRadius: 12.0,
                  color: theme.colorScheme.primary,
                  onTap: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a skill name')),
                      );
                      return;
                    }
                    final exp = int.tryParse(expCtrl.text.trim());
                    setState(() {
                      if (isTeaching) {
                        _skillsToTeach.add(
                          OfferedSkill(
                            skillName: name,
                            category: selectedCategory,
                            level: selectedLevel,
                            experienceYears: exp,
                          ),
                        );
                      } else {
                        _skillsToLearn.add(
                          OfferedSkill(
                            skillName: name,
                            category: selectedCategory,
                            level: selectedLevel,
                          ),
                        );
                      }
                    });
                    Navigator.pop(context);
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submit() async {
    // Validate Step 2 Data
    if (_skillsToTeach.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must add at least one skill you can teach.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_skillsToLearn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must add at least one skill you want to learn.'), backgroundColor: Colors.red),
      );
      return;
    }
    // Use default 'Flexible' availability
    const availabilityString = 'Flexible';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      collegeName: _collegeController.text.trim(),
      department: _deptController.text.trim(),
      city: _cityController.text.trim(),
      bio: _bioController.text.trim(),
      skillsOffered: _skillsToTeach,
      skillsWanted: _skillsToLearn,
      availability: availabilityString,
      profilePicture: _profileImage?.path ?? '',
      role: _selectedRole,
      classAccessPreference: _classAccessPreference,
    );

    if (mounted) {
      Navigator.pop(context); // Dismiss loading dialog
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully! Please log in.'), backgroundColor: Colors.green),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Registration failed.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_currentStep == 0 ? 'Create Account' : 'Skills & Availability'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join SkillSwap',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                _currentStep == 0
                    ? 'Enter your college and academic profile to begin matching.'
                    : 'Setup your learning portfolio and scheduling preferences.',
                style: TextStyle(
                  fontSize: 12.0,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24.0),
              _currentStep == 0 ? _buildStep1(theme) : _buildStep2(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(ThemeData theme) {
    return Form(
      key: _formKeyStep1,
      child: Column(
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  NeumorphicContainer(
                    borderRadius: 46.0,
                    shape: BoxShape.circle,
                    child: CircleAvatar(
                      radius: 46.0,
                      backgroundColor: Colors.transparent,
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? Icon(
                              Icons.add_a_photo,
                              size: 30.0,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.scaffoldBackgroundColor, width: 2.0),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 12.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6.0),
          const Center(
            child: Text(
              'Upload Profile Picture (Mandatory)',
              style: TextStyle(fontSize: 12.0, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24.0),
          CustomTextField(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            controller: _nameController,
            prefixIcon: Icons.person,
            validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            labelText: 'Email Address',
            hintText: 'Enter your college or personal email',
            controller: _emailController,
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Email is required';
              if (!val.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            labelText: 'Phone Number',
            hintText: 'Enter your 10-digit number',
            controller: _phoneController,
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (val) => val == null || val.isEmpty ? 'Phone number is required' : null,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            labelText: 'City',
            hintText: 'e.g. Bangalore, Mumbai',
            controller: _cityController,
            prefixIcon: Icons.location_city,
            validator: (val) => val == null || val.isEmpty ? 'City is required' : null,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            labelText: 'Short Bio',
            hintText: 'Tell us a bit about your hobbies and skills',
            controller: _bioController,
            prefixIcon: Icons.edit_note,
            validator: (val) => val == null || val.isEmpty ? 'Bio is required' : null,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            labelText: 'College Name',
            hintText: 'Enter your university/college',
            controller: _collegeController,
            prefixIcon: Icons.school,
            validator: (val) => val == null || val.isEmpty ? 'College is required' : null,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            labelText: 'Department',
            hintText: 'e.g. Computer Science, Mechanical',
            controller: _deptController,
            prefixIcon: Icons.account_tree,
            validator: (val) => val == null || val.isEmpty ? 'Department is required' : null,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            labelText: 'Password',
            hintText: 'Min 6 characters',
            controller: _passwordController,
            prefixIcon: Icons.lock,
            isPassword: true,
            validator: (val) => val == null || val.length < 6 ? 'Password too short' : null,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            labelText: 'Confirm Password',
            hintText: 'Re-enter password',
            controller: _confirmPasswordController,
            prefixIcon: Icons.lock_clock,
            isPassword: true,
            validator: (val) => val == null || val.isEmpty ? 'Please confirm password' : null,
          ),
          const SizedBox(height: 28.0),
          CustomButton(
            text: 'Continue to Portfolio',
            onPressed: _nextStep,
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Teaching Skills Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Skills I Can Teach (Mandatory)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
              onPressed: () => _showAddSkillDialog(isTeaching: true),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        _skillsToTeach.isEmpty
            ? _buildEmptySkillBox('No teaching skills added. Tap the + icon to add at least one.')
            : _buildSkillList(_skillsToTeach, true),
        const SizedBox(height: 24.0),

        // Learning Skills Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Skills I Want to Learn (Mandatory)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
              onPressed: () => _showAddSkillDialog(isTeaching: false),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        _skillsToLearn.isEmpty
            ? _buildEmptySkillBox('No learning skills added. Tap the + icon to add at least one.')
            : _buildSkillList(_skillsToLearn, false),
        const SizedBox(height: 24.0),

        Text(
          'Platform Access Preference',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        NeumorphicContainer(
          isInset: true,
          borderRadius: 12.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: _classAccessPreference,
              dropdownColor: theme.scaffoldBackgroundColor,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'All Classes',
                  child: Text('All Classes & Peer Matchmaking'),
                ),
                DropdownMenuItem(
                  value: 'Free Live Classes Only',
                  child: Text('Free Live Classes Only'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _classAccessPreference = val;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 32.0),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: NeumorphicContainer(
                borderRadius: 18.0,
                onTap: _prevStep,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Center(
                  child: Text(
                    'Back',
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, fontSize: 16.0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: CustomButton(
                text: 'Register',
                onPressed: _submit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildEmptySkillBox(String text) {
    return NeumorphicContainer(
      isInset: true,
      borderRadius: 12.0,
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 12.0),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSkillList(List<OfferedSkill> list, bool isTeaching) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: NeumorphicContainer(
            borderRadius: 14.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(item.skillName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                isTeaching
                    ? '${item.category} • ${item.level} • ${item.experienceYears ?? 0} yrs exp'
                    : '${item.category} • ${item.level}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 18.0),
                onPressed: () {
                  setState(() {
                    list.removeAt(index);
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
