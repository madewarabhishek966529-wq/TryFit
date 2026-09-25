# AI Model Selection and Output Evaluation

## Gate before selecting a model
For every candidate record:
- Repository/model card and exact revision.
- Weight source and checksum.
- License for code, weights, and training/evaluation data.
- Commercial use, redistribution, attribution, and user-input restrictions.
- Supported garment categories, person-image assumptions, resolution, and known limitations.
- VRAM/RAM requirements, inference time, dependencies, and supported hardware.
- Safety restrictions and whether external data is transmitted.

Do not assume open-source means commercially unrestricted. Do not download or integrate weights until review is complete.

## Adapter contract
Inputs: validated person image, garment image, category, optional supported parameters.
Outputs: generated image asset, model/version metadata, warnings, timing, quality flags.
Errors: invalid input, unsupported category, resource unavailable, timeout, model failure, safety rejection.
Adapter must not accept arbitrary remote URLs or log image content.

## Evaluation protocol
1. Version a consented/synthetic evaluation set.
2. Stratify across supported categories, poses, lighting, skin tones, body representation, patterns, and garment colors.
3. Define a rubric before reviewing outputs.
4. Run repeatability tests and document stochasticity.
5. Human review garment preservation, identity preservation, anatomy, artifacts, and usefulness.
6. Measure latency, peak VRAM, throughput, error rate, and timeout rate.
7. Track failures by subgroup/category to identify coverage gaps.
8. Compare versions on the same fixed set.
9. Store outputs securely as test artifacts; never commit private images.
10. Publish a report with model/version, hardware, parameters, metrics, limitations, and release decision.

## User-facing truth
Every result says it is AI-generated and a visual simulation. It does not establish actual size, fit, material feel, or exact product fidelity. Disable unsupported categories rather than silently generating poor results.
