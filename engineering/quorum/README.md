# Quorum Specs (Swagger + Internal Schemas)

Generated on 2025-12-22.

## Contents
- `spec/openai-compat.openapi.yaml`:
  OpenAI-compatible façade (subset) for `POST /v1/chat/completions`.
- `spec/quorum-platform.openapi.yaml`:
  Quorum internal platform endpoints (jobs, libraries, artifacts).
- `schemas/*.schema.json`:
  JSON Schema contracts for SOP workflows:
  - DocFacts
  - DocIssues
  - GlobalConflicts
  - FinalReport

## Suggested generation workflow (PHP)
Use OpenAPI Generator to generate PHP DTOs + controllers, then delegate to your handwritten handlers.

Example (Docker):
```bash
docker run --rm -v "$PWD:/local" openapitools/openapi-generator-cli generate \
  -i /local/spec/openai-compat.openapi.yaml \
  -g php \
  -o /local/gen/openai \
  --additional-properties=invokerPackage=Quorum,packageName=QuorumOpenAI
```

Repeat for:
```bash
docker run --rm -v "$PWD:/local" openapitools/openapi-generator-cli generate \
  -i /local/spec/quorum-platform.openapi.yaml \
  -g php \
  -o /local/gen/platform \
  --additional-properties=invokerPackage=Quorum,packageName=QuorumPlatform
```

## RoadRunner integration
- Keep generated controllers thin: they should call into your handwritten:
  - `Quorum\Api\OpenAI\ChatCompletionsHandler`
  - `Quorum\Api\Platform\JobsHandler`, etc.
- Streaming (`stream=true`) uses `text/event-stream` and is typically implemented in handler code
  (OpenAPI cannot fully model SSE payloads).

## Next
- Add persona registry + capability routing in Quorum code.
- Add Qdrant later when semantic retrieval is earned.
