# API Contract (Initial)

All endpoints use `/api/v1`. Exact auth provider and deployment URLs are configured per environment, never hardcoded.

## Common conventions
- JSON request/response except direct signed object uploads.
- ISO-8601 UTC timestamps.
- UUID identifiers.
- Consistent error shape: `code`, `message`, `request_id`, optional safe `details`.
- Never return internal stack traces, storage credentials, or private object keys.
- Authenticated routes require bearer token; authorization is checked per resource.
- Pagination uses `cursor` and `limit`.

## Endpoints
### Assets
- `POST /assets/upload-url` — request a short-lived signed upload URL and asset ID; validates declared purpose and size limits.
- `POST /assets/{asset_id}/complete` — server verifies object exists and decodes/validates content.
- `DELETE /assets/{asset_id}` — delete asset and related permitted references.

### Try-on
- `POST /tryon/jobs` — person_asset_id, garment_asset_id, category, idempotency_key.
- `GET /tryon/jobs/{job_id}` — status, safe error, timestamps, result availability.
- `POST /tryon/jobs/{job_id}/cancel` — request cancellation where supported.
- `GET /tryon/history?cursor=&limit=` — authorized job history.
- `GET /tryon/results/{result_id}/download-url` — short-lived authorized download URL.
- `DELETE /tryon/results/{result_id}` — delete result.

### Profile/privacy
- `GET /me`
- `GET /me/consents`
- `POST /me/consents`
- `POST /me/export`
- `DELETE /me` — initiate account deletion workflow.

## Job states
`queued -> validating -> processing -> succeeded | failed | cancelled`
Only documented transitions allowed. Repeated create calls with same idempotency key must not create duplicate jobs.

## Phase 2
Wardrobe CRUD, outfits CRUD, stylist recommendations, share-link create/revoke are added only with their own schemas, authorization tests, and docs.
