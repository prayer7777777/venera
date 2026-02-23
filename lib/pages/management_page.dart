import 'package:flutter/material.dart';
import 'package:venera/components/components.dart';
import 'package:venera/foundation/app.dart';
import 'package:venera/pages/categories_page.dart';
import 'package:venera/pages/comic_source_page.dart';
import 'package:venera/pages/downloading_page.dart';
import 'package:venera/pages/follow_updates_page.dart';
import 'package:venera/pages/history_page.dart';
import 'package:venera/pages/local_comics_page.dart';
import 'package:venera/pages/settings/settings_page.dart';
import 'package:venera/utils/translations.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SmoothCustomScrollView(
        slivers: [
          SliverPadding(padding: EdgeInsets.only(top: context.padding.top)),
          _Header(title: "Manage".tl),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid.extent(
              maxCrossAxisExtent: 220,
              childAspectRatio: 1.6,
              children: [
                _EntryCard(
                  title: "Categories".tl,
                  icon: Icons.category_outlined,
                  onTap: () => context.to(() => const CategoriesPage()),
                ),
                _EntryCard(
                  title: "Follow Updates".tl,
                  icon: Icons.update_outlined,
                  onTap: () => context.to(() => FollowUpdatesPage()),
                ),
                _EntryCard(
                  title: "Comic Source".tl,
                  icon: Icons.extension_outlined,
                  onTap: () => context.to(() => const ComicSourcePage()),
                ),
                _EntryCard(
                  title: "History".tl,
                  icon: Icons.history,
                  onTap: () => context.to(() => const HistoryPage()),
                ),
                _EntryCard(
                  title: "Local Comics".tl,
                  icon: Icons.folder_outlined,
                  onTap: () => context.to(() => const LocalComicsPage()),
                ),
                _EntryCard(
                  title: "Downloads".tl,
                  icon: Icons.download_outlined,
                  onTap: () => showPopUpWidget(context, const DownloadingPage()),
                ),
                _EntryCard(
                  title: "Settings".tl,
                  icon: Icons.settings_outlined,
                  onTap: () => context.to(() => const SettingsPage()),
                ),
              ],
            ),
          ),
          SliverPadding(padding: EdgeInsets.only(bottom: context.padding.bottom)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(title, style: ts.s20),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
