import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/skill_model.dart';
import '../../widgets/neumorphic_container.dart';

class LiveClassesScreen extends StatefulWidget {
  const LiveClassesScreen({super.key});

  @override
  State<LiveClassesScreen> createState() => _LiveClassesScreenState();
}

class _LiveClassesScreenState extends State<LiveClassesScreen> {
  final List<Map<String, String>> _liveClasses = [
    {
      'title': 'React JS Components & Hooks',
      'host': 'Priya Sharma',
      'category': 'Programming',
      'time': 'Live Now',
      'participants': '24 joined',
      'isLive': 'true',
    },
    {
      'title': 'Figma Advanced Auto-Layout',
      'host': 'Siddharth Roy',
      'category': 'UI/UX Design',
      'time': 'Live Now',
      'participants': '18 joined',
      'isLive': 'true',
    },
    {
      'title': 'Introduction to Data Models',
      'host': 'Navin Kumar',
      'category': 'Data Science',
      'time': 'June 28, 11:00 AM',
      'participants': '42 joined',
      'isLive': 'false',
    },
  ];

  void _showCreateClassDialog() {
    final theme = Theme.of(context);
    final titleCtrl = TextEditingController();
    String selectedCategory = skillCategories.first;
    DateTime selectedDateTime = DateTime.now().add(const Duration(hours: 2));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
              title: Text('Schedule Public Live Class', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Class Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                    const SizedBox(height: 6.0),
                    NeumorphicContainer(
                      isInset: true,
                      borderRadius: 12.0,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                      child: TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Flutter State Management',
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
                    const Text('Class Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                    const SizedBox(height: 6.0),
                    NeumorphicContainer(
                      borderRadius: 12.0,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDateTime,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (date != null && context.mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                          );
                          if (time != null) {
                            setDialogState(() {
                              selectedDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month, size: 18.0, color: theme.colorScheme.primary),
                          const SizedBox(width: 8.0),
                          Text(
                            '${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} at ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 13.0),
                          ),
                        ],
                      ),
                    ),
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
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a class title')),
                      );
                      return;
                    }
                    setState(() {
                      _liveClasses.insert(0, {
                        'title': title,
                        'host': 'Me',
                        'category': selectedCategory,
                        'time': '${selectedDateTime.day}/${selectedDateTime.month} at ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                        'participants': '1 registered',
                        'isLive': 'false',
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Live Class scheduled successfully!'), backgroundColor: Colors.green),
                    );
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: const Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Classes', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: _showCreateClassDialog,
        icon: const Icon(Icons.add),
        label: const Text('Host Live Class', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _liveClasses.length,
        itemBuilder: (context, index) {
          final c = _liveClasses[index];
          final isLive = c['isLive'] == 'true';

          return NeumorphicContainer(
            margin: const EdgeInsets.only(bottom: 16.0),
            borderRadius: 20.0,
            color: isLive 
                ? (isDark ? const Color(0xFF2C161D) : const Color(0xFFFFECEF))
                : null,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isLive 
                            ? const Color(0xFFEF4444).withValues(alpha: 0.12) 
                            : theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        isLive ? 'LIVE NOW' : 'UPCOMING',
                        style: TextStyle(
                          color: isLive ? const Color(0xFFEF4444) : theme.colorScheme.primary,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 14.0, color: Colors.grey),
                        const SizedBox(width: 4.0),
                        Text(c['participants']!, style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  c['title']!,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                Text('Host: ${c['host']!} • Category: ${c['category']!}', style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      c['time']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isLive ? const Color(0xFFEF4444) : theme.colorScheme.primary,
                      ),
                    ),
                    NeumorphicContainer(
                      borderRadius: 12.0,
                      color: isLive ? const Color(0xFFEF4444) : theme.colorScheme.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LiveStreamRoom(className: c['title']!, hostName: c['host']!),
                          ),
                        );
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        isLive ? 'Join Stream' : 'Register',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LiveStreamRoom extends StatefulWidget {
  final String className;
  final String hostName;

  const LiveStreamRoom({super.key, required this.className, required this.hostName});

  @override
  State<LiveStreamRoom> createState() => _LiveStreamRoomState();
}

class _LiveStreamRoomState extends State<LiveStreamRoom> {
  final List<Map<String, String>> _chatMessages = [];
  final List<String> _studyMaterials = ['Syllabus.pdf', 'LectureNotes.txt'];
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  bool _isRecording = false;
  bool _isCameraOn = true;
  bool _isMicOn = true;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  Timer? _chatTimer;

  final List<String> _mockUserNames = ['Siddharth', 'Priya', 'Navin', 'Kumar', 'Sharma', 'Roy', 'Anjali', 'Vijay'];
  final List<String> _mockPhrases = [
    'Great explanation!',
    'Can you go over that auto-layout trick again?',
    'This is super helpful, thanks!',
    'Does this support dark mode?',
    'What database are we using?',
    'Excellent tutorial.',
    'Is this session recorded?',
    'Wow, peer learning is awesome!',
  ];

  @override
  void initState() {
    super.initState();
    // Simulate periodic incoming chats
    _chatTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final random = DateTime.now().millisecondsSinceEpoch;
      final name = _mockUserNames[random % _mockUserNames.length];
      final text = _mockPhrases[random % _mockPhrases.length];
      if (mounted) {
        setState(() {
          _chatMessages.add({'sender': name, 'text': text});
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _chatTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chatMessages.add({'sender': 'You', 'text': text});
    });
    _msgCtrl.clear();
    _scrollToBottom();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _recordSeconds = 0;
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordSeconds++;
          });
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class Recording Started.'), backgroundColor: Colors.red),
      );
    } else {
      _recordTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Class Recording Saved (Duration: ${_formatDuration(_recordSeconds)}).'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isCameraOn ? 'Camera Enabled' : 'Camera Disabled'),
        backgroundColor: _isCameraOn ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleMic() {
    setState(() {
      _isMicOn = !_isMicOn;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isMicOn ? 'Microphone Enabled' : 'Microphone Muted'),
        backgroundColor: _isMicOn ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _uploadMaterial() {
    setState(() {
      _studyMaterials.add('ReferencePaper_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}.pdf');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mock Study Material Uploaded Successfully!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Live Stream Video Container (Mock)
            Container(
              height: 200.0,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.live_tv, size: 50.0, color: const Color(0xFFEF4444).withValues(alpha: 0.8)),
                        const SizedBox(height: 8.0),
                        Text(
                          'Streaming live lecture by ${widget.hostName}',
                          style: const TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12.0,
                    left: 12.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(6.0)),
                      child: const Row(
                        children: [
                          Icon(Icons.fiber_manual_record, size: 10.0, color: Colors.white),
                          SizedBox(width: 4.0),
                          Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9.0, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  
                  // Camera/Mic status indicators
                  Positioned(
                    top: 12.0,
                    left: 70.0,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Icon(
                            _isCameraOn ? Icons.videocam : Icons.videocam_off,
                            color: _isCameraOn ? Colors.green : Colors.red,
                            size: 12.0,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Icon(
                            _isMicOn ? Icons.mic : Icons.mic_off,
                            color: _isMicOn ? Colors.green : Colors.red,
                            size: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_isRecording)
                    Positioned(
                      top: 12.0,
                      right: 12.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(6.0)),
                        child: Row(
                          children: [
                            const Icon(Icons.radio_button_checked, size: 10.0, color: Colors.red),
                            const SizedBox(width: 4.0),
                            Text(
                              'REC ${_formatDuration(_recordSeconds)}',
                              style: const TextStyle(color: Colors.white, fontSize: 9.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 12.0,
                    right: 12.0,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(_isRecording ? Icons.stop_circle : Icons.radio_button_checked, color: _isRecording ? Colors.red : Colors.white),
                          onPressed: _toggleRecording,
                          tooltip: 'Toggle Record',
                        ),
                        IconButton(
                          icon: Icon(_isCameraOn ? Icons.videocam : Icons.videocam_off, color: _isCameraOn ? Colors.white : Colors.red),
                          onPressed: _toggleCamera,
                          tooltip: 'Toggle Camera',
                        ),
                        IconButton(
                          icon: Icon(_isMicOn ? Icons.mic : Icons.mic_off, color: _isMicOn ? Colors.white : Colors.red),
                          onPressed: _toggleMic,
                          tooltip: 'Toggle Mic',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tabs: Chat vs Materials
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Group Chat'),
                        Tab(text: 'Study Materials'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tab 1: Group Chat Panel
                          Column(
                            children: [
                              Expanded(
                                child: _chatMessages.isEmpty
                                    ? const Center(child: Text('Live Group Chat started...', style: TextStyle(color: Colors.grey)))
                                    : ListView.builder(
                                        controller: _scrollCtrl,
                                        padding: const EdgeInsets.all(16.0),
                                        itemCount: _chatMessages.length,
                                        itemBuilder: (context, index) {
                                          final msg = _chatMessages[index];
                                          final isSelf = msg['sender'] == 'You';
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 10.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${msg['sender']}: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12.0,
                                                    color: isSelf ? theme.colorScheme.primary : Colors.grey[600],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    msg['text']!,
                                                    style: const TextStyle(fontSize: 13.0),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 16.0, top: 8.0),
                                child: NeumorphicContainer(
                                  borderRadius: 24.0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _msgCtrl,
                                          style: TextStyle(color: theme.colorScheme.onSurface),
                                          decoration: const InputDecoration(
                                            hintText: 'Type your message to the class...',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                          ),
                                          onSubmitted: (_) => _sendMessage(),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      NeumorphicContainer(
                                        borderRadius: 20.0,
                                        color: theme.colorScheme.primary,
                                        onTap: _sendMessage,
                                        padding: const EdgeInsets.all(10.0),
                                        child: const Icon(Icons.send, color: Colors.white, size: 18.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Tab 2: Study Materials
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Learning Materials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                    NeumorphicContainer(
                                      borderRadius: 12.0,
                                      onTap: _uploadMaterial,
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.upload_file, color: theme.colorScheme.primary, size: 18.0),
                                          const SizedBox(width: 4.0),
                                          Text('Upload', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 12.0)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12.0),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _studyMaterials.length,
                                    itemBuilder: (context, index) {
                                      final doc = _studyMaterials[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: NeumorphicContainer(
                                          borderRadius: 14.0,
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                            title: Text(doc, style: const TextStyle(fontSize: 13.0)),
                                            trailing: Icon(Icons.download, color: theme.colorScheme.primary),
                                            onTap: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Downloading $doc...'), backgroundColor: Colors.blue),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
}
