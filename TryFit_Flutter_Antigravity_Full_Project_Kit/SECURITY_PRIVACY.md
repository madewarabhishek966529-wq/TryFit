# Security and Privacy Requirements

## Personal photos
Person images can be sensitive. Explain purpose, processing location, retention, and deletion before upload. Collect only required images. Do not use uploads for training by default. Separate training consent from product consent.

## Storage and transport
- TLS for all network traffic.
- Private buckets and short-lived signed URLs.
- Encrypt data at rest using platform-supported encryption.
- Do not place image bytes or signed URLs in logs, analytics, crash reports, or URLs that persist in navigation history.
- Enforce per-user ownership in every API query and worker task.
- Remove EXIF metadata and temporary local copies when no longer needed.

## Device
- Store auth secrets in platform secure storage.
- Avoid storing source photos in app documents/cache beyond required workflow.
- Clear sensitive cached data on logout and account deletion.
- Explain OS photo/camera permissions and request them just in time.
- Avoid broad storage permissions where system pickers suffice.

## Abuse prevention
- Require users to have permission to upload images of other people.
- Prohibit non-consensual intimate imagery and sexualized transformations of minors.
- Apply upload quotas, rate limits, reporting, and moderation appropriate to deployment.
- Keep safety failures separate from ordinary technical errors.

## Deletion and retention
Document retention periods before launch. Support deletion of source, output, and related metadata; backups may have documented delayed expiry. Provide deletion status and avoid claiming immediate backup erasure unless technically true.

## Incident handling
Document owner, escalation, credential rotation, log preservation, user notification obligations, and rollback procedure before production launch.
