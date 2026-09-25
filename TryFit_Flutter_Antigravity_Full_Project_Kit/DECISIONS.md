# Architecture Decision Records

## ADR-001 — Flutter-first client
**Status:** Accepted  
Flutter is the primary app framework. Use Dart and shared UI/business logic where practical. Backend remains separate to isolate GPU inference and protect secrets.

## ADR-002 — Mock inference before real model
**Status:** Accepted  
All app flows must be testable without GPU or paid service. Mock outputs must be visibly marked DEMO and cannot be used as model-quality evidence.

## ADR-003 — Backend inference is asynchronous
**Status:** Accepted  
Use a queue and worker. Do not run GPU inference in API request handlers or Flutter UI thread.

## ADR-004 — Provider abstraction
**Status:** Accepted  
Storage, auth, queue, and model providers are behind interfaces. Do not add Firebase, Supabase, Ollama, or paid AI APIs without explicit project-owner approval.

## ADR-005 — Evidence-based completion
**Status:** Accepted  
A task is complete only after tests and relevant UI/AI checks are run and results recorded. Git commit/push claims require actual command success.
