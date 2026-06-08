import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form values
  String _name = "";
  String _role = "";
  String _email = "";
  String _skills = "";
  String _education = "";

  // Dynamic Lists for Projects and Experiences
  final List<Map<String, TextEditingController>> _projectControllers = [];
  final List<TextEditingController> _experienceControllers = [];

  // Template settings
  String _selectedTemplate = "Default Slate"; // Default Slate, Emerald Glow, Sunset Neon

  @override
  void initState() {
    super.initState();
    _addProjectField();
    _addExperienceField();
  }

  @override
  void dispose() {
    for (var p in _projectControllers) {
      p['title']?.dispose();
      p['desc']?.dispose();
    }
    for (var e in _experienceControllers) {
      e.dispose();
    }
    super.dispose();
  }

  void _addProjectField() {
    setState(() {
      _projectControllers.add({
        'title': TextEditingController(),
        'desc': TextEditingController(),
      });
    });
  }

  void _removeProjectField(int index) {
    if (_projectControllers.length > 1) {
      setState(() {
        final removed = _projectControllers.removeAt(index);
        removed['title']?.dispose();
        removed['desc']?.dispose();
      });
    }
  }

  void _addExperienceField() {
    setState(() {
      _experienceControllers.add(TextEditingController());
    });
  }

  void _removeExperienceField(int index) {
    if (_experienceControllers.length > 1) {
      setState(() {
        final removed = _experienceControllers.removeAt(index);
        removed.dispose();
      });
    }
  }

  void _saveResumeToFileLocally(Map<String, dynamic> data) {
    try {
      final name = data['name'] ?? 'Resume';
      final cleanedName = name.replaceAll(RegExp(r'[^\w\s\-]'), '').replaceAll(' ', '_');
      
      final content = StringBuffer();
      content.writeln("==================================================");
      content.writeln("             ${data['name']?.toUpperCase()}");
      content.writeln("             ${data['role']}");
      content.writeln("==================================================");
      content.writeln("Email: ${data['email']}");
      content.writeln("Timestamp: ${data['timestamp']}");
      content.writeln("\n--------------------------------------------------");
      content.writeln("TECHNICAL SKILLS");
      content.writeln("--------------------------------------------------");
      content.writeln(data['skills']);
      
      content.writeln("\n--------------------------------------------------");
      content.writeln("KEY PROJECTS");
      content.writeln("--------------------------------------------------");
      final projects = data['projects'] as List?;
      if (projects != null && projects.isNotEmpty) {
        for (var i = 0; i < projects.length; i++) {
          final p = Map<String, dynamic>.from(projects[i] as Map);
          content.writeln("${i + 1}. ${p['title']}");
          content.writeln("   ${p['desc']}\n");
        }
      } else {
        content.writeln("Project: ${data['projectTitle']}");
        content.writeln("Description: ${data['projectDesc']}");
      }
      
      content.writeln("--------------------------------------------------");
      content.writeln("WORK EXPERIENCE");
      content.writeln("--------------------------------------------------");
      final experiences = data['experiences'] as List?;
      if (experiences != null && experiences.isNotEmpty) {
        for (var i = 0; i < experiences.length; i++) {
          content.writeln("- ${experiences[i]}");
        }
      } else {
        content.writeln(data['experience']);
      }
      
      content.writeln("\n--------------------------------------------------");
      content.writeln("EDUCATION");
      content.writeln("--------------------------------------------------");
      content.writeln(data['education']);
      content.writeln("==================================================");

      final dir = Directory('${Directory.current.path}/output_resumes');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final file = File('${dir.path}/${cleanedName}_resume.txt');
      file.writeAsStringSync(content.toString());
      debugPrint("Resume output file written successfully to ${file.path}");
    } catch (e) {
      debugPrint("Error writing resume file: $e");
    }
  }

  void _generateResume() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final appState = Provider.of<AppState>(context, listen: false);
    
    // Collect projects
    final projectsList = _projectControllers.map((p) {
      return {
        'title': p['title']!.text.trim(),
        'desc': p['desc']!.text.trim(),
      };
    }).toList();

    // Collect experiences
    final experiencesList = _experienceControllers.map((e) => e.text.trim()).toList();

    final resumeData = {
      'name': _name,
      'role': _role,
      'email': _email,
      'skills': _skills,
      'projectTitle': projectsList.isNotEmpty ? projectsList[0]['title'] : '',
      'projectDesc': projectsList.isNotEmpty ? projectsList[0]['desc'] : '',
      'experience': experiencesList.isNotEmpty ? experiencesList[0] : 'Fresh Graduate',
      'projects': projectsList,
      'experiences': experiencesList,
      'education': _education,
      'template': _selectedTemplate,
      'timestamp': DateTime.now().toLocal().toString().split('.')[0],
    };

    appState.saveResume(resumeData);
    _saveResumeToFileLocally(resumeData);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Resume compiled and downloaded locally to 'output_resumes'!"),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("📝 Resume Builder Wizard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left input form panel
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter Profile Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _buildInputDeco("Full Name", Icons.person),
                      style: const TextStyle(color: Colors.white),
                      validator: (val) => val == null || val.isEmpty ? "Name is required" : null,
                      onSaved: (val) => _name = val ?? "",
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: _buildInputDeco("Target Professional Role (e.g. Software Engineer)", Icons.badge),
                      style: const TextStyle(color: Colors.white),
                      validator: (val) => val == null || val.isEmpty ? "Role is required" : null,
                      onSaved: (val) => _role = val ?? "",
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: _buildInputDeco("Email Address", Icons.email),
                      style: const TextStyle(color: Colors.white),
                      validator: (val) => val == null || !val.contains('@') ? "Valid email is required" : null,
                      onSaved: (val) => _email = val ?? "",
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: _buildInputDeco("Skills (e.g. Flutter, Dart, Java, SQL)", Icons.psychology),
                      style: const TextStyle(color: Colors.white),
                      validator: (val) => val == null || val.isEmpty ? "Skills are required" : null,
                      onSaved: (val) => _skills = val ?? "",
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Key Projects",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                        ),
                        TextButton.icon(
                          onPressed: _addProjectField,
                          icon: const Icon(Icons.add, size: 16, color: AppColors.secondary),
                          label: const Text("Add", style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_projectControllers.length, (index) {
                      final pController = _projectControllers[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Project #${index + 1}", style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                if (_projectControllers.length > 1)
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete, color: AppColors.accentPink, size: 16),
                                    onPressed: () => _removeProjectField(index),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: pController['title'],
                              decoration: _buildInputDeco("Project Title", Icons.folder),
                              style: const TextStyle(color: Colors.white),
                              validator: (val) => val == null || val.isEmpty ? "Project title is required" : null,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: pController['desc'],
                              decoration: _buildInputDeco("Project Description / Achievements", Icons.description),
                              style: const TextStyle(color: Colors.white),
                              maxLines: 2,
                              validator: (val) => val == null || val.isEmpty ? "Project description is required" : null,
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Work/Internship Experience",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                        ),
                        TextButton.icon(
                          onPressed: _addExperienceField,
                          icon: const Icon(Icons.add, size: 16, color: AppColors.secondary),
                          label: const Text("Add", style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_experienceControllers.length, (index) {
                      final eController = _experienceControllers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: eController,
                                decoration: _buildInputDeco("Experience #${index + 1}", Icons.work),
                                style: const TextStyle(color: Colors.white),
                                validator: (val) => val == null || val.isEmpty ? "Experience entry is required" : null,
                              ),
                            ),
                            if (_experienceControllers.length > 1) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.accentPink, size: 20),
                                onPressed: () => _removeExperienceField(index),
                              ),
                            ]
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _buildInputDeco("Education Credentials", Icons.school),
                      style: const TextStyle(color: Colors.white),
                      validator: (val) => val == null || val.isEmpty ? "Education is required" : null,
                      onSaved: (val) => _education = val ?? "",
                    ),
                    const SizedBox(height: 20),
                    const Text("Choose Visual Template", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      dropdownColor: AppColors.surface,
                      value: _selectedTemplate,
                      items: ["Default Slate", "Emerald Glow", "Sunset Neon"].map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedTemplate = val;
                          });
                        }
                      },
                      decoration: _buildInputDeco("Resume Template Theme", Icons.palette),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _generateResume,
                      child: const Text("Compile Resume Layout", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Right preview panel (for desktop layout compatibility, hidden or small on mobile)
          if (MediaQuery.of(context).size.width > 700)
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.black12,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "PREVIEW SCREEN",
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      if (appState.savedResumes.isNotEmpty)
                        _buildResumeCard(appState.savedResumes.last)
                      else
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text("Fill the form to view real-time compilation logs.", textAlign: TextAlign.center),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
      // Bottom drawer listing previously built resumes
      bottomNavigationBar: appState.savedResumes.isEmpty 
          ? null 
          : Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Generated Resumes Archive", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: appState.savedResumes.length,
                      itemBuilder: (context, index) {
                        final res = appState.savedResumes[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: ActionChip(
                            avatar: const Icon(Icons.description, size: 14, color: AppColors.primary),
                            label: Text(res['name'] ?? 'Resume'),
                            backgroundColor: AppColors.surfaceLight,
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: AppColors.surface,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (context) {
                                  return SingleChildScrollView(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildResumeCard(res),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => Navigator.of(context).pop(),
                                                icon: const Icon(Icons.download),
                                                label: const Text("Export PDF"),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: AppColors.accentPink),
                                              onPressed: () {
                                                appState.deleteResume(index);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildResumeCard(Map<String, dynamic> data) {
    Color accentColor = AppColors.primary;
    if (data['template'] == "Emerald Glow") {
      accentColor = AppColors.accentGreen;
    } else if (data['template'] == "Sunset Neon") {
      accentColor = AppColors.accentOrange;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F111E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['name'] ?? "Name",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            data['role'] ?? "Developer",
            style: TextStyle(fontSize: 13, color: accentColor, fontWeight: FontWeight.bold),
          ),
          Text(
            data['email'] ?? "email",
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const Divider(height: 20, color: AppColors.border),
          
          const Text("TECHNICAL SKILLS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(data['skills'] ?? "", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 12),

          const Text("KEY PROJECTS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          if (data['projects'] != null && data['projects'] is List)
            ...((data['projects'] as List).map((p) {
              final proj = Map<String, dynamic>.from(p as Map);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(proj['title'] ?? "", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(proj['desc'] ?? "", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              );
            }).toList())
          else ...[
            Text(data['projectTitle'] ?? "", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(data['projectDesc'] ?? "", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 12),

          const Text("WORK EXPERIENCE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          if (data['experiences'] != null && data['experiences'] is List)
            ...((data['experiences'] as List).map((exp) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text("- ${exp.toString()}", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              );
            }).toList())
          else
            Text(data['experience'] ?? "", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 12),

          const Text("EDUCATION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(data['education'] ?? "", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  InputDecoration _buildInputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
      filled: true,
      fillColor: AppColors.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
    );
  }
}
