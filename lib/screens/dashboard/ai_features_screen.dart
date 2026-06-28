import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ai_provider.dart';
import '../../widgets/neumorphic_container.dart';

class AiFeaturesScreen extends StatefulWidget {
  const AiFeaturesScreen({super.key});

  @override
  State<AiFeaturesScreen> createState() => _AiFeaturesScreenState();
}

class _EditApiKeyDialog extends StatefulWidget {
  final String initialKey;
  final Function(String) onSave;

  const _EditApiKeyDialog({required this.initialKey, required this.onSave});

  @override
  State<_EditApiKeyDialog> createState() => _EditApiKeyDialogState();
}

class _EditApiKeyDialogState extends State<_EditApiKeyDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      title: Text('API Configurations', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Insert your Gemini API key to activate live generative models.', style: TextStyle(fontSize: 12.0, color: Colors.grey)),
          const SizedBox(height: 12.0),
          NeumorphicContainer(
            isInset: true,
            borderRadius: 12.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
            child: TextField(
              controller: _controller,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter API Key...',
                border: InputBorder.none,
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
          onTap: () {
            widget.onSave(_controller.text.trim());
            Navigator.pop(context);
          },
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: const Text('Save Key', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }
}

class _AiFeaturesScreenState extends State<AiFeaturesScreen> {
  final _dreamJobController = TextEditingController();
  final _skillRoadmapController = TextEditingController();
  late final TextEditingController _apiKeyController;

  String? _generatedRoadmap;
  String? _generatedCareerGuidance;

  @override
  void initState() {
    super.initState();
    final aiProv = Provider.of<AiProvider>(context, listen: false);
    _apiKeyController = TextEditingController(text: aiProv.apiKey);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        // Load AI Skill suggestions based on user wanted skills
        final interests = user.skillsWanted.map((s) => s.skillName).toList();
        aiProv.loadSkillSuggestions(interests);
      }
    });
  }

  @override
  void dispose() {
    _dreamJobController.dispose();
    _skillRoadmapController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _generateRoadmap() async {
    final skill = _skillRoadmapController.text.trim();
    if (skill.isEmpty) return;

    FocusScope.of(context).unfocus();
    final aiProv = Provider.of<AiProvider>(context, listen: false);

    await aiProv.loadRoadmap(skill);
    setState(() {
      _generatedRoadmap = aiProv.getRoadmap(skill);
    });
  }

  void _generateCareerGuidance() async {
    final job = _dreamJobController.text.trim();
    if (job.isEmpty) return;

    FocusScope.of(context).unfocus();
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final aiProv = Provider.of<AiProvider>(context, listen: false);

    final userSkills = authProv.currentUser?.skillsOffered.map((s) => s.skillName).toList() ?? [];

    await aiProv.loadCareerGuidance(userSkills, job);
    setState(() {
      _generatedCareerGuidance = aiProv.getCareerGuidance(job);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiProv = Provider.of<AiProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('AI Learning Suite', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 28.0),
                const SizedBox(width: 8.0),
                Text(
                  'Powered by Google Gemini AI',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            const Text(
              'Generate personalized weekly roadmaps, check compatibility metrics, and discover matching tutors.',
              style: TextStyle(fontSize: 12.0, color: Colors.grey, height: 1.3),
            ),
            const SizedBox(height: 12.0),
            
            // Mode Status Banner
            NeumorphicContainer(
              borderRadius: 12.0,
              color: aiProv.apiKey.isNotEmpty 
                  ? Colors.green.withValues(alpha: 0.08) 
                  : Colors.amber.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Row(
                children: [
                  Icon(
                    aiProv.apiKey.isNotEmpty ? Icons.check_circle : Icons.info,
                    color: aiProv.apiKey.isNotEmpty ? Colors.green : Colors.amber.shade700,
                    size: 18.0,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      aiProv.apiKey.isNotEmpty 
                          ? 'Live Gemini AI Connection Active' 
                          : 'Mock Demo Mode Active (Enter your API key below for live AI)',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: aiProv.apiKey.isNotEmpty ? Colors.green.shade800 : Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32.0),

            // 1. AI Skill Suggestions
            Text('AI Skill Suggestions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12.0),
            aiProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: aiProv.suggestedSkills.map((s) {
                      return NeumorphicContainer(
                        borderRadius: 12.0,
                        onTap: () {
                          setState(() {
                            _skillRoadmapController.text = s;
                          });
                          _generateRoadmap(); // Auto-generate when clicked
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, size: 14.0, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 4.0),
                            Text(s, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 24.0),

            // 2. AI Learning Roadmap Generator
            Text('Generate Learning Roadmap', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: NeumorphicContainer(
                    isInset: true,
                    borderRadius: 18.0,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                    child: TextField(
                      controller: _skillRoadmapController,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: const InputDecoration(
                        hintText: 'Enter skill e.g. Machine Learning',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                NeumorphicContainer(
                  borderRadius: 18.0,
                  color: theme.colorScheme.primary,
                  onTap: _generateRoadmap,
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                  child: const Text('Generate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0)),
                ),
              ],
            ),
            if (_generatedRoadmap != null) ...[
              const SizedBox(height: 16.0),
              NeumorphicContainer(
                isInset: true,
                borderRadius: 16.0,
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _generatedRoadmap!,
                  style: TextStyle(fontSize: 13.0, color: theme.colorScheme.onSurface),
                ),
              ),
            ],
            const SizedBox(height: 28.0),

            // 3. AI Career Guidance
            Text('AI Career Advisor', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: NeumorphicContainer(
                    isInset: true,
                    borderRadius: 18.0,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                    child: TextField(
                      controller: _dreamJobController,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: const InputDecoration(
                        hintText: 'Enter target job e.g. Data Scientist',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                NeumorphicContainer(
                  borderRadius: 18.0,
                  color: theme.colorScheme.primary,
                  onTap: _generateCareerGuidance,
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                  child: const Text('Analyze', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0)),
                ),
              ],
            ),
            if (_generatedCareerGuidance != null) ...[
              const SizedBox(height: 16.0),
              NeumorphicContainer(
                isInset: true,
                borderRadius: 16.0,
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _generatedCareerGuidance!,
                  style: TextStyle(fontSize: 13.0, color: theme.colorScheme.onSurface),
                ),
              ),
            ],
            const SizedBox(height: 28.0),

            // 4. AI Gemini API Key Setting (Premium configuration option)
            NeumorphicContainer(
              borderRadius: 20.0,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('API Configurations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                  const SizedBox(height: 4.0),
                  const Text('Insert your Gemini API key to activate live generative models.', style: TextStyle(fontSize: 11.0, color: Colors.grey)),
                  const SizedBox(height: 12.0),
                  NeumorphicContainer(
                    isInset: true,
                    borderRadius: 12.0,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                    child: TextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      onChanged: (val) => aiProv.setApiKey(val),
                      decoration: const InputDecoration(
                        hintText: 'Enter API Key...',
                        border: InputBorder.none,
                      ),
                    ),
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
