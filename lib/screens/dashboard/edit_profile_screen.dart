import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/skill_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/skill_tag.dart';
import '../../widgets/neumorphic_container.dart';
import '../../widgets/avatar_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _bioController = TextEditingController();
  final _collegeController = TextEditingController();
  final _deptController = TextEditingController();
  String _classAccessPreference = 'All Classes';
  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _bioController.text = user.bio;
      _collegeController.text = user.collegeName;
      _deptController.text = user.department;
      _classAccessPreference = user.classAccessPreference;
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _collegeController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (picked != null) {
        setState(() {
          _newProfileImage = File(picked.path);
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

  void _saveProfile() async {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    
    // Save image if updated
    if (_newProfileImage != null) {
      await authProv.updateProfilePicture(_newProfileImage!.path);
    }
    
    await authProv.updateBio(_bioController.text.trim());
    await authProv.updateCollegeAndDepartment(
      _collegeController.text.trim(),
      _deptController.text.trim(),
    );
    await authProv.updateClassAccessPreference(_classAccessPreference);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  void _showAddSkillDialog(bool isOffered) {
    final theme = Theme.of(context);
    String selectedSkillName = popularSkills.first.name;
    String selectedLevel = 'Beginner';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
              title: Text(isOffered ? 'Add Offered Skill' : 'Add Wanted Skill', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select skill topic:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                  const SizedBox(height: 6.0),
                  NeumorphicContainer(
                    isInset: true,
                    borderRadius: 12.0,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSkillName,
                        isExpanded: true,
                        dropdownColor: theme.scaffoldBackgroundColor,
                        items: popularSkills.map((s) {
                          return DropdownMenuItem<String>(
                            value: s.name,
                            child: Text(s.name, style: TextStyle(color: theme.colorScheme.onSurface)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedSkillName = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Select your proficiency level:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
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
                        items: ['Beginner', 'Intermediate', 'Advanced', 'Expert'].map((l) {
                          return DropdownMenuItem<String>(
                            value: l,
                            child: Text(l, style: TextStyle(color: theme.colorScheme.onSurface)),
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
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                NeumorphicContainer(
                  borderRadius: 12.0,
                  color: theme.colorScheme.primary,
                  onTap: () async {
                    final authProv = Provider.of<AuthProvider>(context, listen: false);
                    if (isOffered) {
                      await authProv.addOfferedSkill(selectedSkillName, selectedLevel);
                    } else {
                      await authProv.addWantedSkill(selectedSkillName, selectedLevel);
                    }
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: const Text('Add Skill', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProv = Provider.of<AuthProvider>(context);
    final user = authProv.currentUser;

    if (user == null) return const Scaffold();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Editor Section
            Center(
              child: Stack(
                children: [
                  NeumorphicContainer(
                    shape: BoxShape.circle,
                    padding: const EdgeInsets.all(4.0),
                    child: _newProfileImage != null
                        ? CircleAvatar(
                            radius: 54.0,
                            backgroundImage: FileImage(_newProfileImage!),
                          )
                        : buildSafeAvatar(
                            imagePath: user.profilePicture,
                            radius: 54.0,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: NeumorphicContainer(
                        shape: BoxShape.circle,
                        padding: const EdgeInsets.all(8.0),
                        color: theme.colorScheme.primary,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            Text('Academic Profile', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12.0),
            CustomTextField(
              labelText: 'College / University',
              hintText: 'Enter college name',
              controller: _collegeController,
              prefixIcon: Icons.school,
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              labelText: 'Department',
              hintText: 'Enter department name',
              controller: _deptController,
              prefixIcon: Icons.account_tree,
            ),
            const SizedBox(height: 24.0),

            Text('About Me', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12.0),
            CustomTextField(
              labelText: 'Biography',
              hintText: 'Describe your learning interests, teaching goals, and general bio...',
              controller: _bioController,
              prefixIcon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 24.0),

            Text('Platform Access', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12.0),
            NeumorphicContainer(
              isInset: true,
              borderRadius: 18.0,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: _classAccessPreference,
                  dropdownColor: theme.scaffoldBackgroundColor,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.class_outlined),
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
            const SizedBox(height: 28.0),

            // Skills Offered
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Skills Offered (What you teach)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
                  onPressed: () => _showAddSkillDialog(true),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            NeumorphicContainer(
              isInset: true,
              borderRadius: 16.0,
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              child: user.skillsOffered.isEmpty
                  ? const Text('Click + to add skills you can teach to others.', style: TextStyle(fontSize: 12.0, color: Colors.grey))
                  : Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: user.skillsOffered.map((s) {
                        return SkillTag(
                          label: s.skillName,
                          level: s.level,
                          onDeleted: () => authProv.removeSkill(s.skillName, true),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 20.0),

            // Skills Wanted
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Skills Wanted (What you learn)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
                  onPressed: () => _showAddSkillDialog(false),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            NeumorphicContainer(
              isInset: true,
              borderRadius: 16.0,
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              child: user.skillsWanted.isEmpty
                  ? const Text('Click + to add skills you want to learn from mentors.', style: TextStyle(fontSize: 12.0, color: Colors.grey))
                  : Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: user.skillsWanted.map((s) {
                        return SkillTag(
                          label: s.skillName,
                          level: s.level,
                          onDeleted: () => authProv.removeSkill(s.skillName, false),
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 36.0),
            CustomButton(
              text: 'Save Profile Changes',
              isLoading: authProv.isLoading,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
