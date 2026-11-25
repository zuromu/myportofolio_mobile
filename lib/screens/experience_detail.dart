import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';

/// Shows all the fields of one [Experience].
class ExperienceDetailPage extends StatelessWidget {
  const ExperienceDetailPage({required this.experience, super.key});

  final Experience experience;

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final startedAt = experience.startedAt;
    final endedAt = experience.endedAt;
    final category =
        experienceCategories[experience.category] ?? experience.category;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Experience Detail'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              experience.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Category: $category'),
            Text(
              'Started: ${startedAt == null ? '-' : _formatDate(startedAt)}',
            ),
            Text(
              'Ended: ${endedAt == null ? 'Ongoing' : _formatDate(endedAt)}',
            ),
            const SizedBox(height: 16),
            Text(experience.description),
            if (experience.thumbnail.isNotEmpty) ...[
              const SizedBox(height: 16),
              SelectableText('Thumbnail: ${experience.thumbnail}'),
            ],
          ],
        ),
      ),
    );
  }
}
