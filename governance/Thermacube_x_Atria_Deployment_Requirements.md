# **Thermacube × Atria Deployment Requirements**

*(Internal / Semi-Public)*

## **Purpose**

This document defines the **requirements Thermacube places on Atria** as its primary learning execution platform, and the **constraints Atria places on Thermacube** as a deployment and operating organization.

Its purpose is to:

- ensure Atria is viable for Thermacube’s hosted institutional contracts,

- prevent architectural drift driven by convenience or short-term pressures,

- protect Atria’s kernel from erosion,

- and allow Thermacube to scale responsibly **without creating dependency or support overload**.

## **1. Thermacube’s Role in the Atria Ecosystem**

Thermacube is:

- the **primary production operator** of Atria,

- a **reference implementation** for real-world deployments,

- and a **validator of scale, performance, and security**.

Thermacube is **not**:

- the exclusive owner of Atria,

- the only valid operator,

- or the long-term support provider for all adopters.

## **2. Non-Negotiable Functional Requirements**

Atria **must** enable Thermacube to meet or exceed the capabilities currently delivered via WordPress + Sensei LMS, without increasing operational fragility.

### **2.1 Learner Experience (Client-Facing)**

Atria must:

- Support a **Sensei-like “learning mode” interface** on the client side

- Preserve familiarity for existing learners during migration

- Allow **free navigation between lessons**, bounded by required assessments

### **2.2 Course Progression Model**

Atria must support the following **simple, deterministic progression pattern**:

1.  Required **pre-test  
    **

2.  Free navigation through instructional lessons

3.  Required **post-test  
    **

4.  Automatic **certificate of completion** upon passing

This pattern must be:

- configurable,

- auditable,

- replayable,

- and versioned.

## **3. Commerce and Enrollment Requirements**

Atria must integrate cleanly with Thermacube’s existing revenue flows.

### **3.1 Stripe-Based E-Commerce**

Atria must support:

- Course purchase via Stripe

- Automatic enrollment on successful payment

- Idempotent handling of payment events

### **3.2 Purchase Order Enrollment**

Atria must support:

- Purchase-order-based enrollment

- Batch or manual enrollment triggered by payment confirmation

### **3.3 Voucher Codes**

Atria must support:

- Electronic voucher code creation

- Redemption workflows

- Automatic enrollment upon redemption

## **4. Identity, Support, and Communication Integrations**

### **4.1 Identity and Access**

Atria must integrate with:

- institutional IdPs

- existing identity flows used by Thermacube

### **4.2 Support Chat**

Atria must support embedding or integrating:

- the **Freshworks support chat** application

- without compromising security or performance

## **5. Content and CMS Capabilities**

Atria must support:

- publishing **non-course pages** (CMS-style pages)

- publicly accessible informational content

- clean separation between:

  - course execution

  - informational content

These capabilities must not compromise the learning execution model.

## **6. Administration and Reporting**

### **6.1 Administrative Interface**

Atria’s administrative UI:

- may differ substantially from WordPress

- must support:

  - course management

  - enrollment oversight

  - identity management

  - audit review

### **6.2 Reporting and Analytics**

Atria must support reporting **at least comparable** to Sensei analytics, including:

- enrollment counts

- completion status

- assessment outcomes

- certificate issuance

Atria’s auditability is expected to exceed Sensei’s capabilities.

## **7. Infrastructure and Reliability**

### **7.1 Hosting Environment**

Atria will run on **the same server infrastructure** currently used for WordPress + Sensei.

As a result:

- baseline uptime constraints (ISP, hardware, network) remain unchanged

- improvements are expected primarily from:

  - reduced plugin fragility

  - clearer execution semantics

  - simpler operational surfaces

### **7.2 Performance and Scalability**

Atria must:

- meet or exceed existing performance characteristics

- scale predictably under load

- avoid plugin-driven instability

## **8. Migration Requirements (Critical)**

### **8.1 Migration Philosophy**

Migration from WordPress + Sensei must be:

- **faithful**, not disruptive

- conservative in UX changes

- gradual in adoption of new capabilities

Innovation must not precede user trust.

### **8.2 Course Migration**

Atria should ideally support:

- automated or semi-automated migration of Sensei courses

- preservation of course structure and progression

### **8.3 Learner Records**

Atria should ideally support either:

- migration of historical learner records, **or  
  **

- real-time integration with legacy systems for querying prior completions

The migration strategy must preserve:

- learner trust

- institutional credibility

## **9. Operational Responsibility Boundaries**

### **9.1 Hosted Customers**

For **hosted institutional customers**, Thermacube is responsible for:

- platform configuration

- integrations (IdP, commerce, analytics)

- deployment

- uptime

- operational correctness

Thermacube intentionally acts as **the only cook in the kitchen**.

### **9.2 Subject Matter Expertise**

Thermacube is **not** responsible for:

- course subject matter

- instructional content correctness

- domain-specific pedagogy

These remain the institution’s responsibility.

### **9.3 Self-Hosted Partners**

For institutions that self-host Atria:

- they are responsible for **everything  
  **

- Thermacube provides training and guidance only

- operational success is not Thermacube’s obligation

## **10. Explicit Non-Requirements**

Atria is **not required** to support:

- bespoke features per customer

- white-label variants

- full SaaS hosting for all adopters

- help desk operations

- proprietary “enhanced” editions

Requests in these categories are resolved by **forking**, not accommodation.

## **11. Definition of a Thermacube Win**

Thermacube considers Atria deployment successful when:

- hosted contracts operate with less friction than WP + Sensei

- operational burden decreases rather than increases

- clients experience continuity and trust during migration

- revenue remains stable or improves

- Thermacube avoids becoming:

  - a help desk

  - a SaaS vendor

  - a dependency

## **12. Final Statement**

Thermacube adopts Atria not to chase novelty, but to operate with greater integrity, clarity, and sustainability.

This document exists to ensure that **business success does not come at the cost of architectural compromise or personal burnout**.
