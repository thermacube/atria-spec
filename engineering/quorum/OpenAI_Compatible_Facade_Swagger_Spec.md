## **OpenAI-compatible façade Swagger spec**

### **spec/openai-compat.openapi.yaml**

This is a **strict, generator-friendly subset** of the OpenAI Chat Completions API:

- supports **Jan/LM Studio-style clients**

- supports **streaming via SSE**

- treats model as a **logical selector** (persona/capability), per your plan  
  Thermacube AI Platform Roadmap

openapi: 3.1.0

info:

title: Quorum OpenAI-Compatible API

version: "0.1.0"

description: \>

OpenAI-compatible façade for Quorum. Implements a practical subset of

POST /v1/chat/completions with streaming (SSE) for use with Jan/LM Studio and SDKs.

servers:

\- url: https://ai.thermacube.internal

description: Internal/VPN base URL

security:

\- bearerAuth: \[\]

tags:

\- name: openai

description: OpenAI-compatible endpoints

paths:

/v1/chat/completions:

post:

tags: \[openai\]

summary: Create a chat completion (OpenAI-compatible subset)

operationId: createChatCompletion

security:

\- bearerAuth: \[\]

requestBody:

required: true

content:

application/json:

schema:

\$ref: "#/components/schemas/ChatCompletionRequest"

responses:

"200":

description: Chat completion response (non-streaming)

content:

application/json:

schema:

\$ref: "#/components/schemas/ChatCompletionResponse"

"401":

description: Unauthorized

"413":

description: Payload too large

"429":

description: Rate limited

"500":

description: Server error

/healthz:

get:

tags: \[openai\]

summary: Liveness probe

operationId: healthz

security: \[\]

responses:

"200":

description: OK

content:

application/json:

schema:

\$ref: "#/components/schemas/HealthResponse"

/readyz:

get:

tags: \[openai\]

summary: Readiness probe

operationId: readyz

security: \[\]

responses:

"200":

description: Ready

content:

application/json:

schema:

\$ref: "#/components/schemas/HealthResponse"

"503":

description: Not ready

components:

securitySchemes:

bearerAuth:

type: http

scheme: bearer

schemas:

HealthResponse:

type: object

additionalProperties: false

properties:

status:

type: string

enum: \[ok\]

service:

type: string

version:

type: string

required: \[status, service, version\]

ChatCompletionRequest:

type: object

additionalProperties: false

properties:

model:

type: string

description: \>

Logical model selector. Quorum maps this to persona/capability (e.g., "architect", "developer", "critic").

messages:

type: array

minItems: 1

items:

\$ref: "#/components/schemas/ChatMessage"

temperature:

type: number

minimum: 0

maximum: 2

default: 0.7

top_p:

type: number

minimum: 0

maximum: 1

default: 1

max_tokens:

type: integer

minimum: 1

description: Max tokens to generate (best-effort).

stream:

type: boolean

default: false

description: When true, response MUST be Server-Sent Events (SSE) chunks.

stop:

oneOf:

\- type: string

\- type: array

items: { type: string }

user:

type: string

description: Optional end-user identifier (for audit correlation).

metadata:

type: object

description: \>

Optional extension object for Quorum routing (library_id, job_mode, etc.).

additionalProperties: true

required: \[model, messages\]

ChatMessage:

type: object

additionalProperties: false

properties:

role:

type: string

enum: \[system, user, assistant, tool\]

content:

oneOf:

\- type: string

\- type: array

description: \>

Content parts (future-proof). Many clients will send plain string; array is accepted for compatibility.

items:

\$ref: "#/components/schemas/ContentPart"

name:

type: string

description: Optional name for the participant (rarely used).

tool_call_id:

type: string

description: Present when role=tool to associate tool output with a tool call.

required: \[role, content\]

ContentPart:

type: object

additionalProperties: false

properties:

type:

type: string

enum: \[text\]

text:

type: string

required: \[type, text\]

ChatCompletionResponse:

type: object

additionalProperties: false

properties:

id:

type: string

description: Unique completion id

object:

type: string

enum: \[chat.completion\]

created:

type: integer

description: Unix timestamp seconds

model:

type: string

description: Echoes requested logical model id

choices:

type: array

items:

\$ref: "#/components/schemas/ChatCompletionChoice"

usage:

\$ref: "#/components/schemas/Usage"

required: \[id, object, created, model, choices\]

ChatCompletionChoice:

type: object

additionalProperties: false

properties:

index:

type: integer

message:

\$ref: "#/components/schemas/ChatMessage"

finish_reason:

type: string

enum: \[stop, length, content_filter, tool_calls\]

required: \[index, message, finish_reason\]

Usage:

type: object

additionalProperties: false

properties:

prompt_tokens:

type: integer

completion_tokens:

type: integer

total_tokens:

type: integer

required: \[prompt_tokens, completion_tokens, total_tokens\]

x-quorum-notes:

streaming:

format: \>

When stream=true, this endpoint returns text/event-stream. Each event's data line

is a JSON object shaped like OpenAI chat.completion.chunk. Terminate with data: \[DONE\].

implementation:

note: \>

The RoadRunner+PHP generated controller should delegate to Quorum\\Handlers\\ChatCompletionsHandler.

### **Streaming chunks spec note**

OpenAPI can’t perfectly “type” SSE; the x-quorum-notes.streaming section documents the contract. Your generator will still produce the controller + DTOs for non-streaming; streaming is implemented in the handler (normal for OSS OpenAI-compatible stacks).

## **2) Internal platform Swagger spec (jobs, libraries, artifacts)**

### **spec/quorum-platform.openapi.yaml**

This is the “rest of the monolith” API you’ll use for:

- SOP/job orchestration

- content library ingestion

- artifact access

- admin-lite operations

openapi: 3.1.0

info:

title: Quorum Platform API

version: "0.1.0"

description: Internal platform endpoints for jobs, libraries, documents, and artifacts.

servers:

\- url: https://ai.thermacube.internal

security:

\- bearerAuth: \[\]

tags:

\- name: jobs

\- name: libraries

\- name: artifacts

\- name: admin

paths:

/jobs:

post:

tags: \[jobs\]

summary: Create a long-running job (SOP workflow)

operationId: createJob

requestBody:

required: true

content:

application/json:

schema: { \$ref: "#/components/schemas/CreateJobRequest" }

responses:

"202":

description: Accepted

content:

application/json:

schema: { \$ref: "#/components/schemas/Job" }

get:

tags: \[jobs\]

summary: List jobs (filterable)

operationId: listJobs

parameters:

\- in: query

name: status

schema: { type: string }

\- in: query

name: persona

schema: { type: string }

\- in: query

name: limit

schema: { type: integer, minimum: 1, maximum: 200, default: 50 }

responses:

"200":

description: OK

content:

application/json:

schema: { \$ref: "#/components/schemas/JobList" }

/jobs/{job_id}:

get:

tags: \[jobs\]

summary: Get job status

operationId: getJob

parameters:

\- in: path

name: job_id

required: true

schema: { type: string }

responses:

"200":

description: OK

content:

application/json:

schema: { \$ref: "#/components/schemas/Job" }

"404":

description: Not found

post:

tags: \[jobs\]

summary: Control a job (cancel, retry, advance)

operationId: controlJob

parameters:

\- in: path

name: job_id

required: true

schema: { type: string }

requestBody:

required: true

content:

application/json:

schema: { \$ref: "#/components/schemas/JobControlRequest" }

responses:

"200":

description: OK

content:

application/json:

schema: { \$ref: "#/components/schemas/Job" }

/jobs/{job_id}/artifacts:

get:

tags: \[artifacts\]

summary: List artifacts produced by a job

operationId: listJobArtifacts

parameters:

\- in: path

name: job_id

required: true

schema: { type: string }

responses:

"200":

description: OK

content:

application/json:

schema: { \$ref: "#/components/schemas/ArtifactList" }

/artifacts/{artifact_id}:

get:

tags: \[artifacts\]

summary: Get artifact metadata

operationId: getArtifact

parameters:

\- in: path

name: artifact_id

required: true

schema: { type: string }

responses:

"200":

description: OK

content:

application/json:

schema: { \$ref: "#/components/schemas/Artifact" }

"404":

description: Not found

/artifacts/{artifact_id}/content:

get:

tags: \[artifacts\]

summary: Download artifact content

operationId: downloadArtifactContent

parameters:

\- in: path

name: artifact_id

required: true

schema: { type: string }

responses:

"200":

description: Artifact bytes

content:

application/octet-stream: {}

"404":

description: Not found

/libraries:

post:

tags: \[libraries\]

summary: Create a content library

operationId: createLibrary

requestBody:

required: true

content:

application/json:

schema: { \$ref: "#/components/schemas/CreateLibraryRequest" }

responses:

"201":

description: Created

content:

application/json:

schema: { \$ref: "#/components/schemas/Library" }

get:

tags: \[libraries\]

summary: List libraries

operationId: listLibraries

responses:

"200":

description: OK

content:

application/json:

schema: { \$ref: "#/components/schemas/LibraryList" }

/libraries/{library_id}/documents:

post:

tags: \[libraries\]

summary: Register/upload a document into a library

operationId: uploadDocument

parameters:

\- in: path

name: library_id

required: true

schema: { type: string }

requestBody:

required: true

content:

multipart/form-data:

schema:

\$ref: "#/components/schemas/UploadDocumentForm"

responses:

"201":

description: Created

content:

application/json:

schema: { \$ref: "#/components/schemas/Document" }

get:

tags: \[libraries\]

summary: List documents in a library

operationId: listDocuments

parameters:

\- in: path

name: library_id

required: true

schema: { type: string }

\- in: query

name: doc_type

schema: { type: string }

\- in: query

name: version

schema: { type: string }

responses:

"200":

description: OK

content:

application/json:

schema: { \$ref: "#/components/schemas/DocumentList" }

/libraries/{library_id}/ingest:

post:

tags: \[libraries\]

summary: Enqueue ingestion (parse/chunk/embed) for documents in a library

operationId: ingestLibrary

parameters:

\- in: path

name: library_id

required: true

schema: { type: string }

requestBody:

required: true

content:

application/json:

schema: { \$ref: "#/components/schemas/IngestRequest" }

responses:

"202":

description: Accepted

content:

application/json:

schema: { \$ref: "#/components/schemas/IngestResponse" }

/admin/personas:

get:

tags: \[admin\]

summary: List personas

operationId: listPersonas

responses:

"200":

description: OK

content:

application/json:

schema: { \$ref: "#/components/schemas/PersonaList" }

components:

securitySchemes:

bearerAuth:

type: http

scheme: bearer

schemas:

CreateJobRequest:

type: object

additionalProperties: false

properties:

persona:

type: string

description: Logical persona name (architect, developer, learning_designer, etc.)

workflow:

type: string

description: SOP workflow name (build_course_from_outline, spec_audit, etc.)

library_id:

type: string

inputs:

type: object

additionalProperties: true

description: Workflow-specific inputs (doc ids, outline id, template ids, etc.)

options:

type: object

additionalProperties: true

description: Optional execution settings (iteration limits, strictness, etc.)

required: \[persona, workflow, library_id, inputs\]

Job:

type: object

additionalProperties: false

properties:

job_id: { type: string }

status:

type: string

enum: \[queued, running, waiting, succeeded, failed, canceled\]

persona: { type: string }

workflow: { type: string }

library_id: { type: string }

progress:

type: object

additionalProperties: true

created_at: { type: string, format: date-time }

updated_at: { type: string, format: date-time }

error:

type: object

additionalProperties: true

required: \[job_id, status, persona, workflow, library_id, created_at, updated_at\]

JobList:

type: object

additionalProperties: false

properties:

items:

type: array

items: { \$ref: "#/components/schemas/Job" }

required: \[items\]

JobControlRequest:

type: object

additionalProperties: false

properties:

action:

type: string

enum: \[cancel, retry\]

reason:

type: string

required: \[action\]

Artifact:

type: object

additionalProperties: false

properties:

artifact_id: { type: string }

job_id: { type: string }

kind:

type: string

description: e.g., lesson_markdown, course_plan_json, audit_report, zip_bundle

filename: { type: string }

mime_type: { type: string }

bytes: { type: integer }

sha256: { type: string }

created_at: { type: string, format: date-time }

metadata:

type: object

additionalProperties: true

required: \[artifact_id, job_id, kind, filename, mime_type, created_at\]

ArtifactList:

type: object

additionalProperties: false

properties:

items:

type: array

items: { \$ref: "#/components/schemas/Artifact" }

required: \[items\]

CreateLibraryRequest:

type: object

additionalProperties: false

properties:

name: { type: string }

description: { type: string }

tenant_id: { type: string }

required: \[name, tenant_id\]

Library:

type: object

additionalProperties: false

properties:

library_id: { type: string }

tenant_id: { type: string }

name: { type: string }

description: { type: string }

created_at: { type: string, format: date-time }

required: \[library_id, tenant_id, name, created_at\]

LibraryList:

type: object

additionalProperties: false

properties:

items:

type: array

items: { \$ref: "#/components/schemas/Library" }

required: \[items\]

UploadDocumentForm:

type: object

additionalProperties: false

properties:

file:

type: string

format: binary

doc_type:

type: string

description: e.g., outline, source, template, rubric, reference

version:

type: string

description: Optional version label (e.g., v3)

metadata:

type: string

description: Optional JSON string

required: \[file, doc_type\]

Document:

type: object

additionalProperties: false

properties:

doc_id: { type: string }

library_id: { type: string }

filename: { type: string }

doc_type: { type: string }

version: { type: string }

mime_type: { type: string }

bytes: { type: integer }

sha256: { type: string }

storage_path: { type: string }

created_at: { type: string, format: date-time }

required: \[doc_id, library_id, filename, doc_type, mime_type, sha256, created_at\]

DocumentList:

type: object

additionalProperties: false

properties:

items:

type: array

items: { \$ref: "#/components/schemas/Document" }

required: \[items\]

IngestRequest:

type: object

additionalProperties: false

properties:

doc_ids:

type: array

items: { type: string }

description: If omitted, ingest all docs in the library.

embed:

type: boolean

default: true

chunk:

type: boolean

default: true

parse:

type: boolean

default: true

options:

type: object

additionalProperties: true

required: \[\]

IngestResponse:

type: object

additionalProperties: false

properties:

accepted: { type: boolean }

job_id: { type: string }

required: \[accepted, job_id\]

PersonaList:

type: object

additionalProperties: false

properties:

items:

type: array

items: { \$ref: "#/components/schemas/Persona" }

required: \[items\]

Persona:

type: object

additionalProperties: false

properties:

persona: { type: string }

capability: { type: string }

default_model: { type: string }

notes: { type: string }

required: \[persona, capability, default_model\]

## **3) Specs for the rest of Quorum (non-Swagger)**

These are the **internal code specs** you’ll implement after Swagger generation gives you controllers/DTOs/validators. This keeps “transport correctness” generated and “system intelligence” owned, matching your roadmap

Thermacube AI Platform Roadmap

.

### **3.1 Quorum package layout spec (PHP)**

Create a single library/module tree in the monolith:

src/

Quorum/

Api/

OpenAI/ \# Generated controller entrypoints delegate here

ChatCompletionsHandler.php

Platform/

JobsHandler.php

LibrariesHandler.php

ArtifactsHandler.php

Runtime/

LLMRuntime.php \# public façade for inference operations

ModelRegistry.php \# maps capability -\> provider+model

PromptCompiler.php \# system/dev/user + evidence pack builder

TokenBudget.php \# model-specific budget estimation

StreamAdapter.php \# converts provider streaming -\> OpenAI SSE

OutputContracts/

JsonSchemaValidator.php

RepairLoop.php

Personas/

PersonaRouter.php \# persona -\> capability + policies + templates

Constitutions/ \# system prompts, constraints

Policies/ \# guardrails, grounding, evidence requirements

Retrieval/

Retriever.php \# "retrieve evidence" interface

KeywordRetriever.php \# V1 fallback (DB keyword/metadata retrieval)

QdrantRetriever.php \# V2 when earned

EvidencePack.php \# canonical evidence format

Workflows/

WorkflowEngine.php \# interface

SopStateMachine.php \# V1 implementation

Workflows/

SpecAuditWorkflow.php

BuildCourseWorkflow.php

RemediationWorkflow.php

Storage/

Db.php \# DB access wrapper

Repos/

RunsRepo.php

JobsRepo.php

LibrariesRepo.php

DocumentsRepo.php

ArtifactsRepo.php

ProvenanceRepo.php

Security/

Auth.php

Rbac.php

TenantIsolation.php

Observability/

Logger.php

Metrics.php

Trace.php

### **3.2 Quorum LLMRuntime interface spec**

**Purpose:** One internal abstraction that makes three model families look identical.

interface LLMRuntime {

public function generate(GenerateRequest \$req): GenerateResponse;

public function stream(GenerateRequest \$req): StreamIterator; // yields OpenAI-style chunks

}

**GenerateRequest fields (minimum):**

- capability (generalist_reasoning \| code_specialist \| critic_reasoning)

- messages\[\] (system/dev/user already compiled OR raw user + persona pointer)

- evidencePack (optional)

- outputContract (optional JSON schema or “format rules”)

- decoding (temperature, top_p, max_tokens)

- auditContext (tenant_id, user_id, session_id, library_id, run_id)

**GenerateResponse fields:**

- text

- finish_reason

- usage (prompt/completion/total)

- provenance (chunk IDs, prompt hash, model id, quant profile)

### **3.3 Provider adapter spec (vLLM + llama.cpp)**

You will have at least two providers over time:

- LlamaCppProvider (CPU validation phase)

- VllmProvider (GPU phase)

Both must implement:

- invoke(request) -\> response

- invokeStream(request) -\> eventStream

…and return a provider-neutral stream that StreamAdapter can normalize into OpenAI SSE.

### **3.4 ModelRegistry spec (capability routing)**

A single config file drives model routing, so no hardcoding:

**File:** config/quorum-model-registry.yaml

Example:

capabilities:

generalist_reasoning:

provider: llama_cpp

model: llama4-internal-q4k.gguf

max_context: 8192

code_specialist:

provider: llama_cpp

model: qwen3-coder-q4k.gguf

max_context: 8192

critic_reasoning:

provider: llama_cpp

model: deepseek-r1-q4k.gguf

max_context: 8192

Later, flip provider/model to vLLM without changing workflows.

### **3.5 EvidencePack spec (retrieval contract)**

All workflows use the same evidence format:

{

"library_id": "lib_123",

"version": "v3",

"items": \[

{

"chunk_id": "chk_abc",

"doc_id": "doc_001",

"doc_type": "outline",

"section_path": "2.3 APIs",

"text": "…",

"source_ref": "doc_001#2.3",

"score": 0.82

}

\]

}

Rules:

- Evidence must be filtered by (tenant_id, library_id, version)

- Output contracts can require citations referencing chunk_id or source_ref

### **3.6 WorkflowEngine spec (SOP state machines)**

**WorkflowEngine** must support:

- resumability

- iteration caps

- explicit stop criteria

- artifacts and provenance

Minimal interface:

interface WorkflowEngine {

public function start(CreateJobRequest \$req): Job;

public function tick(string \$jobId): Job; // advances state machine

public function cancel(string \$jobId, string \$reason): Job;

}

Workflows implement:

- plan()

- draft()

- evaluate()

- revise()

- finalize()

### **3.7 Output contract + repair loop spec**

For any step requiring structured output (JSON), Quorum enforces:

1.  Validate JSON against schema

2.  If invalid, run a “repair prompt” with:

    - the raw invalid output

    - schema requirements

    - minimal additional evidence

3.  Fail after N attempts and mark job as blocked

This is the key reliability mechanism for “agentic loops.”
