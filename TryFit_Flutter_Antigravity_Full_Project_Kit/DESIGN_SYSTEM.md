# TryFit Design System and UI QA Rules

## Visual direction
Modern editorial fashion studio: clean, image-led, premium but approachable. Use a consistent theme, spacing scale, typography, rounded cards, restrained gradients, and clear hierarchy. Avoid clutter and excessive glassmorphism.

## Main navigation
Mobile bottom navigation: Studio, History, Wardrobe (Phase 2), Profile. Use a navigation pattern appropriate to available width and accessibility. Do not show unavailable destinations as working features.

## Required screens
1. Splash/bootstrap and onboarding.
2. Consent/privacy explainer.
3. Home/Studio.
4. Person image picker and crop.
5. Garment picker and category.
6. Generation queue/progress.
7. Result comparison/detail.
8. History and saved results.
9. Profile, privacy, deletion.
10. Error/offline/permission states.
Phase 2: wardrobe, outfit builder, stylist chat.

## Motion
- Use brief, purposeful transitions (typically 150–300 ms).
- Use Flutter animation primitives or a maintained package only where it adds value.
- Respect reduced-motion settings and disable nonessential motion.
- Never animate in a way that blocks primary controls or delays accessibility.
- Avoid fake progress. Use indeterminate progress unless backend provides real progress.
- Prevent layout shifts when images load; use aspect-ratio placeholders.

## Image UX
- Show thumbnails and replace/remove actions.
- Display crop/rotate controls and photo tips.
- Preserve original asset separately; never overwrite source image.
- Result screen includes original/result comparison, zoom, save, share, export, delete.
- Always show “AI-generated preview” and the fit/sizing limitation near the result.

## Responsive and accessibility
- Test small Android phone, large phone, tablet, and web/desktop if enabled.
- Text scaling must not overflow; support landscape where practical.
- Minimum comfortable touch target and visible focus.
- Use Semantics labels, logical traversal, contrast checks, and screen-reader verification.
- Verify dark/light themes if both are offered; no broken contrast.
- Test keyboard and mouse interactions for Flutter web/desktop targets.

## Visual regression
Capture stable screenshots for key screens with deterministic fixtures. Compare at fixed viewport, device pixel ratio, font scale, and theme. Review differences rather than blindly updating snapshots. Avoid screenshots containing real personal images.
