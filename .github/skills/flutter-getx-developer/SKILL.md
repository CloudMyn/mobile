---
name: flutter-getx-developer
user-invocable: true
description: "Guides a professional Flutter/Dart developer building mobile app features using GetX state management, dependency injection, navigation, and reactive architecture."
tags: ["flutter", "dart", "getx", "state management", "mobile", "workflow"]
---

# Flutter GetX Developer Skill

## When to use
- Building or updating Flutter app features with GetX state management.
- Implementing controllers, bindings, routes, services, or reactive views.
- Refactoring StatefulWidgets to GetX architecture.
- Ensuring consistent GetX patterns across the app.

## Workflow
1. Identify the feature scope and the widget/page involved.
2. Choose the right GetX structure:
   - `GetView` / `GetWidget` for UI classes with a controller.
   - `GetxController` for business logic and state.
   - `Bindings` for dependency injection and lazy initialization.
   - Services for API, local storage, permissions, or utilities.
3. Define reactive state:
   - Use `.obs`, `Rx<T>`, `RxList`, or `RxMap` for observable data.
   - Create computed getters and derive state with `Rx`.
   - Use `Obx`, `GetX`, or `GetBuilder` in the UI.
4. Wire dependencies with GetX DI:
   - `Get.put`, `Get.lazyPut`, `Get.find`, or Bindings.
   - Keep controller creation centralized where possible.
5. Implement navigation and arguments:
   - Use `Get.to`, `Get.offNamed`, `Get.back`, and `Get.arguments`.
   - Prefer named routes for app-wide flows.
6. Separate UI from logic:
   - Keep side effects, API calls, and data handling in controllers or services.
   - Avoid `setState` for GetX-managed state.
7. Use lifecycle hooks when needed:
   - `onInit`, `onReady`, `onClose`, and worker methods.
8. Maintain professional standards:
   - Follow project naming, style, and shared design tokens.
   - Add error/loading states and handle edge cases.

## Quality checklist
- State lives in a GetX controller, not via `setState`.
- Reactive data uses `.obs` or the appropriate `Rx` type.
- UI updates use `Obx`, `GetX`, or `GetBuilder` correctly.
- Dependencies are injected with GetX DI or Bindings.
- Navigation and routing follow existing project conventions.
- Lifecycle hooks are used when initialization or cleanup is needed.
- Business logic and side effects are separate from the widget tree.
- Shared constants, themes, and localization reuse project patterns.

## Example prompts
- "Create a GetX controller and binding for the presensi list page with API loading and refresh."
- "Refactor this StatefulWidget to use GetX and remove `setState`."
- "Design GetX route setup for login flow and profile navigation."
- "Implement a GetX service for location and permission handling."
