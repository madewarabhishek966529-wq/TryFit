# TryFit — Flutter AI Virtual Try-On Studio

This repository specification is designed to be handed to Antigravity as the implementation brief. Antigravity must read `AGENTS.md` first, then the remaining docs, inspect the repository, and implement incrementally without pretending unfinished work is complete.

## Product
TryFit is a Flutter-first AI virtual try-on and personal fashion studio. Users upload a permitted photo and garment image, request a supported AI preview, save/manage results, and later use wardrobe and stylist features.

**Important:** Generated images are simulations, not verified sizing, fit, fabric behavior, or guaranteed product appearance.

## Documentation map
- `AGENTS.md` — master instructions for Antigravity/autonomous coding agent.
- `PRD.md` — complete product requirements and scope.
- `ARCHITECTURE.md` — Flutter, backend, AI inference, storage, deployment.
- `DESIGN_SYSTEM.md` — UI, animations, responsive behavior, accessibility.
- `TESTING_AND_QA.md` — unit, integration, UI, visual, AI-output, security, release QA.
- `GIT_WORKFLOW.md` — required branch, commit, push, and recovery process.
- `TASKS.md` — phased implementation checklist and gates.
- `SECURITY_PRIVACY.md` — consent, image handling, privacy, abuse prevention.
- `AI_MODEL_EVALUATION.md` — model selection, output validation, benchmarking.
- `API_CONTRACT.md` — API endpoints, data contracts, error conventions.
- `ENVIRONMENT.md` — setup, environment variables, local/dev/prod.
- `CHANGELOG.md` — release history.
- `DECISIONS.md` — architecture decision records.
- `PROMPTS/ANTIGRAVITY_START_PROMPT.md` — paste into Antigravity.

## Mandatory delivery rule
Implement one phase or coherent folder at a time. After each phase passes its required checks, commit and push that phase to the configured GitHub remote, then continue. Never push secrets, personal images, model weights, generated outputs, or unlicensed datasets. Never claim a test, UI check, or AI quality check passed unless it was actually run and its evidence recorded.

## Start
Open the project folder in Antigravity and paste `PROMPTS/ANTIGRAVITY_START_PROMPT.md`. Review Git remote, credentials, model licenses, and any destructive changes before proceeding.
