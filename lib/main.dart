
import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

// -----------------------------------------------------------------------------
// DEVICE PREVIEW CONFIGURATION
// -----------------------------------------------------------------------------

const Size desktopSize = Size(1440, 900);
const Size tabletSize = Size(768, 1024);
const Size mobileSize = Size(390, 844);

final ValueNotifier<Size?> previewSize = ValueNotifier<Size?>(null);

enum PreviewChoice {
  desktop,
  tablet,
  mobile,
  actualViewport,
}

// -----------------------------------------------------------------------------
// APP
// -----------------------------------------------------------------------------

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  ThemeMode themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      themeMode =
      themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      themeMode: themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: TodoHomePage(
        themeMode: themeMode,
        onToggleTheme: toggleTheme,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    const background = Color(0xFFF5F7FB);
    const primary = Color(0xFF6558F5);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const background = Color(0xFF11131A);
    const surface = Color(0xFF1B1E28);
    const primary = Color(0xFF9A90FF);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252936),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TODO MODEL
// -----------------------------------------------------------------------------

class Todo {
  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final int id;
  final String title;
  bool isCompleted;
}

enum TodoFilter { all, active, completed }

// -----------------------------------------------------------------------------
// HOME PAGE
// -----------------------------------------------------------------------------

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<Todo> todos = [];
  final TextEditingController todoController = TextEditingController();

  TodoFilter currentFilter = TodoFilter.all;
  int nextId = 1;

  bool get isDark => widget.themeMode == ThemeMode.dark;

  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }

  void addTodo() {
    final title = todoController.text.trim();

    if (title.isEmpty) return;

    setState(() {
      todos.insert(
        0,
        Todo(
          id: nextId++,
          title: title,
        ),
      );
      currentFilter = TodoFilter.all;
    });

    todoController.clear();
    FocusScope.of(context).unfocus();
  }

  void toggleTodo(Todo todo, bool completed) {
    setState(() {
      todo.isCompleted = completed;
    });
  }

  void deleteTodo(Todo todo) {
    final oldIndex = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Task deleted'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              setState(() {
                todos.insert(
                  oldIndex.clamp(0, todos.length),
                  todo,
                );
              });
            },
          ),
        ),
      );
  }

  List<Todo> get filteredTodos {
    switch (currentFilter) {
      case TodoFilter.active:
        return todos.where((todo) => !todo.isCompleted).toList();
      case TodoFilter.completed:
        return todos.where((todo) => todo.isCompleted).toList();
      case TodoFilter.all:
        return List<Todo>.from(todos);
    }
  }

  int get completedCount => todos.where((todo) => todo.isCompleted).length;

  int get activeCount => todos.length - completedCount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Size?>(
      valueListenable: previewSize,
      builder: (context, selectedSize, _) {
        if (selectedSize == null) {
          return _buildScaffold(context);
        }

        // Rebuild the page using the selected device's simulated viewport.
        // TodoHomePage itself remains mounted, so the task list is preserved.
        return _PreviewStage(
          size: selectedSize,
          onToggleTheme: widget.onToggleTheme,
          themeMode: widget.themeMode,
          childBuilder: (previewContext) {
            return _buildScaffold(previewContext);
          },
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 1100;
    final isCompact = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: isCompact ? 18 : 32,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF6558F5),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TaskFlow',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                Text(
                  'YOUR DAY, ORGANIZED',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: widget.onToggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: 8),
            DevicePreviewToggle(
              isDark: isDark,
              compact: false,
            ),
            const SizedBox(width: 28),
          ] else
            const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 18 : 32,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcome(context, isCompact),
                  const SizedBox(height: 24),
                  _buildStats(context, isCompact),
                  const SizedBox(height: 28),
                  _buildInput(context, isCompact),
                  const SizedBox(height: 24),
                  _buildFilters(context, isCompact),
                  const SizedBox(height: 14),
                  Expanded(child: _buildTodoList(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good things start here.',
          style: TextStyle(
            fontSize: isCompact ? 27 : 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.1,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Make a little progress every day.',
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, bool isCompact) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total tasks',
            value: '${todos.length}',
            icon: Icons.checklist_rounded,
            color: const Color(0xFF6558F5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'In progress',
            value: '$activeCount',
            icon: Icons.pending_actions_rounded,
            color: const Color(0xFFEA9B38),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Completed',
            value: '$completedCount',
            icon: Icons.task_alt_rounded,
            color: const Color(0xFF24A879),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(BuildContext context, bool isCompact) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.035),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(
            Icons.add_circle_outline_rounded,
            color: Color(0xFF6558F5),
            size: 25,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: todoController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => addTodo(),
              decoration: const InputDecoration(
                hintText: 'What would you like to get done?',
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: addTodo,
            icon: const Icon(Icons.add_rounded, size: 19),
            label: Text(isCompact ? 'Add' : 'Add task'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6558F5),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 13 : 20,
                vertical: 17,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, bool isCompact) {
    return Row(
      children: [
        Text(
          'YOUR TASKS',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        for (final filter in TodoFilter.values)
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: _FilterChip(
              label: switch (filter) {
                TodoFilter.all => 'All',
                TodoFilter.active => 'Active',
                TodoFilter.completed => 'Done',
              },
              selected: currentFilter == filter,
              compact: isCompact,
              onTap: () {
                setState(() {
                  currentFilter = filter;
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTodoList(BuildContext context) {
    final items = filteredTodos;

    if (items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6558F5).withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.task_alt_rounded,
                    size: 42,
                    color: Color(0xFF6558F5),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  todos.isEmpty ? 'A clean slate!' : 'Nothing here yet',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  todos.isEmpty
                      ? 'Add your first task and get things moving.'
                      : 'Try another filter to see your tasks.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 20, top: 2),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final todo = items[index];

        return _TodoCard(
          todo: todo,
          onChanged: (value) => toggleTodo(todo, value),
          onDelete: () => deleteTodo(todo),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// STATISTICS CARD
// -----------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 400;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 17),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: color),
              const Spacer(),
              if (!compact)
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            value,
            style: TextStyle(
              fontSize: compact ? 23 : 29,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// FILTER CHIP
// -----------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFF6558F5)
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 11 : 17,
            vertical: 10,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TODO CARD
// -----------------------------------------------------------------------------

class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.todo,
    required this.onChanged,
    required this.onDelete,
  });

  final Todo todo;
  final ValueChanged<bool> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: todo.isCompleted,
            onChanged: (value) => onChanged(value ?? false),
            activeColor: const Color(0xFF6558F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: todo.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: todo.isCompleted ? muted : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      todo.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 12,
                      color: todo.isCompleted
                          ? const Color(0xFF24A879)
                          : muted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      todo.isCompleted ? 'Completed' : 'In progress',
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete task',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: muted,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DEVICE PREVIEW SELECTOR
// -----------------------------------------------------------------------------

class DevicePreviewToggle extends StatelessWidget {
  const DevicePreviewToggle({
    super.key,
    required this.isDark,
    this.compact = true,
  });

  final bool isDark;
  final bool compact;

  void _selectPreview(PreviewChoice choice) {
    // Actual Viewport deliberately uses a non-null enum value.
    // This ensures PopupMenuButton calls onSelected reliably.
    switch (choice) {
      case PreviewChoice.desktop:
        previewSize.value = desktopSize;
      case PreviewChoice.tablet:
        previewSize.value = tabletSize;
      case PreviewChoice.mobile:
        previewSize.value = mobileSize;
      case PreviewChoice.actualViewport:
        previewSize.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PreviewChoice>(
      tooltip: 'Preview device sizes',
      onSelected: _selectPreview,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: PreviewChoice.desktop,
          child: _PreviewMenuItem(
            icon: Icons.desktop_windows_rounded,
            title: 'Desktop preview',
            subtitle: '1440 × 900',
          ),
        ),
        PopupMenuItem(
          value: PreviewChoice.tablet,
          child: _PreviewMenuItem(
            icon: Icons.tablet_mac_rounded,
            title: 'Tablet preview',
            subtitle: '768 × 1024',
          ),
        ),
        PopupMenuItem(
          value: PreviewChoice.mobile,
          child: _PreviewMenuItem(
            icon: Icons.phone_iphone_rounded,
            title: 'Mobile preview',
            subtitle: '390 × 844',
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: PreviewChoice.actualViewport,
          child: _PreviewMenuItem(
            icon: Icons.fullscreen_rounded,
            title: 'Actual viewport',
            subtitle: 'Return to your real screen',
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252936) : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.devices_rounded,
              size: 19,
              color: Color(0xFF6558F5),
            ),
            if (!compact) ...[
              const SizedBox(width: 9),
              const Text(
                'Preview',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreviewMenuItem extends StatelessWidget {
  const _PreviewMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF6558F5).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.devices_rounded,
              size: 19,
              color: Color(0xFF6558F5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PREVIEW STAGE
// -----------------------------------------------------------------------------

class _PreviewStage extends StatelessWidget {
  const _PreviewStage({
    required this.size,
    required this.childBuilder,
    required this.onToggleTheme,
    required this.themeMode,
  });

  final Size size;
  final WidgetBuilder childBuilder;
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  bool get isMobile => size == mobileSize;
  bool get isTablet => size == tabletSize;
  bool get isDesktop => size == desktopSize;

  String get deviceName {
    if (isMobile) return 'Mobile preview';
    if (isTablet) return 'Tablet preview';
    return 'Desktop preview';
  }

  @override
  Widget build(BuildContext context) {
    final dark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: dark
          ? const Color(0xFF101117)
          : const Color(0xFFEAECF3),
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(
              painter: _PreviewBackdropPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // The selector stays in this toolbar, ABOVE and AWAY from
                // the device frame. It is never placed inside the mockup.
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6558F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.devices_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deviceName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: dark
                                    ? Colors.white
                                    : const Color(0xFF202230),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${size.width.toInt()} × ${size.height.toInt()} · Simulated viewport',
                              style: TextStyle(
                                fontSize: 11,
                                color: dark
                                    ? Colors.white60
                                    : const Color(0xFF74788B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: dark ? 'Switch to light mode' : 'Switch to dark mode',
                        onPressed: onToggleTheme,
                        icon: Icon(
                          dark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: dark
                              ? Colors.white
                              : const Color(0xFF33364A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DevicePreviewToggle(
                        isDark: dark,
                        compact: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final deviceFrame = _DeviceFrame(
                        size: size,
                        isMobile: isMobile,
                        isTablet: isTablet,
                        isDesktop: isDesktop,
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(size: size),
                          child: SizedBox(
                            width: size.width,
                            height: size.height,
                            child: Builder(builder: childBuilder),
                          ),
                        ),
                      );

                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                          // FittedBox scales the complete device frame once.
                          // The actual app still receives the chosen viewport.
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: deviceFrame,
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
    );
  }
}

// -----------------------------------------------------------------------------
// DEVICE MOCKUP FRAME
// -----------------------------------------------------------------------------

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({
    required this.size,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.child,
  });

  final Size size;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = isMobile ? 42.0 : (isTablet ? 29.0 : 16.0);
    final bezel = isDesktop ? 13.0 : (isTablet ? 13.0 : 11.0);

    final frame = Container(
      padding: EdgeInsets.all(bezel),
      decoration: BoxDecoration(
        color: const Color(0xFF17181E),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: const Color(0xFF393B45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 55,
            offset: const Offset(0, 28),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - bezel),
        child: Stack(
          children: [
            SizedBox(
              width: size.width,
              height: size.height,
              child: child,
            ),
            if (isMobile)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 105,
                    height: 23,
                    decoration: const BoxDecoration(
                      color: Color(0xFF17181E),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            if (isTablet)
              Positioned(
                top: 5,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF555762),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (!isDesktop) return frame;

    // Simple monitor stand to make desktop preview look like a real monitor.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        frame,
        Container(
          width: size.width * 0.18,
          height: 34,
          decoration: const BoxDecoration(
            color: Color(0xFF292B34),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(7),
            ),
          ),
        ),
        Container(
          width: size.width * 0.32,
          height: 13,
          decoration: BoxDecoration(
            color: const Color(0xFF383A44),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// PREVIEW BACKGROUND
// -----------------------------------------------------------------------------

class _PreviewBackdropPainter extends CustomPainter {
  const _PreviewBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFF777B95).withValues(alpha: 0.12);

    const gap = 26.0;

    for (double x = 12; x < size.width; x += gap) {
      for (double y = 12; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.1, dotPaint);
      }
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6558F5).withValues(alpha: 0.10),
          const Color(0xFF6558F5).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.53),
          radius: size.shortestSide * 0.6,
        ),
      );

    canvas.drawRect(Offset.zero & size, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
