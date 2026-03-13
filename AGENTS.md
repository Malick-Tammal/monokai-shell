# Agent Directives for Monokai Shell (Quickshell)

This document provides guidelines and commands for AI coding agents operating in this repository. It defines standard conventions to ensure stability, aesthetic consistency, and maintainability.

## 1. Project Overview & Environment

- **Framework**: [Quickshell](https://quickshell.outfoxxed.me/) (A QML-based desktop shell for Wayland/X11).
- **Language**: QML, JavaScript, and Bash.
- **Entry Points**: `shell.qml` and `Main.qml`.
- **Architecture**:
  - `components/`: Reusable UI elements (icons, text, sliding animations).
  - `modules/`: Major UI segments (bar, dock, launcher, powermenu, walli).
  - `services/`: Backend logic and state management (Audio, Battery, Bluetooth, Hyprland, Network, Mode).
  - `theme/`: Theming and color singletons (`Style.qml`).
  - `scripts/`: Bash utilities (e.g., thumbnail generation).

## 2. Build, Lint, and Test Commands

### Running the Shell
There is no compilation step required for QML.
- **Run the full shell**:
  ```bash
  quickshell
  ```
- **Reloading**: Quickshell generally supports hot-reloading or can be restarted to apply changes. If you are instructed to test changes, restart the `quickshell` process.

### Testing Individual Components
Since there are no formalized unit test frameworks currently configured, UI testing is mostly visual.
- **Test a single component (if standalone)**:
  ```bash
  qmlscene path/to/Component.qml
  ```
- **Linting QML (if available)**:
  ```bash
  qmllint path/to/File.qml
  ```
- **Debugging**: Use `console.log()` in QML/JS. View logs in the terminal where `quickshell` is running.

## 3. Code Style & Guidelines

### QML Formatting & Structure
- **Imports**: Group imports at the top.
  ```qml
  import QtQuick
  import Quickshell
  ```
- **Root Element ID**: The root element of a component should always be named `id: root`.
- **Property Order**: Follow a logical ordering within elements:
  1. `id`
  2. `x`, `y`, `width`, `height` (layout properties)
  3. Custom `property` definitions
  4. Built-in properties (e.g., `text`, `color`, `clip`)
  5. Signals and `on<Signal>` handlers (e.g., `onClicked: {}`)
  6. Animations and Behaviors
  7. Child items
- **Indentation**: Use 4 spaces for indentation.
- **Naming Conventions**:
  - Files/Components: `PascalCase.qml` (e.g., `BarService.qml`).
  - IDs and properties: `camelCase` (e.g., `popupsLoader`, `fontSizeXs`).
  - Private/Internal properties: Prefix with an underscore (e.g., `property real _offset: 0`).

### Services & State Management
- Services (e.g., `ModeService.qml`, `DockService.qml`) typically manage state and emit signals to UI components. 
- Use Qt's property binding aggressively. UI elements should automatically react to changes in Service properties rather than relying on imperative updates.

### Theming
- **Never hardcode colors or fonts**. Always reference the `Style` singleton from `theme/Style.qml`.
  ```qml
  color: Style.bg
  font.family: Style.family
  ```
- Define new colors in `Style.qml` if a completely new theme element is added.

### Error Handling & Best Practices
- **Null Safety**: Always check if properties or models are valid before accessing them, especially when dealing with Quickshell services (e.g., screens, workspaces).
  ```qml
  visible: root.screen !== undefined
  ```
- **Performance**: 
  - Use `Loader` for components that aren't needed immediately (e.g., popups, heavy menus) to speed up initial launch and keep memory footprint low.
  - Avoid excessive JavaScript in `onPositionChanged` or high-frequency signals. Use C++/QML declarative bindings or `ParallelAnimation`/`SequentialAnimation`.
- **Bash Scripts**: For scripts in `scripts/`, use standard POSIX sh or Bash. Handle paths carefully, quote variables, and cleanly exit.

## 4. Workflows & Agent Instructions
- **Proactiveness**: If asked to add a module, create the necessary `.qml` files in `modules/`, expose required states in a new or existing service in `services/`, and integrate it smoothly into `Main.qml` or `shell.qml`.
- **Modifying UI**: Prefer tweaking existing animations (like those in `components/Sliding.qml`) over introducing entirely new animation paradigms unless requested. 
- **Icons**: Utilize Nerd Fonts or existing symbol implementations from `theme/Style.qml` rather than bringing in raster images when possible.

## 5. Context & Token Management (Context Mode)
You are operating within a workspace equipped with the `context-mode` MCP server and plugin. Your primary directive when reading code or logs is to strictly minimize token consumption and prevent context bloat.

- **Zero Raw Data Ingestion:** You must NEVER read entire files, logs, or command outputs directly into the context window using standard file-reading tools or raw OS commands (e.g., `cat`, `less`, `curl`).
- **Mandatory Context Mode Routing:** For any file larger than 100 lines (such as `Main.qml` or `shell.qml`), you must route the read operation through the `context-mode` tools.
- **Index First, Query Second:** Use `context-mode` to index target files or directories into the local SQLite sandbox. Once indexed, use targeted Full Text Search (FTS5) queries to retrieve *only* the specific QML components, functions, or lines required for your current task.
- **Summarization over Raw Output:** Do not dump unprocessed output into the chat. If an operation yields large results, summarize the findings or write them to a local scratch file.
- **Compaction Awareness:** The `context-mode` plugin automatically manages session compacting and injects resume snapshots. Rely on these injected summaries to maintain state; do not re-request full context files after a session compacts.
