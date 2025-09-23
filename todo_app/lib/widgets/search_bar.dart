import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/constants.dart';

/// Custom search bar widget with debounced search functionality
///
/// This widget provides a beautiful search interface with smooth animations,
/// debounced input handling, and proper accessibility features
class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onSearchChanged;
  final String initialValue;
  final bool autofocus;
  final Duration debounceDelay;

  const CustomSearchBar({
    super.key,
    this.hintText = AppConstants.searchHintText,
    required this.onSearchChanged,
    this.initialValue = '',
    this.autofocus = false,
    this.debounceDelay = AppConstants.searchDebounceDelay,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _hasText = widget.initialValue.isNotEmpty;

    _animationController = AnimationController(
      duration: AppConstants.animationFast,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (_hasText) {
      _animationController.forward();
    }

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      if (hasText) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer
    _debounceTimer = Timer(widget.debounceDelay, () {
      widget.onSearchChanged(_controller.text);
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: AnimatedSwitcher(
            duration: AppConstants.animationFast,
            child: Icon(
              Icons.search,
              key: const ValueKey('search_icon'),
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          suffixIcon: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: IconButton(
                  onPressed: _hasText ? _clearSearch : null,
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear search',
                ),
              );
            },
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingMedium,
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => widget.onSearchChanged(value),
      ),
    );
  }
}

/// Expandable search bar that can be collapsed/expanded
///
/// This widget provides a compact search button that expands into a full search bar
/// when tapped, perfect for app bars and compact layouts
class ExpandableSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String hintText;
  final Duration animationDuration;

  const ExpandableSearchBar({
    super.key,
    required this.onSearchChanged,
    this.hintText = AppConstants.searchHintText,
    this.animationDuration = AppConstants.animationMedium,
  });

  @override
  State<ExpandableSearchBar> createState() => _ExpandableSearchBarState();
}

class _ExpandableSearchBarState extends State<ExpandableSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  late TextEditingController _controller;
  bool _isExpanded = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.searchDebounceDelay, () {
      widget.onSearchChanged(_controller.text);
    });
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      _controller.clear();
      widget.onSearchChanged('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Container(
          width: _isExpanded
              ? MediaQuery.of(context).size.width - (AppConstants.paddingMedium * 2)
              : 48,
          height: 48,
          child: Stack(
            children: [
              // Search field (when expanded)
              if (_isExpanded)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: _toggleSearch,
                        icon: const Icon(Icons.close),
                        tooltip: 'Close search',
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                        vertical: AppConstants.paddingSmall,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) => widget.onSearchChanged(value),
                  ),
                ),

              // Search button (when collapsed)
              if (!_isExpanded)
                Positioned(
                  right: 0,
                  child: IconButton(
                    onPressed: _toggleSearch,
                    icon: const Icon(Icons.search),
                    tooltip: 'Search todos',
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Search suggestions widget
///
/// This widget displays search suggestions based on previous searches
/// or common search terms
class SearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTapped;

  const SearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
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
            child: Text(
              'Suggestions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          ...suggestions.map((suggestion) {
            return ListTile(
              leading: Icon(
                Icons.search,
                size: AppConstants.iconSizeSmall,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              title: Text(suggestion),
              onTap: () => onSuggestionTapped(suggestion),
              dense: true,
            );
          }),
        ],
      ),
    );
  }
}