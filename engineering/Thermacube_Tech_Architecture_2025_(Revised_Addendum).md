Thermacube Tech Architecture 2025

Implementation Addendum Included (2025-12-16)

**Part 1. Introduction**

Thermacube’s architectural strategy is grounded in the principle that learning technologies must operate with clarity, reliability, and long-term maintainability. Over the past decade, software engineering practice has increasingly adopted complex distributed patterns such as microservices, heavy client-side rendering, and multi-layer orchestration pipelines. While these patterns are appropriate in certain large-scale or highly decomposed environments, they often introduce unnecessary fragility, operational overhead, and cognitive complexity in the context of learning management systems.

Educational institutions and corporate training organizations depend on predictable performance, assessment integrity, accessibility compliance, and transparent data governance. These institutional requirements call for an architecture that emphasizes conceptual coherence rather than fragmentation. Thermacube expresses this commitment through a modern reinterpretation of the majestic monolith pattern, embodied in the Atria Learning Management System.

This paper presents Thermacube’s architectural rationale and describes how Atria supports instructional design, institutional governance, global standards, and regulatory mandates. The document is organized into eight parts addressing architecture, learning design, institutional alignment, and regulatory frameworks.

**Atria and the Return to Institutional Software**

For the last decade, software development has been driven by a simple assumption: more abstraction equals more power. Microservices, orchestration layers, client-side applications, and distributed pipelines promised speed and scale. What they also delivered—quietly—was fragility. Across engineering and DevOps, experienced practitioners have converged on the same conclusion: complexity compounds faster than value, and institutions are the ones left carrying the risk. Atria is built on that realization.

**Earned Complexity and the Majestic Monolith**

Atria’s design follows a principle increasingly articulated by engineers such as David Heinemeier Hansson (DHH) and senior platform leaders at GitHub and Stripe: complexity must be earned.

Microservices are a tool, not a virtue. Most systems fail not because they cannot scale, but because they cannot be understood, operated, or maintained over time. By keeping execution within a majestically monolithic runtime, Atria delivers predictable performance, reduced security surface area, and operational clarity that survives staff turnover and vendor change. As DHH has argued, the monolith isn’t what breaks at scale — it’s people’s ability to understand their own service mesh.

Atria’s stack reflects another emerging consensus: performance and transparency are features of simplicity, not abstraction. As Carson Gross has argued, most applications do not need a client-side application runtime to feel modern. They need faster feedback loops and fewer moving parts. Atria chooses HTMX over SPA, which enables interactivity while preserving semantic HTML as the source of truth.

The result is accessible interfaces, deterministic assessment behavior, and observability that does not require heroic tooling. Institutions do not need magic; they need systems they can trust.

**Pedagogical Fidelity as a First-Class Concern**

Most learning platforms treat pedagogy as content layered on top of infrastructure. Atria treats pedagogy as executable intent.

The Business Process Model and Notation (BPMN) runtime is the critical distinction. Instructional design—sequencing, prerequisites, branching, remediation, and assessment rules—is encoded as deterministic workflows. What designers intend is what learners consistently experience across cohorts, whether the intended design offers complete freedom or a tightly regimented pathway.

This protects institutions from a costly failure mode: pedagogical drift. In “easy-to-use” systems, small changes accumulate into broken pathways, inconsistent assessments, and analytics that no longer reflect reality. Atria prevents this not through training or policy, but through execution guarantees.

This reflects a broader shift toward workflow-driven systems where correctness, auditability, and reproducibility matter more than ad hoc flexibility.

**The Next Wave Is Institutional Protection**

Atria represents a broader correction underway in development and DevOps: a move toward institutional software—systems designed for long-lived missions, regulated environments, and human organizations.

Earned complexity protects the platform. BPMN enforces pedagogical fidelity. A restrained, high-performance stack delivers transparency and security. Together, they protect the institution. Atria is built to ensure that when institutions invest in programs, faculty, and learners, the investment remains durable, defensible, and intact over time.

**Part 1.1 Architectural Thesis: The Majestic Monolith**

Atria adopts the majestic monolith model because it provides a cohesive environment for development, deployment, and long-term stewardship. This approach reduces the operational variability introduced by network-distributed components and allows the system to maintain predictable behavior across instructional and administrative workflows.

Key advantages include the following:

1.  Lower Cognitive Load  
    A unified codebase and execution environment simplify the mental models required for developing, maintaining, and supporting the system. Engineers and administrators can understand platform behavior without tracing interactions across distributed components.

2.  Predictable Performance  
    By avoiding distributed request patterns, Atria minimizes latency variance and achieves deterministic execution. This consistency is essential for reliable assessment delivery, learner engagement, and administrative stability.

3.  Security Through Simplicity  
    A limited number of components and communication pathways reduces the attack surface and enables security controls to be applied centrally. Logging, auditing, and monitoring are simpler and more complete when all critical operations occur within a well-defined boundary.

4.  Maintainability and Longevity  
    A monolithic architecture evolves incrementally without the need for large-scale re-platforming events. This is particularly important for learning ecosystems, where institutions require stability across multiple academic or fiscal cycles.

5.  Operational Stability  
    Backup, failover, disaster recovery, and deployment processes remain understandable and consistently executable. This model aligns with institutional expectations for continuity and supportability.

Thermacube recognizes that microservices can be beneficial for performance isolation or independent scaling, but these advantages must justify the operational and architectural cost. The Roadrunner runtime, used in conjunction with PHP and Go, provides a path for extracting specific performance-critical functions when necessary without requiring a fully distributed system by default.

**Part 1.2 Hosting Philosophy: Minimal Layers, Maximum Reliability**

Thermacube deploys Atria on hardened Linux hosts using direct or institution-controlled server administration. This model supports reliability by minimizing abstraction layers and ensuring that performance behavior is observable and controllable. Atria can run on-premises, in institutional private clouds, or on virtual machines provided by cloud vendors, but it does not require container orchestration or managed cloud services.

Thermacube’s hosting philosophy includes the following commitments:

1.  Minimization of Infrastructure Complexity  
    Atria avoids mandatory use of Kubernetes, service meshes, or distributed autoscaling frameworks. Institutions that prefer containerization may use Docker or Kubernetes, but these are not prerequisites for the platform’s operation.

2.  Predictable Operational Footprint  
    A small set of well-understood services—reverse proxy, Roadrunner, PHP workers, Go workers, and MariaDB—forms the complete runtime environment.

3.  Deployment Flexibility  
    Institutions may deploy Atria on their preferred VM providers, including DigitalOcean, Linode, or EC2, or operate entirely on-premises to satisfy data residency or governance requirements.

4.  Transparency and Observability  
    Institutions have full access to performance metrics, structured logs, and runtime health indicators without needing specialized cloud-native tooling.

**Part 1.3 DevOps Philosophy: Earned Complexity**

Thermacube implements a DevOps model designed to support reliability while avoiding unnecessary workflow overhead. The goal is to automate processes that reduce operational friction without adopting tools or paradigms whose complexity outweighs their benefits.

Core principles include the following:

1.  Simplicity in CI/CD  
    Atria uses minimal, readable deployment pipelines with immutable build artifacts and zero-downtime worker replacement.

2.  Pragmatic Infrastructure as Code  
    Configuration is automated where it reduces toil, but Thermacube avoids heavy IaC frameworks unless required by institutional policy.

3.  Operational Transparency  
    Observability is delivered through Prometheus-compatible metrics, structured logs, and optional OpenTelemetry traces, supporting institutional monitoring without mandating specific vendor stacks.

4.  Disaster Recovery as a Regular Practice  
    Thermacube conducts periodic disaster recovery exercises to validate restoration workflows and align with institutional continuity standards.

**Part 1.4 Application Runtime: PHP, Go, and Roadrunner**

Atria uses PHP 8 for domain logic, Go for performance-critical or long-running tasks, and Roadrunner as the high-performance application server connecting them. This hybrid model provides both developer ergonomics and enterprise-grade performance.

1.  PHP 8 as the Domain Layer  
    PHP’s expressive syntax, modern type system, and robust library ecosystem make it well suited for request–response interactions, templating, and business logic.

2.  Go for Concurrency and High Throughput  
    Go workers are used for media processing, batch data handling, analytics pipelines, and other tasks requiring concurrency or sustained performance.

3.  Roadrunner as the Unified Runtime  
    Roadrunner provides a long-lived worker architecture, predictable request processing, and optional queueing, allowing Atria to remain monolithic while still scaling efficiently.

**Part 1.5 Framework Philosophy: Tools, Not Worldviews**

Thermacube uses Spiral components selectively for routing, dependency injection, validation, and worker orchestration. The platform maintains a clear separation between framework utilities and domain logic. This prevents framework lock-in and preserves the longevity of the codebase. Thermacube’s approach follows the principle that frameworks should serve the application, not define it.

**Part 1.6 Front-End Philosophy: Server-Driven UI with HTMX**

Atria uses a server-driven interface model enhanced by HTMX to support interactivity without introducing complexity associated with large client-side frameworks. This model improves accessibility, reduces cognitive load for instructional designers, and ensures UI consistency across devices.

1.  Accessibility  
    Server-rendered HTML maintains semantic structure across updates, supporting screen readers and assistive technologies.

2.  Performance  
    HTMX enables partial updates with minimal client overhead, improving responsiveness in low-bandwidth environments.

3.  Stability  
    Centralized rendering avoids framework churn and reduces maintenance burden for institutions.

Atria exposes APIs for institutions that wish to build SPA-based administrative tools, but HTMX remains the optimal default for learner and instructor interfaces.

**Part 1.7 Data Philosophy: MariaDB as the Source of Truth**

Atria uses MariaDB to provide ACID-compliant relational storage with predictable performance. Institutions benefit from clear schema evolution, robust transaction guarantees, and standards-based export formats. Distributed read replicas are supported when needed, but Atria does not assume complex distributed database topologies by default.

**Part 1.8 Security Philosophy: Layered Controls and Predictable Boundaries**

Atria implements a defense-in-depth security model aligned with OWASP Top Ten and ASVS standards. Security is integrated into every architectural layer, including the operating system, application runtime, data store, and user interface.

Key elements include the following:

1.  Centralized Access Control  
    Authentication uses OIDC, and authorization follows a hybrid RBAC–ABAC model.

2.  Input and Output Validation  
    All data is validated and escaped in context to prevent injection and cross-site scripting.

3.  Separation of Privilege  
    Roadrunner and PHP workers operate within restricted system accounts, and database users follow least-privilege policies.

4.  Secure Interactions  
    HTMX endpoints are fully authenticated and include CSRF protection. All interactions occur over HTTPS.

5.  Monitoring and Logging  
    Structured logs support correlation, auditability, and security analysis.

**Part 1.9 Conclusion**

Atria’s architectural foundation reflects Thermacube’s commitment to clarity, maintainability, and institutional stewardship. The platform avoids unnecessary complexity while providing flexible integration points and standards alignment. These principles support long-term durability, accessibility, and instructional quality across higher education, corporate training, and public-sector environments.

**Part 2. Architecture Deep Dive**

This section expands the architectural philosophy introduced in Part 1 by examining Atria’s operational foundation, execution model, data management practices, and security posture. The goal is to illustrate how Thermacube’s design choices translate into concrete behaviors that support reliability, instructional integrity, maintainability, and institutional governance requirements.

**Part 2.1 Hosting and Infrastructure**

Atria operates on a predictable, transparent infrastructure model designed to reduce operational overhead while supporting institutional control over data and performance. Thermacube deploys Atria on hardened Linux hosts using standard virtual machine environments, which allows institutions to maintain governance over hosting strategy without dependence on proprietary cloud-native tooling.

**Part 2.1.1 Minimal Abstraction Layers**

Atria does not require Kubernetes, service meshes, or autoscaling orchestrators. While the platform can be containerized for institutions that prefer Docker or Kubernetes, these technologies are optional. Operating without them reduces failure modes, simplifies observability, and allows institutions to reason directly about application behavior.

**Part 2.1.2 Network Topology**

Atria uses a layered network model in which a reverse proxy manages TLS termination, routing, and rate limiting. Roadrunner handles application traffic internally, and MariaDB operates on private interfaces not exposed externally. This separation limits attack surface and creates clear enforcement points for institutional firewall rules and endpoint protections.

**Part 2.1.3 Deployment Flexibility**

Atria may be deployed on institutional data centers, private clouds, or virtual machine providers such as DigitalOcean, Linode, or Amazon EC2. Because the platform does not rely on cloud-managed services, institutions retain full control over data residency, resource allocation, and disaster recovery practices.

**Part 2.2 Application Runtime**

Atria’s execution model integrates PHP 8 for primary domain logic, Go for concurrency-intensive and long-running tasks, and Roadrunner as the unified Go-based application server. This hybrid model optimizes performance while preserving the cohesive properties of a monolith.

**Part 2.2.1 PHP 8 for Business Logic**

PHP 8 provides modern type declarations, improved performance characteristics, and an extensive ecosystem of mature libraries. The language aligns particularly well with server-side rendering, input validation, templating, and assessment workflows. PHP’s stability and maturity also support Thermacube’s commitment to predictable long-term maintenance.

**Part 2.2.2 Go for Concurrency and High Throughput**

Go workers support media processing, batch data handling, analytics event batching, and scheduled tasks. These workers operate inside the monolithic boundary but can be scaled independently to handle variable workloads. Because Go binaries are static and resource efficient, they enable high-throughput processing without introducing external system dependencies.

**Part 2.2.3 Roadrunner as the Execution Core**

Roadrunner provides long-lived PHP workers, internal queueing capabilities, and consistent concurrency handling. Its predictable memory model and performance characteristics allow Atria to serve thousands of concurrent learners with minimal overhead. Roadrunner’s queue plugin supports multiple backends, including RabbitMQ, Amazon SQS, Beanstalk, and local durable queues. This flexibility supports asynchronous processing needs without forcing institutions to adopt heavy distributed architectures.

**Part 2.3 Framework and Modular Organization**

Atria uses components of the Spiral framework selectively, including routing, middleware pipelines, validation tools, dependency injection, and worker orchestration. Domain logic remains independent of the framework. This design prevents framework lock-in and ensures that the codebase remains accessible to new developers.

Thermacube takes a pragmatic stance toward domain organization. Rather than adopting the rigid internal boundaries associated with formal Domain-Driven Design (DDD), Atria follows the architectural philosophy of the majestic monolith. Code is organized through conventions and architectural guidance, but boundaries remain permeable to preserve the efficiency and clarity of a unified system.

**Part 2.4 Front-End Architecture**

Atria adopts a server-driven UI model enhanced by HTMX. This approach preserves accessibility, reduces maintenance burden, and supports rapid instructional iteration.

**Part 2.4.1 Server-Rendered HTML**

Server-rendered pages maintain consistent semantics across browsers and assistive technologies. This supports accessibility guidelines and reduces client-side complexity. Because rendering logic is centralized, UI changes are predictable and auditable.

**Part 2.4.2 HTMX for Progressive Interaction**

HTMX allows selective, incremental updates to page content without requiring a full single-page application framework. This results in faster load times, lower CPU usage on the client device, and a more inclusive experience for learners using older hardware or low-bandwidth connections.

**Part 2.4.3 API Integration for SPA Workflows**

Although Atria defaults to server-driven interfaces, the platform exposes JSON-based APIs documented with OpenAPI (OAS3). Institutions that wish to develop SPA-based administrative interfaces or custom dashboards may do so without compromising Atria’s architectural clarity.

**Part 2.5 Asynchronous Processing**

Certain LMS workflows require high-throughput, asynchronous processing. Atria supports these through Roadrunner’s queue subsystem and Go workers.

**Part 2.5.1 Message Queue Capabilities**

Atria supports multiple queue backends, including in-memory queues, local BoltDB-backed queues, RabbitMQ, and Amazon SQS. These backends enable batch SIS synchronization, analytics event batching, email notifications, media processing, and scheduled reporting.

**Part 2.5.2 Earned Complexity in Worker Design**

Thermacube applies its earned-complexity principle to determine when asynchronous workflows are appropriate. Tasks that demonstrate clear performance or reliability benefits may be routed through queue-backed workers, while simpler tasks remain inline for clarity.

**Part 2.6 Data Architecture**

Atria uses MariaDB as its relational datastore, providing ACID guarantees and predictable performance characteristics.

**Part 2.6.1 Relational Consistency**

A single-source-of-truth relational model ensures that learner records, assessment results, credential artifacts, and course configurations remain coherent across workflows. Referential integrity prevents data drift and supports accurate reporting.

**Part 2.6.2 Multi-Tenant Isolation**

Each tenant operates on a separate database instance. This model guarantees strong isolation, simplifies archival processes, and supports per-tenant retention and deletion policies. Tenant-level branding, configuration, and identity integration are handled without compromising data segregation.

**Part 2.6.3 Schema Stability and Evolution**

MariaDB’s structured schema supports careful, versioned evolution of data models. Institutions may rely on stable identifiers and fields for analytics, institutional research, assessment validity, and accreditation reporting.

**Part 2.7 Security Architecture**

Security is integrated across all layers of Atria’s architecture.

**Part 2.7.1 OWASP-Aligned Controls**

Atria’s design reflects the OWASP Top Ten and ASVS models. Input validation, output encoding, least-privilege access, and secure session management form the foundation of Atria’s secure operation.

**Part 2.7.2 Defense in Depth**

Linux hardening, PHP worker isolation, private network bindings for MariaDB, and TLS termination at the reverse proxy create layered defenses against intrusion.

**Part 2.7.3 Observability for Security**

Structured JSON logs, Prometheus metrics, and optional OpenTelemetry traces support anomaly detection, incident investigation, and forensic analysis.

**Part 2.8 Summary**

Atria’s architecture integrates PHP, Go, Roadrunner, MariaDB, and HTMX within a cohesive monolithic design. This combination supports high-performance operation, accessibility, maintainability, and robust security while avoiding the complexity of distributed systems. The result is an architecture well suited to institutional learning environments, where reliability and governance are critical.

**Part 3. Implications for Learning Design and Instructional Practice**

Atria’s architectural decisions directly shape instructional design workflows, user experience quality, and the overall effectiveness of learning environments. A learning management system should not merely deliver content; it should support cognitive clarity, instructional flexibility, assessment reliability, and inclusive access for all learners. This part explains how Thermacube’s design philosophy enhances learning outcomes and supports instructional designers, faculty, and students.

**Part 3.1 Consistency of the Learning Experience**

Learners benefit from predictable interaction patterns, consistent layouts, and interface stability across courses and activities. Atria’s server-driven rendering ensures that user interfaces behave consistently regardless of device type or browser configuration. Consistency reduces cognitive load, allowing learners to focus on content mastery rather than navigation or interface interpretation. This is especially important for institutions with broad demographic diversity, including adult learners, multilingual learners, and learners with disabilities.

**Part 3.2 Accessibility and Inclusive Design**

Accessibility is embedded into Atria’s core architecture. Server-rendered HTML maintains semantic structure across updates, which supports screen readers, keyboard navigation, and assistive technologies without requiring specialized client-side accommodations. HTMX interactions preserve semantic relationships and accessible states, minimizing the risk of inaccessible dynamic content. As a result, instructional designers inherit accessible defaults, reducing the need for post-hoc remediation and aligning with institutional commitments to universal design for learning.

**Part 3.3 Assessment Stability and Reliability**

Assessment workflows require strong guarantees of stability and fairness. Atria centralizes all assessment logic, scoring evaluations, timing controls, and attempt tracking on the server. This avoids inconsistencies introduced by client-side execution and ensures that learners receive equitable and reliable assessment experiences. Timed assessments, branching logic, adaptive sequences, and eligibility rules all operate within deterministic BPMN-defined workflows. This consistency supports accreditation requirements, program evaluation, and the integrity of high-stakes assessments.

**Part 3.4 Implications for Instructional Designers**

Instructional designers depend on stable authoring workflows, predictable behavior, and efficient iteration cycles. Atria’s cohesive architecture ensures that changes to content, logic, or course configuration propagate reliably across learner views. Designers can preview content in a sandbox environment before releasing updates to active cohorts, reducing the risk of unintended instructional disruptions. Because primary UI rendering occurs on the server, designers can focus on pedagogy rather than managing front-end framework behavior.

**Part 3.5 Learning Analytics and Program Evaluation**

Atria’s unified data model provides a reliable basis for analytics and evaluation. Interactions, assessments, progress markers, and engagement patterns are captured consistently through server-side events. Atria supports xAPI and Caliper specifications to provide structured data streams for institutional research, program evaluation, and quality assurance. These analytics enable instructional designers and learning scientists to identify learning bottlenecks, evaluate instructional strategies, and support evidence-based improvements across courses and programs.

**Part 3.6 Instructional Workflow Flexibility**

Instructional design requires flexibility in sequencing, branching, and conditional logic. Atria’s BPMN-based workflow model enables fine-grained control over learning paths, prerequisites, remediation steps, and mastery-based progression. Workflow versions are frozen at the cohort level, ensuring instructional integrity while enabling iteration in future offerings. This duality supports both stability and continuous improvement.

**Part 3.7 Faculty Support and Ease of Adoption**

Faculty and instructors benefit from a coherent system that minimizes configuration overhead and reduces variability between courses. Atria’s design ensures that common tasks such as grading, rubric evaluation, progress monitoring, and content updates are predictable and intuitive. Instructors can adopt and use Atria without extensive technical training, and the platform’s consistent interaction patterns reduce faculty support burden.

**Part 3.8 Summary**

Atria strengthens the instructional environment by providing accessible, consistent, and reliable learning experiences. Its server-driven design, workflow configurability, deterministic assessment logic, and analytics capabilities support the goals of instructional designers, faculty, and learning support teams. These characteristics position Atria as an environment that prioritizes pedagogy, equity, and long-term instructional integrity.

**Part 4. Standards Compliance and Interoperability**

Learning ecosystems rely on interoperability standards that ensure systems can communicate reliably, exchange data meaningfully, and preserve instructional integrity across platforms. Atria is designed to operate within this standards ecosystem by supporting the 1EdTech (formerly IMS Global) and Advanced Distributed Learning (ADL) specifications. These standards enable institutions to integrate existing learning assets, maintain compatibility with external tools, and build sustainable workflows for teaching, assessment, and analytics.

**Part 4.1 Alignment with 1EdTech Standards**

Atria implements the major standards published by the 1EdTech Consortium. These standards support interoperability between learning systems, content providers, credentialing systems, and analytics platforms.

**Part 4.1.1 Learning Tools Interoperability (LTI) 1.3 and LTI Advantage**

Atria supports LTI 1.3 and the LTI Advantage service suite, including Names and Roles Provisioning Services (NRPS), Assignment and Grade Services (AGS), and Deep Linking. These capabilities allow external tools to integrate seamlessly with Atria while maintaining secure, standards-based authentication and authorization flows. The monolithic architecture ensures consistent evaluation of LTI messages and predictable grade return workflows.

**Part 4.1.2 Question and Test Interoperability (QTI)**

Atria supports QTI as a format for assessment items, pools, rubrics, and metadata. Server-driven rendering ensures consistent interpretation of item structure, scoring rules, and adaptive pathways. The centralized assessment engine maintains reliability across course offerings and supports import and export workflows.

**Part 4.1.3 Common Cartridge and Thin Common Cartridge**

Atria supports Common Cartridge (CC) and Thin CC for sharing course materials across LMS platforms. Designers may export cartridges containing content, metadata, and assessments, or import existing cartridges from publishers and partner institutions. Thin CC support enables linking to external content repositories while preserving metadata integrity.

**Part 4.1.4 OneRoster**

Atria aligns with OneRoster for SIS integration, enabling batch and API-based synchronization of users, classes, enrollments, and rosters. Go-based workers support large-scale imports and exports without disrupting the main application runtime.

**Part 4.1.5 Caliper Analytics**

Atria uses Caliper to generate learning activity metrics that conform to 1EdTech’s JSON-LD analytics model. These events may be routed to institutional analytics pipelines or data warehouses, supporting program evaluation, retention analysis, and learning research.

**Part 4.1.6 Open Badges and LRMI**

Atria supports Open Badges for credential issuance and LRMI metadata for resource classification. These standards facilitate recognition of learning outcomes and improve discoverability of learning resources.

**Part 4.1.7 CASE Framework**

Atria aligns with the Competency and Academic Standards Exchange (CASE) to support outcome mapping, competency-based education, and skill alignment across assessments and learning pathways.

**Part 4.2 Alignment with ADL Standards**

Atria supports standards published by the Advanced Distributed Learning (ADL) Initiative, which govern content packaging, runtime communication, and learning activity tracking.

**Part 4.2.1 SCORM 1.2 and SCORM 2004**

Atria provides server-side management of SCORM packages, including API discovery, suspend data handling, and completion tracking. Centralizing SCORM communication on the server avoids client-side inconsistencies and preserves the integrity of training records.

**Part 4.2.2 Experience API (xAPI)**

Atria generates xAPI statements for learner interactions and supports batching through Go workers. xAPI provides detailed activity tracking across tools and allows institutions to aggregate learning data for evaluation, compliance reporting, or research.

**Part 4.2.3 cmi5**

Atria supports cmi5’s launch and tracking requirements, combining SCORM-structured course logic with xAPI data streams. The monolithic architecture provides predictable enforcement of cmi5 session rules and consistent event capture.

**Part 4.3 Additional Standards for Registrarial and Corporate Contexts**

Atria integrates with standards relevant to credentialing, continuing education, and corporate training.

**Part 4.3.1 PESC Standards**

Atria can integrate with PESC-aligned transcript and credential systems when institutions require conformity to PESC XML models for student records and registrarial workflows.

**Part 4.3.2 HR-XML and Workforce Standards**

For corporate training environments, Atria supports alignment with competency frameworks used in HR-XML and related SHRM-aligned job architecture models. These connections enable mapping between job roles, competencies, and learning pathways.

**Part 4.4 Interoperability Design Principles**

Thermacube follows several design principles that govern interoperability across all components.

1.  Standards as First-Class Entities  
    Standards-based interactions are implemented as stable, documented interfaces that align with institutional expectations for long-term interoperability.

2.  Stability Across Versions  
    Atria supports backward compatibility for API contracts and content import/export workflows. Breaking changes are communicated with clear timelines and migration guidance.

3.  Cohesion Within the Application  
    Unlike distributed systems that implement standards across multiple microservices, Atria provides centralized logic for standards handling. This reduces the risk of inconsistent behavior across workflows.

**Part 4.5 Summary**

Atria’s standards alignment ensures compatibility with instructional tools, content providers, credentialing systems, analytics environments, and enterprise architectures. By supporting 1EdTech, ADL, PESC, CASE, and workforce-aligned models, the platform integrates cleanly into diverse learning ecosystems. Standards compliance strengthens instructional reliability, enables program evaluation, and supports institutional governance expectations.

**Part 5. Enterprise Readiness and Operational Governance**

Atria’s architecture is designed not only for instructional quality but also for operational stability, institutional governance, and enterprise integration. Institutions require platforms that are secure, supportable, scalable, and aligned with established IT norms. This part explains how Atria supports enterprise-grade operational practices, identity management, observability, multi-tenancy, disaster recovery, and compliance with institutional technology policies.

**Part 5.1 High Availability and Disaster Recovery**

Atria supports operational continuity through an active–passive failover model. The primary instance processes all traffic, while a passive standby instance is preconfigured to take over in the event of primary failure. This approach limits operational complexity while enabling predictable recovery.

**Part 5.1.1 Database Redundancy**

MariaDB operates with a single primary database and asynchronous replicas hosted locally within the same region. Replica promotion is supported when institutions require continuity despite hardware or datacenter failures. The Recovery Time Objective (RTO) for a full primary loss is twenty-four hours, and the Recovery Point Objective (RPO) approaches zero because no new transactions occur while the system is unavailable.

**Part 5.1.2 Disaster Recovery Exercises**

Thermacube conducts periodic disaster recovery exercises to validate replica promotion processes, restoration workflows, and institutional failover expectations. Institutions may review test plans or participate directly in these exercises to align Atria’s DR posture with their own continuity standards.

**Part 5.2 Multi-Tenancy and Client Isolation**

Atria uses a strongly isolated multi-tenant model in which each tenant is assigned a separate database schema. This approach ensures that tenant data, configuration, identity endpoints, and credentials remain independent. Isolation mechanisms support institutional data governance policies and mitigate risk associated with cross-tenant leakage.

**Part 5.2.1 Customization at the Tenant Level**

Tenant-specific branding, configuration parameters, LTI credentials, and theme logic may be applied without affecting other tenants. Tenants may optionally publish selected learning resources for public consumption or controlled sharing.

**Part 5.3 Identity and Access Management**

Atria adopts an OpenID Connect (OIDC)–first identity model and integrates with Shibboleth, Okta, and PingFederate. Institutions may configure their own identity providers to maintain control over authentication flows and user lifecycle management.

**Part 5.3.1 Role and Attribute-Based Control**

Authorization uses a hybrid Role-Based Access Control (RBAC) and Attribute-Based Access Control (ABAC) model. RBAC aligns with LTI and OneRoster role semantics, while ABAC provides granular control based on attributes such as academic unit, job function, or program affiliation. Institutions may create custom roles or attributes to satisfy internal governance needs.

**Part 5.3.2 SCIM and Identity Governance**

Atria supports SCIM-aligned identity provisioning. Institutions may provision, update, or deactivate user accounts and roles automatically using institutional identity governance workflows. Group-based role assignment ensures consistent authorization across both UI and API surfaces.

**5.3.3 Credential Finality and Non-Retroactivity**

Atria SHALL NOT retroactively invalidate, reinterpret, or revoke a learner’s completed course, activity, or credential due to later changes in workflows, activities, assessments, or content.

Completions and credentials are evaluated exclusively under the workflow version and artifact versions in effect at the time the learner completed the course.

Subsequent updates apply **prospectively** and SHALL NOT alter historical outcomes.

If an institution requires prior completers to satisfy new requirements, this SHALL be implemented through explicit re-enrollment or recertification mechanisms and SHALL NOT be implied by course updates.

**Part 5.4 Observability and Operational Insight**

Atria provides a modern, lightweight observability stack that integrates with institutional monitoring tools without imposing unnecessary complexity.

**Part 5.4.1 Metrics and Tracing**

Atria exposes Prometheus-compatible metrics for performance monitoring. Optional OpenTelemetry tracing supports deeper inspection of request flows when institutions require granular diagnostics.

**Part 5.4.2 Structured Logging**

All application logs are emitted in structured JSON format with correlation identifiers. Logs may be ingested into any SIEM or log aggregator chosen by the institution, enabling comprehensive incident investigation, audit analysis, and performance tuning.

**Part 5.5 Integration and Extensibility**

Atria supports integration with institutional systems through REST APIs, webhook notifications, and standards-based import/export workflows.

**Part 5.5.1 API Design and Documentation**

Atria’s public APIs are documented using OpenAPI (OAS3). Each exposed endpoint is treated as a first-class integration surface and follows consistent conventions. While Atria does not adopt semantic versioning for APIs, Thermacube maintains backward compatibility and communicates breaking changes with clear migration guidance.

**Part 5.5.2 Webhooks and Batch Import/Export**

Webhook notifications allow institutions to incorporate Atria events into their broader enterprise architecture. Batch import and export workflows support SIS synchronization, reporting pipelines, and large-scale enrollment updates.

**Part 5.6 Release Management and Quality Assurance**

Thermacube practices disciplined release management to support institutional expectations for stability and transparency.

**Part 5.6.1 Release Cadence**

Mainstream updates, including bug fixes and security patches, are delivered on a semiannual schedule. Critical security hotfixes are delivered within seventy-two hours of discovery. Release notes and version tags are published publicly for transparency.

**Part 5.6.2 Backward Compatibility**

Atria preserves backward compatibility for instructional workflows, program logic, API behavior, and data schemas whenever possible. When breaking changes are required, Thermacube provides migration documentation, timelines, and advanced notice.

**Part 5.7 Support Model and Operational Commitments**

Atria uses a tiered support structure that aligns with institutional practices. Institutions handle tier 1 support after receiving training from Thermacube, while Thermacube handles tier 2 and tier 3 support during regular business hours.

**Part 5.7.1 Uptime and SLO Expectations**

Atria maintains service-level objectives for availability, response time, and resolution time. An uptime dashboard provides real-time visibility into platform performance.

**Part 5.8 Organizational Stewardship and Open-Source Governance**

Thermacube maintains an open-source stewardship model that supports long-term sustainability of the Atria platform. Public documentation, architectural specifications, and contribution guidelines mitigate vendor risk and ensure that institutions retain the ability to operate or extend the platform independently. Governance practices emphasize stability, transparency, and continuity.

**Part 5.9 Summary**

Atria’s enterprise readiness reflects Thermacube’s commitment to operational clarity, governance alignment, and reliable performance. The platform integrates identity management, observability, multi-tenancy, disaster recovery, and disciplined release management in a cohesive architecture that supports institutional missions and long-term sustainability.

**Part 6. Learning Design Analysis of Atria**

Atria’s architecture and feature set were designed with explicit consideration for learning design (LD) principles and instructional effectiveness. The platform supports instructional designers, faculty, and learning support staff by emphasizing accessibility, consistency, workflow clarity, and data-driven evaluation. This part examines Atria from the perspective of learning design theory, instructional practice, and cognitive considerations relevant to teaching and training.

**Part 6.1 Alignment with Learning Design Principles**

Atria supports foundational learning design principles, including clarity of navigation, consistency of interaction, and structured sequencing. By reducing extraneous cognitive load, the platform enables learners to allocate attention to instructional content rather than interface interpretation.

Atria’s server-driven UI ensures predictable behavior across modules, reducing unnecessary variability and strengthening the alignment between course design intentions and learner experience. This predictability supports effective scaffolding and sequencing strategies used in higher education and corporate training environments.

**Part 6.2 Support for Universal Design for Learning (UDL)**

Atria’s accessible-by-default architecture aligns with the Universal Design for Learning framework by reducing barriers to access and offering structured flexibility for learners. Server-rendered HTML ensures compatibility with screen readers and assistive technologies, while consistent component semantics reduce the risk of inaccessible dynamic states.

Instructional designers benefit from accessible templates and predictable focus behaviors, which reduce remediation workload and support the creation of inclusive learning materials. Because Atria’s markup and interaction patterns are centrally controlled, accessibility improvements propagate consistently across the platform.

**Part 6.3 Instructional Sequencing Through BPMN Workflows**

Atria’s workflow engine enables structured learning paths grounded in Business Process Model and Notation (BPMN). This approach supports mastery-based progression, conditional branching, prerequisite enforcement, and remediation workflows. Designers can define repeatable instructional experiences that align with pedagogical goals, while Atria preserves the integrity of workflow versions across cohorts.

This BPMN-driven model ensures that instructional intent is captured precisely and that learners move through content according to designed sequencing rules. Workflow versioning protects instructional coherence for each cohort, supporting fairness, auditability, and accreditation requirements.

**Part 6.4 Reliability of Assessment Delivery**

Assessment reliability is central to learning design. Atria centralizes scoring logic, timing behavior, eligibility conditions, and attempt tracking on the server to preserve the fidelity of assessment experiences. Timed assessments, adaptive branching, and rubric-based evaluations function without client-side dependencies, preventing inconsistencies associated with browser or device variability.

Instructional designers and faculty can rely on consistent behavior during high-stakes assessments, enabling them to design more sophisticated and pedagogically meaningful evaluation strategies.

**Part 6.5 Sandbox and Preview Environments for Designers**

Atria supports faculty and instructional designers by providing sandbox environments for previewing and validating course changes before publishing. Designers can test workflow logic, content updates, assessments, and accessibility improvements without affecting active learner cohorts. This separation between design and delivery environments reduces instructional risk and enables iterative refinement of course materials.

**Part 6.6 Support for Multimedia and Interactive Learning Assets**

Atria’s architecture supports integrated multimedia content, including video, simulations, and interactive visualizations. Go-based workers process media as needed, and server-driven delivery ensures consistent behavior across devices. Instructional designers may incorporate standards-aligned assets such as SCORM packages, xAPI-based activities, or QTI-based assessments without concern for client-side inconsistencies.

**Part 6.7 Learning Analytics and Evidence-Based Design**

Atria’s unified data model supports data-driven learning design. Structured xAPI and Caliper event capture enable designers to understand how learners engage with materials, identify friction points, and evaluate the effectiveness of instructional strategies. Because analytics are derived from consistent server-side events, designers can trust the validity of the data for program evaluation and continuous improvement initiatives.

**Part 6.8 Instructor Cognitive Flow and Workflow Support**

Atria reduces complexity for faculty by providing uniform workflows for grading, content updates, assessment review, and learner communication. Consistency across tools reduces training requirements for faculty and helps maintain instructional continuity across academic terms. Because Atria’s UI logic is managed centrally, instructors can rely on stable behaviors that align with instructional design patterns and department expectations.

**Part 6.9 Academic Integrity and Transparency**

Atria supports academic integrity by ensuring deterministic scoring and prohibitively restricting AI involvement during assessments. Faculty retain control over AI-assisted interactions and can require transparency or disable AI entirely for specific workflows. These features align with institutional academic integrity policies and support faculty governance structures.

**Part 6.10 Summary**

Atria’s learning design alignment is an expression of Thermacube’s commitment to instructional quality. By supporting accessible, predictable, workflow-driven, and data-informed learning environments, Atria empowers faculty, instructional designers, and learning support teams to create effective and inclusive learning experiences. The platform’s architecture functions in service of pedagogy rather than in tension with it, ensuring that instructional intent is preserved and supported across contexts.

**Part 7. Institutional Alignment and Governance**

Institutions require learning platforms that support not only instruction and assessment but also governance, compliance, and long-term operational stewardship. Atria’s design reflects the needs of a wide range of institutional stakeholders, including accessibility services, registrars, procurement teams, faculty governance bodies, data architects, accreditation agencies, and student support services. This part synthesizes these institutional perspectives and demonstrates how Atria aligns with their requirements.

**Part 7.1 Accessibility and Disability Support Services**

Atria’s server-driven HTML architecture supports accessibility by providing consistent semantic markup, predictable component behavior, and compatibility with assistive technologies. These characteristics align with WCAG, Section 508, and ADA mandates. Because Atria centralizes rendering logic, accessibility improvements propagate uniformly across the platform. Accommodations such as extended time on assessments, alternate workflows, and controlled retake logic are implemented at the server level, supporting compliance with institutional accommodation policies and reducing remediation burden.

**Part 7.2 Registrar, Records Governance, and Credential Integrity**

Institutions rely on accurate and immutable academic records. Atria ensures the integrity of those records by centralizing scoring, attempt tracking, and credential issuance within deterministic BPMN-defined workflows. Each grade, assessment attempt, and credential artifact is logged and traceable to its originating course version and workflow. This data provenance supports transcript generation, grade audits, accreditation reviews, and dispute resolution. Workflow versioning ensures that cohorts follow the instructional structure defined at the start of the term, preserving fairness and record consistency.

**Part 7.3 Institutional Research, Accreditation, and Quality Assurance**

Atria provides consistent and reliable learning activity data to support program evaluation and accreditation processes. Server-side event handling ensures that learning analytics reflect actual learner behavior rather than device or browser variations. Support for xAPI and Caliper enables integration with institutional data warehouses and analytics platforms. These capabilities enable longitudinal studies, outcome mapping, retention analysis, and evidence-based reporting required by accreditation bodies and institutional research offices.

**Part 7.4 Advising, Retention, and Student Support**

Student support teams require timely and accurate indicators of performance and engagement. Atria captures engagement signals and progress markers through consistent server-side events. These data streams support advising dashboards, early-alert mechanisms, intervention workflows, and student success initiatives. Institutions can use Atria’s APIs to integrate learner data into advising systems or student support analytics platforms.

**Part 7.5 Procurement, Legal, and Risk Management**

Procurement and legal offices evaluate platforms for data ownership clarity, risk exposure, compliance posture, and long-term sustainability. Atria aligns with SOC 2 principles and supports controlled access, audit logging, structured incident response, and institution-driven retention and deletion policies. Institutions retain full ownership of learner data and may export records at any time. Atria’s open-source stewardship model ensures long-term viability by providing documentation, transparent governance, and the ability for institutions to self-host or extend the platform.

**Part 7.6 Enterprise Data, Integration, and Architecture Teams**

Atria integrates into enterprise architectures through REST APIs, webhook notifications, batch imports and exports, and adherence to standards such as OneRoster, Common Cartridge, QTI, and CASE. Public APIs are documented using OpenAPI (OAS3), and Atria maintains backward compatibility for integration surfaces. Structured data formats, including JSON, CSV, XML, and JSON-LD, support ETL workflows and data warehouse ingestion. Because Atria’s schema evolves through controlled versioning, enterprise teams can rely on stable identifiers and predictable data flows.

**Part 7.7 Library, OER, and Learning Resource Services**

Libraries and OER programs require stable metadata, content preservation, and discoverability. Atria supports LRMI for metadata labeling and preserves stable links to learning resources. Server-rendered content ensures long-term usability of archived materials. Atria’s content packaging workflows support publisher assets, open educational resources, and long-term preservation practices in alignment with institutional repository standards.

**Part 7.8 Communications, Branding, and External Engagement**

Branding consistency and public-facing communication are critical for institutions delivering microcredentials, professional development courses, or continuing education programs. Atria’s multi-tenant model supports institution-specific branding, public landing pages, and externally visible credential artifacts. These features support marketing, corporate partnerships, and community outreach initiatives.

**Part 7.9 Continuing Education and Workforce Development**

Atria supports non-credit and workforce programs through flexible registration models, microcredential workflows, Open Badges, and BPMN-driven learning pathways. Because these programs often operate outside of traditional SIS cycles, Atria provides standards-aligned data exports and credential structures that support employer verification, professional development tracking, and compliance reporting.

**Part 7.10 Finance, Budgeting, and Business Officers**

Financial officers evaluate platforms based on total cost of ownership, sustainability, and predictability. Atria minimizes infrastructure expenditure by avoiding mandatory cloud-native services and operating effectively on modest VM deployments. Operational simplicity reduces staffing requirements and long-term support costs. These design characteristics provide budgetary stability and align with fiduciary responsibilities for technology stewardship.

**Part 7.11 Faculty Governance, Academic Freedom, and Pedagogical Integrity**

Atria aligns with faculty governance expectations by supporting instructional autonomy and academic integrity. Deterministic scoring, cohort versioning, and transparent workflow logic ensure fairness and instructional consistency. Atria’s AI-assisted features are transparent, auditable, and subordinate to instructor judgment. Faculty may disable AI features where needed and request explainability for AI-generated recommendations.

**Part 7.12 Cybersecurity Governance and Audit Committees**

Cybersecurity governance committees require evidence of strong security posture, audit readiness, and policy compliance. Atria’s OWASP-aligned controls, structured logging, privilege separation, and secure configuration practices support these requirements. Incident response procedures, log retention policies, and data residency options align with institutional governance expectations. Atria may be deployed on FedRAMP-authorized infrastructure when necessary for governmental compliance.

**Part 7.13 IT Help Desk, Training, and Operational Support Units**

Atria’s consistent UI, structured error messages, and predictable workflow behavior enable IT help desk teams to provide efficient front-line support. Thermacube supplies documentation, onboarding materials, and operational runbooks to equip institutional staff for triage, escalation, and system use. Because Atria avoids rapid UI framework changes, training materials remain relevant across release cycles, reducing support burden.

**Part 7.14 Data Privacy Officers and Compliance Officers**

Atria supports privacy governance through data minimization, category-specific retention schedules, controlled deletion workflows, and alignment with GDPR, CPRA, and other state and international privacy regulations. Legal hold and eDiscovery requirements are supported by suspending deletion processes and preserving relevant audit logs. Institutions may configure data residency to restrict storage to specific geographic regions.

**Part 7.15 Institutional Alignment Summary**

Atria is designed to function as a reliable institutional asset that satisfies the diverse requirements of governance bodies, instructional staff, operational teams, and compliance offices. Its cohesion, transparency, standards alignment, and accessibility support the institution as a whole rather than any single constituency. By addressing the concerns of registrars, accessibility professionals, procurement officers, faculty governance bodies, institutional researchers, data architects, and student support teams, Atria demonstrates readiness for enterprise-scale adoption and long-term stewardship.

**Part 8. Regulatory and Compliance Alignment**

Learning platforms operate within an increasingly complex regulatory landscape spanning federal law, state privacy statutes, international data protection frameworks, accessibility mandates, public-sector requirements, and industry-specific compliance expectations. Atria’s architectural decisions support alignment with these frameworks while maintaining institutional control over data, deployment, and governance. This part outlines how Atria supports compliance readiness across jurisdictions and regulatory domains.

**Part 8.1 U.S. Federal Educational and Accessibility Regulations**

Atria supports compliance with the primary federal regulations governing learner data protections, accessibility, and equal access.

**Part 8.1.1 Family Educational Rights and Privacy Act (FERPA)**

Atria aligns with FERPA by enforcing strict access controls, audit logging, deterministic scoring logic, and institution-defined retention and correction policies. Institutions retain full ownership of learner data and may export or delete records according to their governance requirements. Sensitive operations, such as grade changes and credential issuance, are logged as auditable events to support FERPA compliance and institutional oversight.

**Part 8.1.2 Section 508 and the Rehabilitation Act**

Atria’s server-rendered architecture provides predictable semantics for assistive technologies. Focus states, landmarks, headings, and dynamic interactions maintain coherence across updates, supporting Section 508 accessibility standards. HTMX-enhanced interactions preserve accessibility affordances without requiring client-side framework adaptation.

**Part 8.1.3 Americans with Disabilities Act (ADA)**

Atria aligns with ADA expectations by maintaining consistent UI behavior, supporting screen readers, enabling keyboard navigation, and offering server-level accommodations such as extended timing and alternative interaction pathways.

**Part 8.2 U.S. State Privacy Laws**

Atria supports institutional compliance with state privacy laws affecting data handling, retention, access, and deletion.

**Part 8.2.1 California Consumer Privacy Act (CCPA/CPRA)**

Atria supports CPRA principles through data minimization, transparency, deletion workflows, and institution-controlled hosting models. Institutions can manage privacy notices and configure data handling procedures required for learners who qualify as California consumers.

**Part 8.2.2 Emerging State Privacy Frameworks**

Atria’s retention scheduling, access controls, deletion policies, and logging behaviors align with requirements found in the privacy laws of Virginia, Colorado, Connecticut, and Utah. Because institutions control hosting regions and security configurations, they can align Atria deployments with state-specific privacy governance rules.

**Part 8.3 International Privacy and Data Protection Frameworks**

Institutions serving international learners or operating in multiple countries must comply with global privacy expectations. Atria’s design supports these needs.

**Part 8.3.1 General Data Protection Regulation (GDPR) and UK GDPR**

Atria supports minimization, purpose limitation, right to rectification, right to erasure, and right to data portability. Records may be exported in structured formats including CSV, XML, JSON, and JSON-LD. Institutions may execute deletion workflows for GDPR erasure requests while maintaining referential integrity and a compliant audit chain. Atria also supports Data Processing Agreements (DPAs) and allows institutions to restrict hosting to specific geographic regions when required.

**Part 8.3.2 International Data Residency Requirements**

Atria may be deployed entirely within institution-selected hosting environments, including on-premises servers and cloud regions confined to specific jurisdictions. Because Atria avoids dependency on distributed cloud-native services, it does not automatically move learner data across regions or introduce data sovereignty risks.

**Part 8.3.3 Australian Privacy Principles, Canada PIPEDA, and India DPDPA**

Atria’s support for controlled access, clear retention policies, deletion procedures, and institution-governed hosting aligns with requirements found in these international privacy regimes.

**Part 8.4 Public-Sector and Governmental Compliance Expectations**

Public-sector deployments often require adherence to additional security and audit frameworks.

**Part 8.4.1 FISMA Alignment**

Atria’s structured logging, controlled access, encryption practices, and incident response procedures align with the expectations of FISMA Low and Moderate categorizations. While Atria itself is not a cloud service requiring FedRAMP certification, institutions may deploy it on FedRAMP-authorized infrastructure to meet governmental hosting requirements.

**Part 8.4.2 Freedom of Information Act (FOIA) and Legal Hold Processes**

Atria preserves audit logs and relevant records to support FOIA requests, litigation holds, and eDiscovery obligations. Deletion workflows may be suspended when institutions issue retention orders, ensuring evidentiary integrity and compliance with legal processes.

**Part 8.5 Payment Industry Compliance**

Atria does not process or store payment card data. All transactions are delegated to external PCI-DSS–compliant providers. This design prevents payment data from entering the LMS environment and eliminates the need for institutions to conduct PCI-DSS certification for Atria’s deployment.

**Part 8.6 Corporate Training and Workplace Compliance**

For corporate training environments, Atria supports immutable completion tracking, timestamped progress records, and BPMN-governed credential issuance. These features align with the audit and compliance needs of OSHA-regulated training, workplace safety certifications, and mandatory corporate learning requirements.

**Part 8.7 Academic and Credentialing Standards**

Atria supports standards that govern credentialing, outcomes mapping, and registrarial exchange.

**Part 8.7.1 CASE Alignment**

Competency mapping and outcome alignment are supported through compatibility with the Competency and Academic Standards Exchange (CASE).

**Part 8.7.2 PESC Standards**

Institutions requiring PESC XML for transcript or credential exchange may integrate Atria with existing PESC-aligned systems through its export and API capabilities.

**Part 8.8 Accessibility Standards and Emerging Guidelines**

Atria adheres to WCAG 2.1 AA accessibility standards and monitors WCAG 2.2 guidance to ensure continued alignment with evolving accessibility expectations. Because Atria’s interface is server-rendered, institutions may implement accessibility revisions without concern for client-side framework regressions.

**Part 8.9 Data Governance, Retention, and Deletion**

Institutions may configure per-category retention schedules for assessment data, enrollment records, analytics logs, and credential artifacts. Atria enforces these schedules automatically while preserving required audit artifacts. Deletion workflows support FERPA corrections, GDPR erasure requests, and state privacy obligations, ensuring that records are removed in a controlled and auditable manner.

**Part 8.10 AI Governance, Fairness, and Transparency**

Atria aligns with institutional AI governance frameworks by offering transparent, explainable AI-assisted operations. AI features do not override instructor authority and may be disabled at the workflow or course level. Institutions may review AI usage logs or request explainability details to ensure fairness, compliance with academic policies, and alignment with emerging AI standards.

**Part 8.11 Internationalization and Localization (i18n/l10n)**

Atria supports language packs, locale-specific formatting, and right-to-left script requirements. Because Atria renders UI on the server, localization changes propagate uniformly across pages and tools, supporting international learners and multilingual campuses.

**Part 8.12 Summary**

Atria’s compliance posture reflects Thermacube’s commitment to institutional stewardship, transparency, and long-term alignment with legal and regulatory expectations. By supporting U.S. federal law, state privacy regulations, international data protection frameworks, accessibility mandates, public-sector requirements, credentialing standards, and workplace compliance, Atria is positioned as a dependable and regulation-ready learning platform for higher education, corporate training, and government organizations.

**Part 9. Conclusion: Stewardship, Clarity, and Institutional Partnership**

Atria represents Thermacube’s commitment to building a learning platform that prioritizes clarity, reliability, and long-term institutional stewardship. By grounding its design in a modern interpretation of the majestic monolith, Atria avoids unnecessary architectural complexity while supporting the performance, accessibility, and maintainability required by learning environments. The platform’s integration of PHP, Go, Roadrunner, MariaDB, and HTMX creates a cohesive system that is both robust and adaptable, enabling institutions to operate confidently at scale.

Throughout this document, the platform’s alignment with instructional design principles, accessibility standards, enterprise governance expectations, regulatory frameworks, and global interoperability standards has been demonstrated. Atria supports faculty autonomy, assessment integrity, and student success through deterministic behavior and workflow-based instructional sequencing. It meets institutional governance needs by offering transparent data models, clear audit trails, strong identity integration, and disciplined operational practices. Its regulatory readiness ensures that institutions can deploy Atria in diverse contexts with confidence that data protection, accessibility, and compliance obligations are supported.

Atria is more than a learning platform; it is a durable component of an institution’s instructional and technological ecosystem. Thermacube’s development philosophy emphasizes earned complexity, pragmatic tooling, open-source stewardship, and sustainable growth. This approach ensures that Atria can evolve alongside institutional needs without imposing costly migration burdens or destabilizing instructional continuity.

As institutions expand their digital learning strategies, the need for platforms that balance innovation with stability becomes increasingly clear. Atria delivers on this need by combining pedagogical soundness, operational coherence, architectural restraint, and regulatory alignment. Thermacube looks forward to partnering with institutions, instructional leaders, and technology teams to support the long-term success of their learners, faculty, and programs.

**Appendix A. OWASP Security Controls Mapped to the Atria Architecture**

Atria’s security posture integrates OWASP-recommended controls into each component of the platform. This appendix summarizes how Atria aligns with the OWASP Top Ten and Application Security Verification Standard (ASVS) across its architectural layers.

**Appendix A.1 Application Layer (PHP and Go)**

Atria uses parameterized queries and input validation to mitigate injection risks (OWASP A03). All request-handling logic enforces authentication and authorization rules as defined by the hybrid RBAC–ABAC model (OWASP A01). Sessions are secured with HttpOnly, Secure, and SameSite cookies, and sensitive identifiers are never exposed to client logic. Output escaping follows context-specific rules to prevent cross-site scripting vulnerabilities (OWASP A03 and A05).

**Appendix A.2 Interaction Layer (HTMX)**

Atria treats HTMX endpoints as full, authenticated request boundaries. CSRF protections are enforced on all state-changing requests, and same-origin policies are applied consistently. Dynamic fragments inherit server-rendered accessibility and sanitization patterns, ensuring that partial updates do not introduce injection or scripting vulnerabilities.

**Appendix A.3 Runtime Layer (Roadrunner and Go Workers)**

Roadrunner processes operate under restricted system accounts and use dedicated runtime permissions to enforce least-privilege execution (OWASP A07). Go-based workers avoid shared mutable state, reducing concurrency-related vulnerabilities. Durable queue backends provide resilient message handling and support secure replay behavior.

**Appendix A.4 Infrastructure Layer (Linux and Reverse Proxy)**

The hosting environment implements minimal OS configurations, firewall restrictions, and SSH hardening. TLS termination occurs at the reverse proxy, which enforces HTTP security headers, rate limiting, and protocol restrictions. System updates and vulnerability patches follow scheduled maintenance routines.

**Appendix A.5 Data Layer (MariaDB)**

MariaDB accounts follow strict least-privilege policies, and connections use private interfaces or encrypted channels when hosts are separate. Backup processes encrypt stored data and preserve integrity through automated restoration tests. Database operations comply with integrity constraints to prevent unauthorized or inconsistent state changes.

**Appendix B. Standards Compliance Matrix**

Atria supports a broad set of interoperability standards used in higher education, corporate training, analytics, and credentialing.

**Appendix B.1 1EdTech Standards**

1.  LTI 1.3 and LTI Advantage: Secure tool launches, grade return, roster access

2.  QTI: Assessment item structure, scoring rules, metadata

3.  Common Cartridge (CC) and Thin CC: Content packaging and import/export

4.  OneRoster (CSV and REST): SIS synchronization

5.  Caliper Analytics: JSON-LD event capture

6.  Open Badges: Credential issuance

7.  LRMI: Content metadata

8.  CASE: Competency and outcomes alignment

**Appendix B.2 ADL Standards**

1.  SCORM 1.2 and 2004: Runtime execution and tracking

2.  xAPI: Learning activity statements

3.  cmi5: Structured launching and xAPI-driven tracking

**Appendix B.3 Additional Standards**

1.  PESC XML: Transcript and credential exchange

2.  HR-XML: Competency and job-role alignment

3.  WCAG 2.1 AA and 2.2 tracking: Accessibility compliance

4.  JSON, CSV, XML, JSON-LD: Data interchange formats

**Appendix C. Architecture Diagrams (Text Descriptions)**

The following textual descriptions supplement architectural diagrams and support accessibility requirements.

**Appendix C.1 System Overview**

Atria’s system architecture comprises three layers:

1.  Presentation Layer: Server-rendered HTML with HTMX progressive enhancement

2.  Application Layer: Roadrunner, PHP workers, Go workers, and internal queue processes

3.  Data Layer: MariaDB with optional asynchronous replicas

Client requests flow through the reverse proxy to Roadrunner, which dispatches them to PHP or Go handlers.

**Appendix C.2 LTI Launch Flow**

1.  External tool initiates LTI launch with signed JWT.

2.  Atria validates the signature, resolves the tool deployment, and initiates or confirms a session.

3.  Role, membership, and context metadata are retrieved.

4.  Atria delivers a server-rendered launch experience or passes control to the tool.

5.  Grade return or subsequent interactions use LTI Advantage services.

**Appendix C.3 SCORM Runtime Flow**

1.  Learner launches SCORM package via Atria content module.

2.  The SCORM API is exposed through Atria’s SCORM runtime wrapper.

3.  Atria records GetValue, SetValue, Commit, and SuspendData interactions on the server.

4.  Assessment completion and mastery logic are resolved centrally.

5.  Records are stored in the MariaDB datastore with audit provenance.

**Appendix C.4 Workflow Sequencing (BPMN)**

1.  Atria loads BPMN definitions for the course’s versioned workflow.

2.  Learner interactions advance workflow nodes representing activities, assessments, or conditions.

3.  Branching logic determines progression or remediation.

4.  Completion triggers credential issuance or grade consolidation.

**Appendix D. Glossary of Terms**

**Active–Passive Failover**: A high availability model in which a primary system handles traffic while a secondary instance remains on standby.

**ABAC**: Attribute-Based Access Control, a model that evaluates policies based on user attributes and contextual conditions.

**BPMN**: Business Process Model and Notation, used for defining instructional workflows.

**Caliper**: A 1EdTech analytics standard using JSON-LD to represent learner events.

**CASE**: Competency and Academic Standards Exchange, used for aligning learning outcomes and competencies.

**HTMX**: A library enabling server-driven, incremental UI updates without SPA overhead.

**LTI Advantage**: A suite of interoperability services supporting secure tool launches, roster access, and grade return.

**Open Badges**: A digital credentialing standard for representing verifiable achievements.

**PESC**: Postsecondary Electronic Standards Council, governing transcript and credential exchange formats.

**RBAC**: Role-Based Access Control, a role-defined authorization model.

**Roadrunner**: A Go-based application server used to orchestrate PHP and Go workers.

**SCIM**: System for Cross-domain Identity Management, used for identity provisioning.

**Appendix E. References**

Atria’s design, security model, and standards alignment draw from recognized regulatory frameworks, accessibility guidelines, and interoperability specifications. The following sources inform Thermacube’s practices.

1.  1EdTech Consortium. (n.d.). *Learning Tools Interoperability (LTI)*.

2.  1EdTech Consortium. (n.d.). *Caliper Analytics Standard*. https://www.1edtech.org/activity/caliper

3.  1EdTech Consortium. (n.d.). *Question and Test Interoperability (QTI)*. https://www.1edtech.org/question

4.  1EdTech Consortium. (n.d.). *Open Badges*. https://www.1edtech.org/openbadges

5.  Advanced Distributed Learning Initiative. (n.d.). *Experience API (xAPI)*. https://adlnet.gov/projects/xapi

6.  Advanced Distributed Learning Initiative. (n.d.). *SCORM 2004 4th Edition*. https://adlnet.gov/projects/scorm

7.  Open Web Application Security Project. (n.d.). *OWASP Top Ten*.

8.  Open Web Application Security Project. (n.d.). *ASVS: Application Security Verification Standard*.

9.  U.S. Department of Education. (n.d.). *FERPA Regulations*. https://www2.ed.gov/policy/gen/guid/fpco/ferpa

10. World Wide Web Consortium. (2018). *Web Content Accessibility Guidelines (WCAG) 2.1*.

11. European Union. (2016). *General Data Protection Regulation (GDPR)*.

12. National Institute of Standards and Technology. (n.d.). *FISMA Implementation Project*.

13. Postsecondary Electronic Standards Council. (n.d.). *PESC Standards*.

14. Society for Human Resource Management. (n.d.). *Competency Standards*.

Implementation Addendum (2025-12-16)

This addendum clarifies the minimum implementation documentation required for an AI-assisted build to remain faithful to the architecture and avoid accidental invention of missing rules.

Required engineering documentation set (binding):

• Atria Engineering Spec 0.1 (Constitution): system invariants and non-negotiables.

• Atria Engineering Spec 0.2 (Domain Interfaces and Contracts): message envelope and inter-domain contract rules.

• Atria Engineering Spec 0.3 (Canonical Data Model): canonical relational storage and evidence/decision ledger rules.

• Ordin BPMN Execution Spec: deterministic workflow execution rules.

• Standards Version and Conformance Registry: exact supported standards/versions/profiles and conformance testing requirements.

• Artifact Storage and Reference Spec: immutable artifact handling and references.

• HTTP/API and HTMX Interaction Spec: endpoint catalogue and UI interaction constraints.

• Tenancy Control Plane Spec: database-per-tenant lifecycle and routing.
