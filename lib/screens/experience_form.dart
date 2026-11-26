import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_list.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Form page for adding a new experience to the portfolio.
///
/// The fields follow the Experience model of the Django website.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _description = "";
  String _category = "full-time"; // default, same as the Django model
  String _thumbnail = "";
  DateTime? _endDate;
  bool _isSubmitting = false;

  final _endController = TextEditingController();

  @override
  void dispose() {
    _endController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "${date.year}-$month-$day";
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      // Django sets the start date to today, so the end can't be earlier.
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      // End of the chosen day, so it is never before the start time.
      _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      _endController.text = _formatDate(picked);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final auth = context.read<AuthState>();
    final apiClient = context.read<ApiClient>();
    final newExperience = Experience(
      title: _title.trim(),
      description: _description.trim(),
      category: _category,
      thumbnail: _thumbnail.trim(),
      endedAt: _endDate?.toUtc(),
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final created = await apiClient.createExperience(
        newExperience,
        token: auth.token!,
      );
      if (!mounted) return;
      await _showSuccess(created);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        await auth.logout();
        if (!mounted) return;
        _showError('Your session ended. Log in, then press Save again.');
        await ensureLoggedIn(context);
      } else if (e.statusCode == 403) {
        _showError('Your account is not allowed to add experience.');
      } else {
        _showError('Could not save the experience (${e.statusCode}).');
      }
    } catch (_) {
      if (!mounted) return;
      _showError('Could not reach the server.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showSuccess(Experience experience) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Experience added successfully!'),
          content: Text('Title: ${experience.title}'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    // Open a fresh list so the new entry shows up.
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ExperienceListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Experience Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Experience Title",
                    labelText: "Experience Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _title = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter an experience title.";
                    }
                    if (value.trim().length > 255) {
                      return "Title can be at most 255 characters.";
                    }
                    return null;
                  },
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Experience Description",
                    labelText: "Experience Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _description = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter an experience description.";
                    }
                    return null;
                  },
                ),
              ),

              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Experience Category",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  initialValue: _category,
                  items: experienceCategories.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                ),
              ),

              // === Thumbnail URL ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText: "https://example.com/photo.jpg (optional)",
                    labelText: "Experience Thumbnail URL",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _thumbnail = value!;
                    });
                  },
                  validator: (String? value) {
                    // The thumbnail is optional, like in the Django model.
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }
                    final uri = Uri.tryParse(value.trim());
                    final isValid =
                        uri != null &&
                        (uri.scheme == 'http' || uri.scheme == 'https') &&
                        uri.host.isNotEmpty;
                    if (!isValid) {
                      return "Enter a valid URL starting with http:// or https://";
                    }
                    return null;
                  },
                ),
              ),

              // === End Date (optional) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _endController,
                  readOnly: true,
                  onTap: _pickEndDate,
                  decoration: InputDecoration(
                    hintText: "Tap to pick a date (empty = ongoing)",
                    labelText: "End Date",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _endDate = null;
                          _endController.clear();
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),

              // === Save Button ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
