# **Atria Project Governance & Open Source Position Paper**

## **1. Purpose of This Document**

This document defines the **governance model, open source posture, and participation expectations** for the Atria project.

Its purpose is to:

- explain what Atria is and is not,

- describe how decisions are made,

- clarify how institutions and partners may participate,

- and prevent misunderstanding about responsibility, support, or influence.

Atria is an open source project with a **deliberate governance model**.  
Openness does not imply obligation, entitlement, or shared control.

## **2. What Atria Is**

Atria is an **open source learning execution platform**.

It is designed to:

- execute learning workflows deterministically,

- preserve auditable learner state,

- integrate with education standards as evidence,

- and enable institutions to own and control their learning systems.

Atria operates at the **execution and infrastructure layer**, not the content management layer.

## **3. What Atria Is Not**

Atria is not:

- a commodity LMS

- a SaaS product

- a vendor-hosted platform

- a feature-driven CMS

- a community-governed roadmap project

- a replacement for Canvas-style platforms

Atria is intended for institutions that value **ownership, auditability, and correctness** over convenience and vendor dependency.

## **4. Open Source Posture**

### **4.1 License**

Atria is released under the **GNU Affero General Public License (AGPL-3.0-or-later)**.

This license was chosen to:

- preserve freedom to use, study, modify, and fork,

- prevent enclosure of the platform into proprietary services,

- and ensure reciprocity when the platform is modified and operated as a network service.

Forking is explicitly permitted and encouraged when needs diverge.

### **4.2 Forking and Independence**

Institutions may:

- self-host Atria,

- fork the codebase,

- freeze a version indefinitely,

- or evolve their own variant.

Forking is treated as a **healthy outcome**, not a failure.

Atria does not require upstream contribution or alignment.

## **5. Governance Model**

### **5.1 Stewardship**

Atria follows a **single-steward governance model**.

The steward:

- maintains architectural coherence,

- stewards the core specifications,

- and protects the integrity of the platform.

This model prioritizes:

- clarity over consensus,

- coherence over popularity,

- and long-term integrity over rapid expansion.

### **5.2 Specifications as Authority**

Atria is governed by its **published engineering specifications**.

The specifications define:

- system behavior,

- architectural boundaries,

- execution semantics,

- and integration contracts.

Implementations are expected to conform to the specifications.

Requests that violate the core specifications are resolved by **forking**, not accommodation.

### **5.3 Contributions**

Atria does not operate as a traditional volunteer-driven open source project.

- There is no obligation to accept contributions.

- Pull requests may be reviewed at the steward’s discretion.

- Participation does not imply influence over direction.

Atria welcomes **use, feedback, and validation through real deployments**, not governance by committee.

## **6. Partner Community**

### **6.1 Who Atria Is For**

Atria is designed for institutions and organizations that:

- understand *free as in freedom*, not *free as in free beer*,

- already operate and maintain open source systems,

- value auditability and determinism,

- prioritize institutional autonomy,

- and seek to avoid vendor lock-in.

Atria assumes partners have the **culture and staff** to operate their own systems.

### **6.2 Role of Partners**

Partners contribute to Atria primarily by:

- deploying it in real environments,

- validating its operation at scale,

- identifying real constraints through use,

- and engaging in design discussions grounded in evidence.

Atria follows a **train-the-trainer** model.  
Partners are expected to build internal capability rather than rely on external support.

### **6.3 What Partnership Does Not Mean**

Partnership does not mean:

- roadmap control

- bespoke feature development

- operational support

- help desk services

- adaptation to procurement checklists

When needs diverge materially, forking is the appropriate path.

## **7. Relationship to Thermacube**

Thermacube is one of the organizations that deploys and operates Atria.

Thermacube:

- uses Atria in production environments,

- validates its real-world operation,

- and offers optional training and architectural guidance.

Thermacube does not:

- control institutional forks,

- require adoption of its services,

- or operate Atria as a universal SaaS platform.

Atria remains open and independent of any single operator.

## **8. Standards and Interoperability**

Atria supports education standards as **integration and evidence mechanisms**, not as governing authorities.

Standards such as:

- LTI

- QTI

- xAPI

- Caliper

- OneRoster

- Common Cartridge

are treated as inputs and outputs within a deterministic execution model.

Pedagogical authority resides within Atria’s workflow execution engine, not external tools.

## **9. Support and Expectations**

Atria is provided **as-is**.

There is:

- no free support,

- no SLA,

- and no on-call assistance.

Optional training and consulting may be available through third parties, including Thermacube.

Institutions adopting Atria are expected to take responsibility for operating and supporting their own deployments.

## **10. Final Statement**

Atria exists to enable learning systems that are:

- transparent,

- auditable,

- forkable,

- and ethically operated.

It is intentionally narrow in scope and selective in posture.

Institutions that value these principles are welcome.  
Institutions seeking convenience, dependence, or control are encouraged to pursue other solutions.

Upstream does not guarantee compatibility with downstream forks, nor does it coordinate or validate downstream integrations.

The selection and execution of a fork strategy is entirely the responsibility of the fork maintainer.

These models are described for clarity, not as recommendations.

The fork selectively cherry-picks specific upstream changes (such as security fixes or targeted bug patches) without broadly tracking upstream development.

Model C: Selective Integration

The fork periodically merges or rebases from upstream to incorporate fixes and improvements. All integration decisions, conflict resolution, and validation are fully owned by the fork maintainer.

Model B: Upstream-Tracking Fork

The fork diverges freely and does not routinely track upstream changes. Upstream releases may be referenced, but are not treated as dependencies.

Model A: Independent Fork

Fork maintainers may independently choose how (or whether) to incorporate upstream changes. Common patterns include:

Once a fork is created, Thermacube does not participate in downstream architectural, operational, or upgrade decisions.

Forking transfers full ownership of the resulting codebase to the fork maintainer.

4.2.1 Fork Models and Downstream Responsibility
