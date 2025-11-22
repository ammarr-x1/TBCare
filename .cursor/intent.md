# TB-Care Project Intent

The primary intent of this codebase is to build a production-ready, highly scalable, secure, memory-efficient Flutter Web application for tuberculosis screening and medical workflow management.

## Core Engineering Goals
- Produce code that is reliable, stable under load, and easy to maintain.
- Prioritize memory efficiency and avoid unnecessary state retention.
- Enforce strict separation of concerns for long-term scalability.
- Ensure all generated code aligns with enterprise-grade quality standards.
- Prevent architectural drift; keep existing patterns intact unless instructed.

## Performance & Memory Intent
- Minimize widget rebuilds; prefer const widgets where applicable.
- Avoid heavy synchronous operations on the main thread.
- Use efficient Firestore queries (indexed, paginated, minimal reads).
- Reduce state retention and memory leaks by disposing controllers properly.
- Avoid redundant streams and listeners; ensure cleanup.
- Prefer lightweight models and data structures to keep the app responsive.

## Security Intent
- Only perform sensitive logic on the backend or secured services.
- Avoid embedding secrets, tokens, or sensitive logic in frontend code.
- Ensure all Firestore writes/reads are validated through secure rules.
- Enforce role-based access strictly at service or middleware layers.
- Use proper validation on all user inputs.
- Maintain safe, defensive coding practices at all times.

## Scalability Intent
- All features must be modular, independently extendable, and testable.
- Services must remain stateless and reusable.
- UI must remain loosely coupled from backend logic.
- Maintain consistent naming and folder structure across all modules.
- Avoid hardcoded values; use constants and config classes.
- Code should allow seamless future integration of AI models, analytics, and admin tools.

## Reliability Intent
- Prefer predictable state management patterns.
- Avoid hidden side effects; keep data flow explicit and transparent.
- Write deterministic, easily debuggable logic.
- Ensure services handle errors gracefully and return reliable outcomes.
- Prefer typed returns over dynamic or loosely structured data.

## Cursor Behavior Intent
- Never modify existing logic unless explicitly requested.
- Generate code that follows all context rules automatically.
- Ask for clarification before generating risky or ambiguous implementations.
- Follow naming conventions, architecture, and folder structure consistently.
- Avoid introducing third-party dependencies without asking.

