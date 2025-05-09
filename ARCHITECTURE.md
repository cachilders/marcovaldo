# Marcovaldo Architecture Guidelines

This document outlines the core architectural patterns, principles, and development guidelines for the Marcovaldo project.

## Table of Contents
1. [Core Principles](#core-principles)
2. [Module System](#module-system)
3. [State Management](#state-management)
4. [Initialization Patterns](#initialization-patterns)
5. [Development Workflow](#development-workflow)
6. [Resources](#resources)

## Core Principles

### 1. Maintain Proper Inheritance and Object Hierarchy
- **Why:** Subverting inheritance structures can lead to bugs and unnecessary complexity.
- **How:** 
  - Follow established patterns for object creation and extension.
  - Use `setmetatable` correctly to ensure proper delegation of behavior.
  - Avoid introducing breaking changes to base classes or modules without a clear and documented rationale.

### 2. Modular and Scalable Design
- **Why:** Modular design improves code reuse and ease of maintenance.
- **How:** 
  - Isolate functionality into self-contained modules or classes.
  - Design modules to handle different configurations through options or parameters.
  - Avoid hardcoding values; use constants and configuration variables instead.

### 3. Collaborative Development Practices
- **Why:** Collaboration reduces errors and improves code quality.
- **How:** 
  - Conduct code reviews to validate adherence to principles and patterns.
  - Document changes thoroughly, including the rationale behind decisions.
  - Use version control effectively to track changes and facilitate collaboration.

## Module System

### Module Inclusion Pattern
- Use `include('path/to/module')` at the top of each file to import project modules
- Place all `include` statements together at the top of the file
- Use `require` only for external Lua libraries
- Instantiate classes in initialization functions, not at the top level

### Global Instance Pattern
- **Never** include a module if you're only using its global instance
  - Wrong: `local CatBreedRegistry = include('lib/cat_breed_registry')` when only using `cat_breed_registry`
  - Right: Just use the global `cat_breed_registry` instance directly
- **Only** include modules when you need:
  - The class/module definition for inheritance
  - To create new instances
  - To access module-level constants or utilities
- **Always** check existing globals before adding includes
  - Search for global instances in `init_observables()` in `marcovaldo.lua`
  - Reference these instances directly instead of including their modules

## State Management

### Observables and Global State
- All global or shared state, including observables, should be initialized in `init_observables()`
- Use snake_case for global/shared instances (e.g., `cat_breed_registry`)
- Avoid using `_G.` or other global mutation patterns unless absolutely necessary
- Modules should reference instances rather than requiring modules directly

### Registry and Service Class Pattern
- All shared registries must be implemented as classes with a `:new()` constructor
- Instantiate these classes in initialization functions
- Never require/include and use a registry as a singleton table
- Always access the instance (e.g., `cat_breed_registry:register_breeds(...)`)

### Observable Usage
- Query observables directly (e.g., `cat_breed_registry:get()`) when current state is needed
- Only subscribe to observables if you need to react to changes
- Do not store local copies of observable state unless absolutely necessary

## Initialization Patterns

### Initialization Order
1. `init_observables()` - creates global instances
2. `init_params()` - uses global instances
3. `create_metaphors()` - creates system components
4. `init_events()` - sets up event handlers
5. `init_metaphors()` - initializes components

### Common Initialization Pitfalls
- **Global Instance Access**
  - Global instances are initialized in `init_observables()`
  - Never try to use these instances before they're initialized
  - Check initialization order in `init()` function of `marcovaldo.lua`
- **Module vs Instance**
  - Wrong: `CatBreedRegistry:some_method()` (calling on module)
  - Right: `cat_breed_registry:some_method()` (calling on instance)

## Development Workflow

### Debugging and Logging
- **Purpose:** Diagnostic logs are for development only and MUST be deleted before release
- **Why:** 
  - Norns is a constrained system - all logs must be removed for production
  - Logs in production may expose sensitive information
- **How:**
  - Use `print` statements during development as needed
  - Delete ALL logs before release
  - Test thoroughly after log removal
- **Important:** When removing logs:
  - Remove ONLY the print statements
  - Do NOT modify any other code
  - Do NOT restructure functions
  - Do NOT change logic
  - Do NOT simplify implementations
  - Preserve ALL existing functionality

### Debug Logging for Effect Application
- Use a local `log_data` function to enumerate all keys and values in data tables
- This pattern should be used for all effect application logs
- Remove or disable debug logs before production release

### Regression Analysis Guidelines
- **Always Limit Root Cause Analysis to Recent Changes**
  - Begin by examining only changes in the current branch/PR
  - Do not speculate about causes outside the current changes
- **Use Evidence, Not Assumptions**
  - Verify suspected causes in the actual code changes
  - Do not propose fixes based on patterns from other projects
- **Trace Initialization and Usage Order**
  - Confirm all required initialization occurs before use
  - Document the investigation path clearly

### Code Review Checklist
- [ ] No unnecessary module includes
- [ ] Using global instances correctly (not module directly)
- [ ] Proper initialization order respected
- [ ] Clear separation between module definitions and instance usage
- [ ] All debug logs removed for production
- [ ] Changes limited to necessary modifications

## Resources
- [Norns API Reference](https://monome.org/docs/norns/reference/)
- [Lua Programming Best Practices](https://www.lua.org/manual/)
- [Debugging Techniques](https://example.com/debugging-guide)
- [Modular Design Patterns](https://example.com/modular-design)