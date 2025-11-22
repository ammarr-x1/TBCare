# TB-Care Project Context

## Overview
TB-Care is a Flutter Web app with role-based dashboards: Patient, CHW and Doctor.  
The system must remain scalable, maintainable, and production-ready.

## Architecture Rules
- Strict modular structure under `features/<role>/models|services|screens`.
- Models: data definitions only (`*_model.dart`).
- Services: Firestore/network logic only (`*_service.dart`).
- Screens: UI and controllers only (`*_screen.dart`).
- Firestore operations must never appear in screens.
- Use SOLID principles consistently.
- Maintain existing structure and patterns unless explicitly told otherwise.

## Naming Conventions
- Snake_case for files and folders.
- Screens → `*_screen.dart`
- Models → `*_model.dart`
- Services → `*_service.dart`
- Example: `features/doctor/screens/dashboard/doctor_dashboard.dart`



## Cursor Behavior Rules
- Do NOT alter existing logic or architecture unless explicitly requested.
- Follow current project structure when generating new files.
- Always ask for clarification when encountering ambiguous requirements.
- Never introduce new dependencies without permission.
- Keep code efficient, scalable, and clean.

