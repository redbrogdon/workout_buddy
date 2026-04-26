---
name: verify-codebase
description: Comprehensive verification of a Flutter codebase to ensure health, style, and architectural correctness.
---

Use this skill whenever a task is completed, or after making significant changes, to ensure the repository remains in a stable and maintainable state.

### Step 1: Static Analysis
Run `flutter analyze` from the project root.
- **Requirement**: Zero errors.
- **Requirement**: Zero warnings (clean up unused imports, duplicate imports, and deprecated APIs).
- **Requirement**: No temporary "TODO" comments or debug print statements should remain in production code.

### Step 2: Code Formatting
Run `dart format .` to ensure the codebase adheres to standard Dart styling conventions.

### Step 3: Automated Testing
Run `flutter test`.
- **Suite Success**: Ensure the entire test suite passes.
- **Environment Isolation**: Verify that tests utilize appropriate mocks or overrides for external services (API, Storage, etc.) to avoid side effects or external dependencies during testing.

### Step 4: Architectural Integrity Check
Verify the following architectural patterns:
1. **Service Abstraction**: Ensure UI components do not depend directly on low-level SDKs or platform-specific packages. They should interact with abstract service interfaces or high-level providers.
2. **Themed UI**: Verify that UI components use `Theme.of(context)` for colors, typography, and spacing rather than hardcoded values to maintain theme consistency.
3. **Provider/State Scope**: Ensure that any new providers are correctly scoped and that test environments provide necessary overrides.
4. **Clean Imports**: Ensure that imports are organized and that cross-package or internal path dependencies are consistent with the project's folder structure.

### Step 5: Documentation Audit
Check documentation files (e.g., in `docs/`) for any updates needed to keep pace with code changes that have been made. Ensure that specifications, schemas, and instructions remain accurate and consistent with the current implementation.

### Step 6: Final Status
Clearly state whether all checks passed. If any checks failed, you MUST continue working to resolve the issues before completing the task. If you are unable to resolve the issues, ask the user for help.
