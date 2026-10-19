# ✨ TaskFlow — Todo App

**Organize your day. Focus on what matters. Get things done.**

TaskFlow is a modern, responsive Todo application built with **Flutter and Dart**. It provides a clean interface for managing daily tasks, tracking progress, and switching between light and dark themes.

Designed to work across **mobile, tablet, desktop, and web**, TaskFlow also includes a built-in device preview mode that lets you explore how the interface looks at different screen sizes.

---

## 📸 Overview

TaskFlow combines a minimal interface with practical task management features, responsive layouts, and a polished visual design.

### Highlights

- 📝 Quickly add and manage tasks.
- ✅ Mark tasks as completed or active.
- 🗑️ Delete tasks with an undo option.
- 🌗 Switch between light and dark themes.
- 📱 Preview the interface in mobile, tablet, and desktop layouts.
- 🖥️ Run on supported desktop and web platforms.
- 📊 Track total, active, and completed tasks.
- 🔎 Filter tasks by All, Active, and Completed.
- 🎨 Enjoy a modern UI with rounded cards, subtle shadows, and consistent styling.
- 📦 Built using Flutter's built-in widgets, without additional package dependencies.

---

## 🚀 Features

### 1. Task Management

TaskFlow provides the essential tools to manage your daily to-do list.

- **Add tasks:** Enter a task and add it to your list.
- **Complete tasks:** Check off tasks when they are finished.
- **Delete tasks:** Remove tasks you no longer need.
- **Undo deletion:** Restore a recently deleted task using the Undo action.

### 2. Task Filters

Keep your list organized with three filters:

| Filter | Description |
|---|---|
| All | Displays every task. |
| Active | Displays tasks that are not completed. |
| Completed | Displays finished tasks. |

### 3. Progress Dashboard

The dashboard displays three task statistics:

- **Total Tasks** — The total number of tasks in your list.
- **In Progress** — The number of active tasks.
- **Completed** — The number of finished tasks.

These statistics update automatically as you add, complete, or delete tasks.

### 4. Light and Dark Themes

Choose the appearance that suits your environment.

- ☀️ **Light mode:** A clean, bright interface.
- 🌙 **Dark mode:** A darker interface designed for comfortable viewing in low-light environments.

Switch themes using the theme button in the application toolbar.

### 5. Responsive Design

TaskFlow adapts its layout to different screen widths, providing a usable interface on:

- 📱 Mobile phones
- 📲 Tablets
- 💻 Desktop computers
- 🌐 Web browsers

The layout adjusts spacing, typography, controls, and content width to suit the available screen space.

### 6. Interactive Device Preview

When running on a sufficiently wide screen, use the device preview control to inspect the application at different simulated viewport sizes.

| Preview | Simulated viewport |
|---|---|
| Mobile | 390 × 844 |
| Tablet | 768 × 1024 |
| Desktop | 1440 × 900 |
| Actual Viewport | Returns to the real viewport |

The preview includes device-style frames, rounded corners, shadows, and mobile or tablet details.

**Note:** Device preview is a visual testing feature. It simulates viewport dimensions inside the running application; it does not launch a separate emulator or replace testing on actual devices.

---

## 🛠️ Built With

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev/) | Cross-platform UI development |
| [Dart](https://dart.dev/) | Application programming language |
| Material 3 | UI components and theming |
| Stateful Widgets | Task management and interactive UI state |
| ValueNotifier | Communicating device preview state |
| MediaQuery | Reading and simulating viewport dimensions |
| LayoutBuilder | Building layouts based on available space |
| CustomPainter | Drawing the device preview background |

TaskFlow uses Flutter's built-in functionality and requires no third-party packages for its current features.

---

## 📂 Project Structure

The application is currently implemented in a single `main.dart` file, making it straightforward to explore and run.

```text
taskflow/
├── lib/
│   └── main.dart
├── test/
├── web/
├── windows/
├── macos/
├── linux/
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

*Note: The platform folders shown above are generated or maintained by Flutter when the corresponding platforms are enabled in the project. Your actual project may contain only some of these folders.*

---

## ⚙️ Getting Started

Follow these steps to run TaskFlow locally.

### Prerequisites

Install the following:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Android Studio](https://developer.android.com/studio), [Visual Studio Code](https://code.visualstudio.com/), or another compatible editor
- A supported emulator, physical device, or browser

Verify your Flutter installation:

```bash
flutter doctor
```

### 1. Clone the Repository

```bash
git clone https://github.com/sufyanafzal7/bigbrainsday7.git
```

```bash
cd taskflow
```

> Replace the repository URL if your GitHub repository uses a different name or URL.

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the Application

Run on your currently selected device:

```bash
flutter run
```

To see available devices:

```bash
flutter devices
```

### Run on Specific Platforms

**Android:**

```bash
flutter run -d android
```

**Chrome:**

```bash
flutter run -d chrome
```

**Windows:**

```bash
flutter run -d windows
```

**macOS:**

```bash
flutter run -d macos
```

**Linux:**

```bash
flutter run -d linux
```

Platform-specific prerequisites apply. For example, Windows desktop builds require the appropriate Visual Studio C++ desktop development tools.

---

## 🧪 How to Use

1. Launch TaskFlow.
2. Enter a task in the input field.
3. Select **Add task** or press Enter.
4. Use the checkbox to mark a task as completed.
5. Switch between All, Active, and Completed filters.
6. Delete a task using its delete icon; choose **Undo** if you want to restore it.
7. Use the theme button to switch between light and dark modes.
8. On a wide screen, open the device preview menu to inspect mobile, tablet, or desktop layouts.
9. Select **Actual viewport** to return to the real screen size.

---

## 🧠 What I Learned

Building TaskFlow provides practical experience with several Flutter development concepts:

- Structuring interfaces with reusable widgets.
- Managing state with `StatefulWidget`, `setState`, and `ValueNotifier`.
- Building responsive layouts for different screen sizes.
- Implementing light and dark themes with `ThemeData` and `ColorScheme`.
- Working with lists and updating UI state dynamically.
- Handling text input and keyboard submission.
- Implementing task completion, deletion, and undo interactions.
- Using `MediaQuery` to simulate different viewport sizes.
- Creating visual device mockups with Flutter layouts, shadows, clipping, and `CustomPainter`.

---

## ⚠️ Current Limitations

TaskFlow is currently a lightweight Todo application focused on UI, responsiveness, and basic task management.

- **In-memory storage:** Tasks are stored in application state and are not saved permanently. They may be lost when the application is restarted.
- **No user accounts:** Authentication and user profiles are not implemented.
- **No cloud synchronization:** Tasks are not synchronized across devices.
- **Preview limitations:** Simulated device sizes are useful for layout inspection but cannot replace testing on real hardware and browsers.

These limitations provide opportunities for future development.

---

## 🔮 Future Improvements

Potential enhancements include:

- [ ] Persistent local storage using Hive, SQLite, or shared preferences.
- [ ] Task editing.
- [ ] Due dates, reminders, and priorities.
- [ ] Task categories and labels.
- [ ] Search and sorting.
- [ ] Drag-and-drop task reordering.
- [ ] Firebase authentication and cloud synchronization.
- [ ] Unit and widget tests.
- [ ] Improved accessibility and keyboard navigation.
- [ ] Automated builds and releases.

---

## 👨‍💻 Author

**Sufyan Afzal**

Flutter Developer | Artificial Intelligence Student

- **GitHub:** [@sufyanafzal7](https://github.com/sufyanafzal7)
- **LinkedIn:** [@sufyanafzal7](https://www.linkedin.com/in/sufyanafzal7/)

---

## 📄 License

This project is intended for learning, portfolio development, and demonstration purposes.

If you plan to distribute or reuse it publicly, consider adding a `LICENSE` file and specifying the terms under which others may use your code.

---

<p align="center">
  <strong>Built with Flutter 💙 by Sufyan Afzal</strong>
  <br>
  <em>Plan your tasks. Track your progress. Keep moving forward.</em>
</p>
