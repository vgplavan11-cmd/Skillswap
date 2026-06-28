import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  String _apiKey = '';

  void setApiKey(String key) {
    _apiKey = key;
  }

  bool get hasApiKey => _apiKey.isNotEmpty;

  // --- 1. AI SKILL RECOMMENDATION ---

  Future<List<String>> getSkillRecommendations(List<String> interests) async {
    if (interests.isEmpty) {
      return ['Python Programming', 'Figma UI/UX Design', 'Product Management'];
    }

    if (hasApiKey) {
      try {
        final prompt = 'Given these user interests: ${interests.join(", ")}, suggest exactly 3 skill topics they should learn next. Return only a JSON array of strings.';
        final response = await _callGemini(prompt);
        final List<dynamic> list = jsonDecode(response);
        return list.map((e) => e.toString()).toList();
      } catch (e) {
        print("Gemini API Error, falling back to mock: $e");
      }
    }

    // Mock/Template-based recommendations
    final suggestions = <String>[];
    for (var interest in interests) {
      final item = interest.toLowerCase();
      if (item.contains('code') || item.contains('program') || item.contains('software')) {
        suggestions.addAll(['Data Structures & Algorithms', 'Web Development with React', 'Mobile Apps with Flutter']);
      } else if (item.contains('design') || item.contains('art') || item.contains('draw')) {
        suggestions.addAll(['Advanced Figma Prototyping', 'Design Systems', 'Typography & Visual Hierarchy']);
      } else if (item.contains('business') || item.contains('start') || item.contains('money')) {
        suggestions.addAll(['Financial Modeling', 'Growth Marketing', 'Product Strategy']);
      }
    }
    if (suggestions.isEmpty) {
      suggestions.addAll(['Python Programming', 'Figma UI/UX Design', 'Machine Learning']);
    }
    return suggestions.take(3).toList();
  }

  // --- 2. AI LEARNING ROADMAP ---

  Future<String> generateLearningRoadmap(String skillName) async {
    if (hasApiKey) {
      try {
        final prompt = 'Generate a detailed weekly learning roadmap for the skill "$skillName" spanning 4 weeks. Include weekly learning topics and resource suggestions. Output in formatted markdown.';
        return await _callGemini(prompt);
      } catch (e) {
        print("Gemini API Error, falling back: $e");
      }
    }

    // Dynamic, beautiful mock template markdown
    return '''
# AI Learning Roadmap: $skillName
*A structured 4-week learning roadmap designed just for you.*

---

## 📅 Week 1: Core Fundamentals & Setups
* **Topics**: Introduction to basic syntax, concepts, variables, environment setups, and compiling the first execution sample.
* **Hands-on Practice**: Set up local IDE tools, run hello world applications, and configure compiler/version variables.
* **Suggested Resources**: Official documentation and YouTube crash courses.

## 📅 Week 2: Intermediate Abstractions & Controls
* **Topics**: Control flow trees, conditions, loops, array elements, functions, and exception handling routines.
* **Hands-on Practice**: Solve 5 algorithm exercises using loops and array mapping parameters.
* **Suggested Resources**: Interactive coding websites (HackerRank/LeetCode) and visual tutorials.

## 📅 Week 3: Advanced Architectures & Integrations
* **Topics**: Object-oriented models, modular imports, file operations, API fetches, and structured package formatting.
* **Hands-on Practice**: Build a local CLI command tracker that reads and writes json profile arrays to disk.
* **Suggested Resources**: Medium design pattern tutorials.

## 📅 Week 4: Capstone Portfolio Build & Deployment
* **Topics**: Project design scoping, refactoring boilerplate, testing edge cases, and pushing to GitHub codebases.
* **Hands-on Practice**: Complete and package the final app for peer review and showcase it on your SkillSwap profile!
* **Suggested Resources**: GitHub workflows and host deploy document pages.
''';
  }

  // --- 3. AI CAREER GUIDANCE ---

  Future<String> generateCareerGuidance(List<String> currentSkills, String dreamJob) async {
    if (hasApiKey) {
      try {
        final prompt = 'A student knows these skills: ${currentSkills.join(", ")} and wants to become a "$dreamJob". Provide 3 actionable career tips, recommended skill additions, and prospective jobs. Output in formatted markdown.';
        return await _callGemini(prompt);
      } catch (e) {
        print("Gemini API Error, falling back: $e");
      }
    }

    // Mock career template
    return '''
# AI Career Advisor: Transition to $dreamJob
*Personalized pathway analysis based on your current skill sets.*

---

### 🔍 Gap Analysis
* **Your Current Skills**: ${currentSkills.isEmpty ? "Generalist" : currentSkills.join(", ")}
* **Target Role**: $dreamJob

### 🚀 Top 3 Actionable Recommendations
1. **Bridge the Tech Gap**: Add specialized courses in automation and systems integration to match developer hiring profiles.
2. **Build a Public Portfolio**: Create at least 3 end-to-end showcases on GitHub displaying code scalability and documentation.
3. **Engage in Peer Mentoring**: Teach introductory elements on SkillSwap. Explaining concepts to peers strengthens core knowledge.

### 💼 Recommended Job Roles to Apply
* Junior $dreamJob
* Associate Technical Consultant
* QA Analyst / Systems Specialist
''';
  }

  // --- 4. AI SESSION SUMMARY ---

  Future<String> generateSessionSummary(String skillName, String transcripts) async {
    if (hasApiKey) {
      try {
        final prompt = 'Summarize a peer-learning session on the skill "$skillName" based on notes: "$transcripts". Produce 3 key takeaway bullet points. Keep it brief.';
        return await _callGemini(prompt);
      } catch (e) {
        print("Gemini API Error, falling back: $e");
      }
    }

    // Default summaries
    return '1. Mastered core syntaxes and variable setups.\n2. Addressed debugger configurations and run variables.\n3. Defined next goals: build logic loops for next session.';
  }

  // --- 5. AI FAKE REVIEW DETECTION ---

  Future<bool> detectFakeReview(String reviewText) async {
    // Simple rule-based logic to detect obvious spam patterns, falling back to Gemini if available.
    final lowercaseText = reviewText.toLowerCase();

    // Check for spam triggers
    final spamTriggers = [
      'make money fast', 'earn cash', 'free gift card', 'visit website', 'buy bitcoin', 'http', 'spam', 'subscribe to my channel'
    ];

    for (var trigger in spamTriggers) {
      if (lowercaseText.contains(trigger)) {
        return true; // Flagged as spam review
      }
    }

    if (hasApiKey) {
      try {
        final prompt = 'Is this review spam, promotional advertisement, or fake? "$reviewText". Answer with only "true" or "false".';
        final response = await _callGemini(prompt);
        return response.toLowerCase().contains('true');
      } catch (_) {}
    }

    return false;
  }

  // --- GEMINI REST CALL IMPLEMENTATION ---

  Future<String> _callGemini(String prompt) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
      return text.trim();
    } else {
      throw Exception('Gemini API call failed with status: ${response.statusCode}');
    }
  }
}
