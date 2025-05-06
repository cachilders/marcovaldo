# Development Patterns and Principles for This Project

This document provides key resources, best practices, and lessons learned from past development experiences to guide future work on this project.

---

## Key Resources

### Norns API Reference
- The Norns API provides a comprehensive guide to the executing environment. Familiarity with this API is essential for effective development.
- Access the official Norns API documentation here: [Norns API Reference](https://monome.org/docs/norns/reference/)

---

## Key Development Principles

### 1. Maintain Proper Inheritance and Object Hierarchy
- **Why:** Subverting inheritance structures can lead to bugs and unnecessary complexity.
- **How:** 
  - Follow established patterns for object creation and extension.
  - Use `setmetatable` correctly to ensure proper delegation of behavior.
  - Avoid introducing breaking changes to base classes or modules without a clear and documented rationale.

---

### 2. Prioritize State Management
- **Why:** Poor state handling can result in unpredictable behavior and hard-to-diagnose bugs.
- **How:** 
  - Clearly define state variables and their expected transitions.
  - Reset flags and states (e.g., `halt_keys`, `keys_held`) at appropriate points in the lifecycle.
  - Write unit tests to validate state transitions under different scenarios.

---

### 3. Diagnostic Logging
- **Purpose:** Diagnostic logs (e.g., `print` statements) are for development only and MUST be deleted before release.
- **Why:** 
  - Norns is a constrained system - all logs must be removed for production.
  - Logs in production environments may expose sensitive information.
- **How:**
  - Use `print` statements during development as needed.
  - Delete ALL logs before release.
  - Test thoroughly after log removal.
- **Important:** When removing logs:
  - Remove ONLY the print statements
  - Do NOT modify any other code
  - Do NOT restructure functions
  - Do NOT change logic
  - Do NOT simplify implementations
  - Preserve ALL existing functionality

---

### 4. Debugging and Logging
- **Why:** Meaningful logs help detect and resolve issues efficiently during development and testing.
- **How:** 
  - Use descriptive and consistent log messages (e.g., "Added key to held keys").
  - Log both success and failure cases to provide context for debugging.
  - Ensure logs provide actionable information without cluttering the output.

---

### 5. Modular and Scalable Design
- **Why:** Modular design improves code reuse and ease of maintenance.
- **How:** 
  - Isolate functionality into self-contained modules or classes (e.g., `SheetPane`, `SequenceSheet`).
  - Design modules to handle different configurations (e.g., 64-key vs. 128-key grids) through options or parameters.
  - Avoid hardcoding values; use constants and configuration variables instead.

---

### 6. Gesture and Event Handling
- **Why:** Complex gestures require robust detection and handling to ensure a smooth user experience.
- **How:** 
  - Validate all conditions for triggering gestures (e.g., specific keys being held simultaneously).
  - Provide clear feedback mechanisms for successful or unsuccessful gestures.
  - Implement fallback mechanisms to handle edge cases gracefully.

---

### 7. Collaborative Development Practices
- **Why:** Collaboration reduces errors and improves code quality.
- **How:** 
  - Conduct code reviews to validate adherence to principles and patterns.
  - Document changes thoroughly, including the rationale behind decisions.
  - Use version control effectively to track changes and facilitate collaboration.

---

## Development Guidelines

### Observables and Global State
- All global or shared state, including observables, should be initialized in `init_observables()` in `marcovaldo.lua`.
- Use snake_case for global/shared instances (e.g., `cat_breed_registry`).
- Avoid using `_G.` or other global mutation patterns unless absolutely necessary.
- Modules that require access to shared observables should reference the instance (e.g., `cat_breed_registry`) rather than requiring the module directly.

### Cat Breed Registry
- The cat breed registry (observable for cat breeds/mods) should be initialized in `init_observables()` as `cat_breed_registry`.
- All modules should use this instance for registering, deregistering, or querying cat breeds.
- Do not subscribe to or initialize the registry in individual plans or modules.

### Consistency
- Use snake_case for all variable and instance names unless a different convention is established in the codebase.
- Follow the established observable and initialization patterns for all new global/shared state.

---

### Registry and Service Class Pattern
- All shared registries (e.g., cat_breed_registry) must be implemented as classes with a :new() constructor.
- Instantiate these classes in initialization functions (such as init_observables), not at the top level.
- Never require/include and use a registry as a singleton table.
- Always access the instance (e.g., cat_breed_registry:register_breeds(...)).

### Initialization Order
- Ensure all shared state (e.g., cat_breed_registry, observables) is instantiated before any module or plan that depends on it.
- If a module uses a registry or observable, verify it is initialized in init_observables or an equivalent setup function.

### Debug Logging for Effect Application
- When logging effect application (e.g., in performer:apply_effect), use a local log_data function to enumerate all keys and values in the data table.
- This pattern should be used for all effect application logs to ensure consistency and aid debugging.
- Remove or disable debug logs before production release.

### Observable Usage
- Query observables directly (e.g., cat_breed_registry:get()) when current state is needed.
- Only subscribe to observables if you need to react to changes (e.g., UI updates).
- Do not store local copies of observable state unless absolutely necessary.

---

### Debugging and Regression Analysis Guidelines

- **Always Limit Root Cause Analysis to Recent Changes:**  
  When investigating a regression or bug, begin by examining only the changes introduced in the current branch or pull request (i.e., the diff from the main branch). Do not speculate about causes outside the scope of the current changes unless evidence is found in the diff.

- **Use Evidence, Not Assumptions:**  
  Do not propose fixes or root causes based on assumptions or patterns from other projects or codebases. Always verify that the suspected cause is present in the actual code changes under review.

- **Trace Initialization and Usage Order:**  
  When a bug involves uninitialized or nil values, trace the order of object creation, initialization, and usage in the changed code. Confirm that all required initialization occurs before use.

- **Search the Diff First:**  
  Before searching the entire codebase or proposing architectural changes, search the diff between the current branch and main for any relevant changes to the affected files, methods, or initialization patterns.

- **Document the Investigation Path:**  
  When reporting or discussing a regression, clearly state:
  - What was changed in the diff.
  - What was not changed.
  - The exact evidence (lines, files, or diffs) supporting your hypothesis.

- **Avoid No-Op or Redundant Edits:**  
  Do not propose or make changes that do not actually alter the code (e.g., removing a default assignment that does not exist). Always confirm the presence of the code before suggesting its removal.

- **Escalate Only with Evidence:**  
  If the root cause is not found in the diff, escalate the investigation with a summary of what was checked and why the diff does not explain the regression.

#### Example Workflow for Regression Analysis:
1. Reproduce the bug and note the error message and stack trace.
2. Run `git diff main...feature-branch` and review all changes to relevant files.
3. Search for changes to initialization, construction, or usage of affected objects.
4. Confirm or refute each hypothesis with direct evidence from the diff.
5. Only expand the search to the rest of the codebase if the diff does not explain the bug.

---

## Include Pattern
- Use `include('path/to/module')` at the top of each file to import project modules, following the standard pattern throughout the codebase.
- Place all `include` statements together at the top of the file, before any function or class definitions.
- Use `require` only for external Lua libraries or dependencies that are not part of the project source tree.
- Instantiate classes or modules (e.g., `SomeClass:new()`) in initialization functions (such as `init_observables`), not at the top level.
- This pattern ensures clarity, consistency, and maintainability across all modules.

---

Add further guidelines as new architectural patterns are introduced.

---

## Recommendations for Future Development

- **Continuous Improvement:**
  - Regularly review and refactor code to align with evolving best practices.
  - Learn from past issues and incorporate lessons into future development.

---

## Resources
- [Norns API Reference](https://monome.org/docs/norns/reference/)
- [Lua Programming Best Practices](https://www.lua.org/manual/)
- [Debugging Techniques](https://example.com/debugging-guide)
- [Modular Design Patterns](https://example.com/modular-design)

---

By following these principles, we can ensure the project remains maintainable, scalable, and easy to extend, while avoiding common pitfalls.