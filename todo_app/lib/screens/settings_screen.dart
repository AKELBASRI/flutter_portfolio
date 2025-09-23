import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/todo_provider.dart';
import '../utils/constants.dart';

/// Settings screen with theme controls and app management options
///
/// PORTFOLIO NOTE: This screen demonstrates settings UI design,
/// theme switching functionality, and clean settings layout -
/// good for showing app configuration and user preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildThemeSection(),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _buildDataSection(),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _buildAboutSection(),
                        const SizedBox(height: AppConstants.paddingXLarge),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the sliver app bar with gradient background
  Widget _buildSliverAppBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Settings'),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer,
                colorScheme.tertiaryContainer,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.settings,
                    size: 48,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Customize Your Experience',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the theme settings section
  Widget _buildThemeSection() {
    return _buildSection(
      title: 'Appearance',
      icon: Icons.palette,
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Column(
              children: [
                _buildThemeOption(
                  'Light Theme',
                  'Use light colors',
                  Icons.light_mode,
                  themeProvider.isLightMode,
                  () => themeProvider.setLightTheme(),
                ),
                _buildThemeOption(
                  'Dark Theme',
                  'Use dark colors',
                  Icons.dark_mode,
                  themeProvider.isDarkMode,
                  () => themeProvider.setDarkTheme(),
                ),
                _buildThemeOption(
                  'System Theme',
                  'Follow device settings',
                  Icons.brightness_auto,
                  themeProvider.isSystemMode,
                  () => themeProvider.setSystemTheme(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Builds a theme option tile
  Widget _buildThemeOption(
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: AppConstants.animationFast,
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: colorScheme.primary,
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }

  /// Builds the data management section
  Widget _buildDataSection() {
    return _buildSection(
      title: 'Data Management',
      icon: Icons.storage,
      children: [
        Consumer<TodoProvider>(
          builder: (context, todoProvider, child) {
            final stats = todoProvider.getStatistics();

            return Column(
              children: [
                _buildDataInfo(
                  'Total Tasks',
                  '${stats['total']} tasks stored locally',
                  Icons.assignment,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildActionTile(
                  'Clear All Data',
                  'Delete all todos permanently',
                  Icons.delete_forever,
                  Colors.red,
                  stats['total']! > 0 ? () => _showClearDataDialog() : null,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Builds a data information tile
  Widget _buildDataInfo(String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an action tile
  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color? iconColor,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: onTap == null
              ? colorScheme.onSurface.withOpacity(0.5)
              : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right)
          : null,
      onTap: onTap,
      enabled: onTap != null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
    );
  }

  /// Builds the about section
  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About',
      icon: Icons.info,
      children: [
        _buildInfoTile(
          'App Version',
          AppConstants.appVersion,
          Icons.update,
        ),
        _buildInfoTile(
          'Developer',
          'Flutter Todo App',
          Icons.code,
        ),
        _buildInfoTile(
          'Framework',
          'Flutter with Material Design 3',
          Icons.flutter_dash,
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        _buildFeaturesList(),
      ],
    );
  }

  /// Builds an information tile
  Widget _buildInfoTile(String title, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppConstants.iconSizeSmall,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the features list
  Widget _buildFeaturesList() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final features = [
      'CRUD operations for todos',
      'Category-based organization',
      'Search functionality',
      'Dark/Light theme support',
      'Local data storage',
      'Statistics and analytics',
      'Material Design 3 UI',
      'Smooth animations',
    ];

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Text(
                    feature,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// Builds a section with title and children
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppConstants.paddingMedium,
              right: AppConstants.paddingMedium,
              bottom: AppConstants.paddingMedium,
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows confirmation dialog for clearing all data
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'Are you sure you want to delete all todos? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllData();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  /// Clears all todo data
  Future<void> _clearAllData() async {
    try {
      await context.read<TodoProvider>().clearAllTodos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All todos have been deleted'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}