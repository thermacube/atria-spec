# **Thermacube AI Platform Roadmap**

**Spec-First • CPU-First • Majestic Monolith • OpenAI-Compatible**

## **0) Foundational Commitments (Locked)**

1.  **Majestic Monolith  
    **

    - One primary service (“Thermacube AI Monolith”) owns:

      - persona logic

      - SOP / agentic workflows

      - retrieval policy

      - job state machines

      - audit & provenance

    - No microservice sprawl.

2.  **Earned Complexity  
    **

    - External dependencies, additional models, and hardware are added **only after**:

      - quality is proven,

      - limitations are measured,

      - value is clear.

3.  **Spec-First Development  
    **

    - All externally visible services are defined by **OpenAPI specs**.

    - PHP controllers, DTOs, and validators are **generated** from spec.

    - Business logic remains handwritten and owned.

4.  **OpenAI API as Wire Protocol  
    **

    - The OpenAI API schema is used as a **compatibility façade**, not as internal architecture.

    - Jan / LM Studio / SDKs talk to your service without custom clients.

5.  **CPU Validates Quality; GPU Validates Performance  
    **

    - Initial work is done on CPU.

    - GPU hardware is purchased only after output quality is validated.

## **1) Phase 1 — CPU-Only “Pre-Monster” Box (Upgradeable)**

### **Purpose**

Validate:

- model output quality,

- persona behavior,

- SOP convergence,

- retrieval correctness,

**before** investing in GPU hardware.

### **Hardware (CPU-Only, GPU-Ready)**

- **CPU**: 16–24 cores (Ryzen 9 / Threadripper-class)

- **RAM**: **128 GB minimum  
  **

- **Storage**:

  - NVMe \#1 (OS/logs): 1–2 TB

  - NVMe \#2 (models/docs/artifacts): 2 TB

- **Motherboard**:

  - full PCIe x16 slot

  - sufficient PCIe lanes for future GPU + NVMe

- **PSU/Case**:

  - sized for later 300–450 W GPU

> This box proves correctness, not speed.

## **2) Phase 2 — Define the API Specs (Before Writing Code)**

### **2.1 Public Façade Spec (OpenAI-Compatible)**

**File:** spec/openai-compat.openapi.yaml

Includes:

- POST /v1/chat/completions

- request schemas:

  - model

  - messages\[\]

  - stream

  - decoding params (temperature, max_tokens, etc.)

- response schemas:

  - ChatCompletionResponse

  - streaming chunks (SSE)

**Design rules**

- model is treated as a **logical selector** (persona/capability), not a real model ID.

- Allow extension fields (e.g., metadata) without breaking clients.

### **2.2 Internal Platform Spec**

**File:** spec/thermacube-ai.openapi.yaml

Defines:

- /jobs

- /jobs/{id}

- /jobs/{id}/artifacts

- /libraries

- /libraries/{id}/documents

- health endpoints

This spec captures **agentic workflows**, not chat.

### **2.3 Code Generation Strategy**

- Use OpenAPI generator to produce:

  - PHP DTOs

  - request/response validators

  - controller skeletons

- Generated controllers delegate to handwritten handlers:

  - ChatCompletionsHandler

  - JobHandler

  - LibraryHandler

**Generated code = transport correctness  
** **Handwritten code = system intelligence**

## **3) Phase 3 — Stand Up the Majestic Monolith (V1, CPU)**

### **External Dependencies (V1 Minimum)**

- **RoadRunner  
  **

- **PHP  
  **

- **MariaDB** (or Postgres)

- **llama.cpp** (CPU inference)

> No vLLM, no vector DB, no message queue yet.

### **Internal Modules (Handwritten PHP)**

#### **3.1 LLMRuntime**

- capability-based routing

- prompt compilation

- token budgeting

- schema enforcement

- repair loops

- streaming normalization

#### **3.2 PersonaRouter**

- persona → capability → model family

- persona constitutions (system prompts + constraints)

#### **3.3 WorkflowEngine**

- SOP-driven state machines

- iteration limits

- blocker detection

- resumability

#### **3.4 Audit & Provenance**

- runs

- inputs

- outputs

- document/chunk references

- model + prompt versioning

## **4) Phase 4 — OpenAI-Compatible Endpoint (Quality Validation)**

### **Implemented Endpoint**

- POST /v1/chat/completions

  - fully spec-validated

  - SSE streaming

  - works with Jan / LM Studio immediately

### **Why this phase matters**

- Zero UI development

- Immediate interactive testing

- Persona tuning without extra tooling

- SOP workflows can be triggered via chat

## **5) Phase 5 — Model Strategy (CPU Validation)**

### **Models Used (Smaller / Quantized Variants)**

#### **Llama 4 — Internal Generalist**

- Personas:

  - Architect

  - Learning Designer

  - Course Developer

  - Counselor (private)

- Inference:

  - llama.cpp (CPU)

- Quant:

  - GGUF 4-bit or 8-bit

#### **Qwen3-Coder — Developer Persona**

- Persona:

  - Developer

- Inference:

  - llama.cpp (CPU)

- Quant:

  - GGUF 4-bit or 8-bit

#### **DeepSeek-R1 — Critic / Verifier**

- Role:

  - adversarial review

  - readiness arbitration

- Inference:

  - llama.cpp (CPU)

- Quant:

  - GGUF 4-bit or 8-bit

> Slow execution is acceptable; behavioral quality is the goal.

## **6) Phase 6 — SOP / Agentic Workflow Proof**

### **Standard SOP State Machine**

INGESTED

→ PLANNED

→ DRAFTED

→ EVALUATED

→ REVISED (loop)

→ FINALIZED

### **Acceptance Criteria (Before GPU Purchase)**

- ≥80 % of real issues detected by Architect + Critic

- Revisions measurably improve output

- Personas behave distinctly

- Provenance is traceable

- Outputs are usable artifacts

If this fails → **stop**.  
Hardware will not fix reasoning.

## **7) Phase 7 — Retrieval Strategy (Earned Dependency Ladder)**

### **7.1 V1 Retrieval (No Vector DB)**

- Documents + parsed text stored in MariaDB

- Retrieval via:

  - keyword filtering

  - section paths

  - document type routing

- SOPs operate on:

  - extracted facts

  - summaries

### **7.2 V2 Retrieval (Add Qdrant Only If Needed)**

Add **Qdrant** when:

- corpus reaches hundreds/thousands

- recall/latency suffers

- keyword retrieval becomes brittle

## **8) Phase 8 — GPU Upgrade: Becoming the Monster Box**

### **Trigger**

- Output quality proven

- SOP workflows converge

- Performance is the only blocker

### **Upgrade**

- Add **1× 48 GB GPU  
  **

- Add NVMe if needed

### **Software Change**

- Swap inference backend:

  - llama.cpp → **vLLM  
    **

- No architectural rewrite

- Same API, same personas, same workflows

## **9) Phase 9 — Public Prototyping (Controlled)**

### **Goal**

Test Student/Tutor personas safely.

### **Approach**

- Same monolith

- Same OpenAI façade

- Strict rate limits

- Strict RAG grounding

- Separate quotas/model routing

### **Models**

- Student → small Qwen family

- Tutor → DeepSeek-R1 or mid-Qwen

## **10) Phase 10 — Integration with Atria LMS (Go + PHP)**

### **Pattern**

Atria treats the AI Monolith as a platform service:

- Chat for Tutor/Student

- Jobs for:

  - course generation

  - remediation plans

  - evaluation workflows

- Artifacts fetched by ID

RoadRunner aligns naturally with this.

## **11) Phase 11 — Scaling Beyond One Box (Only If Forced)**

### **Scaling Order**

1.  Second GPU box (public inference)

2.  More GPU boxes (horizontal)

3.  Separate Qdrant node

4.  DB replicas

**Never scale preemptively.**

## **Final Summary**

- Yes, the **efficient investment path** is:

  - CPU-only → prove quality

  - GPU-later → unlock performance

- Yes, **spec-first OpenAPI development** is the right move:

  - correctness

  - consistency

  - lower maintenance

- You end up with:

  - fewer dependencies

  - smaller attack surface

  - a system you understand end-to-end
