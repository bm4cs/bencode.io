---
layout: post
draft: false
title: "Information Assurance"
slug: "infoassurance"
date: "2023-03-04 13:22:36+11:00"
lastmod: "2023-03-04 13:22:36+11:00"
comments: false
categories:
  - cyber
tags:
  - cyber
  - defensive
  - blueteam
  - threats
  - vulnerabilities
  - university
---

This is a work in a progress.

Kicking off the University year of 2023 at UNSW and ADFA in the Cybersecurity Masters program I am taking [Infomation Assurance and Security](https://legacy.handbook.unsw.edu.au/postgraduate/courses/2018/ZEIT8021.html).

> Provides students with a deep understanding of the technical, management and organisational aspects of Information Assurance within a holistic legal and social framework.

The course is modelled off the [CISSP certification](https://www.isc2.org/Certifications/CISSP#), which dives into the following subjects:

- make a realistic assessment of the needs for information security in an organisation
- discuss the implications of security decisions on the organisation's information systems
- understand the principles of writing secure code
- show an understanding of database and network security issues
- demonstrate an understanding of encryption techniques
- understand foundations of the tools and techniques in computer forensics
- show an appreciation of the commercial, legal and social context in which IT security is implemented
- apply knowledge gained to business and technical IA scenarios

Contents:

- [Module 1: Intro](#module-1-intro)
- [Module 2: Risk management](#module-2-risk-management)
  - [2.1: Risk and the CIA Triad](#21-risk-and-the-cia-triad)
    - [Threats](#threats)
    - [Threat Modelling](#threat-modelling)
  - [2.2: Security Governance](#22-security-governance)
    - [Security Governance Principles](#security-governance-principles)
    - [Policy/Standards/Procedures/Guidelines](#policystandardsproceduresguidelines)
    - [Organisational Roles and Responsibilities](#organisational-roles-and-responsibilities)
    - [Risk Management of Supply Chain](#risk-management-of-supply-chain)
    - [Service Level Agreements](#service-level-agreements)
    - [External Requirements for Governance](#external-requirements-for-governance)
    - [External Requirements for Contracts](#external-requirements-for-contracts)
    - [External Requirements for Legal Standards](#external-requirements-for-legal-standards)
    - [External Requirements for Industry Standards](#external-requirements-for-industry-standards)
    - [External Requirements for Regulatory Standards](#external-requirements-for-regulatory-standards)
    - [External Requirements for Privacy Standards](#external-requirements-for-privacy-standards)
    - [External Requirements for EXIM](#external-requirements-for-exim)
  - [2.3: Personnel Security Policies and Procedures](#23-personnel-security-policies-and-procedures)
    - [Candidate Screening and Hiring](#candidate-screening-and-hiring)
    - [Employment Agreements and Policies](#employment-agreements-and-policies)
- [Module 3: Asset management](#module-3-asset-management)
  - [Information and assets](#information-and-assets)
    - [Classification of Assets Based on Value](#classification-of-assets-based-on-value)
    - [Asset discovery](#asset-discovery)
  - [Asset Lifecycle](#asset-lifecycle)
- [Module 4: Threat assessment](#module-4-threat-assessment)
- [Module 5: Controls](#module-5-controls)
- [Module 7: Assessment](#module-7-assessment)
- [Module 9: Accreditation](#module-9-accreditation)

## Module 1: Intro

Not a one size fits all approach. Too many factors and seemingling chaotic variables, such as risk appetites, country legislation, the business vertical (mining vs banking vs government), acceditation frameworks that apply to certain industries, tolerances, technology limitations, and so on.

The systems engineering "V" provides a useful structured approach to building a complex system, integrating it and validating it. Security can be integrated at every stage in the "V", from high level architecture, component designs, software development, security unit testing (such as fuzzing), validating common vectors, ensuring that security mechanisms are effective such as anomogy detection systems.

A large part of effective IA is groking the business, maintaining alignment with organisational objectives, sensitivity to risk appetite and clarity of return of investment are vital to the success of an IA program.

At this stage there is no need to dig into the specific technologies or security controls of implementations or the services offered. Rather, the goal is at the executive summary level, of the following:

- _Bottom Line Up Front (BLUF)_ What is the problem, what is the solution. Why is it a solution (better, cheaper, faster, other?). What is the business value? Are there different audiences?
- _Organisational Context_ Organisation function, environment, risks and risk appetite. What are the organisational drivers (economics, competition)? Relevant business strategy.
- _Options and Justification_ Options aligned to problem, relevant costs. Credible data. Key stakeholders / relationships. Security and technology strategy
- _Recommendation and Next Steps_ Clear and action-oriented summary. Roles and governance for the plan. Traceability to BLUF and options. How will we see progress?

## Module 2: Risk management

### 2.1: Risk and the CIA Triad

The CIA triad:

- Confidentiality: Only authorised entities have access to the data (e.g. lock on a safe provides
  confidentiality, encryption on block device)
- Integrity: there are no unauthorised modifications of the data (e.g. version control
  provides integrity)
- Availability: Authorised entities can access the data when and how they are permitted to do so (e.g. backups provide
  availability)

There is a <likelihood/probability> that a <threat> will exploit a <vulnerability> to <impact> an <asset>. We don’t
want this to happen so we introduce a <mitigation/control> which reduces the likelihood and/or impact resulting in an
acceptable <residual risk>.

Risk likelihood is typically quantified according to three factors:

1. Impact: Size of the effect on the asset
2. Likelihood: Probability of the threat being able to exploit the vulnerability
3. Exposure: Percentage of the asset exposed to the threat

Two common methods:

– Qualitative:
– Quantitative

#### Threats

- Any aspects that create a risk to the organisation, its function, and its assets
- By Origin: Natural, Criminal, User error
- By Target
  – Hardware: Theft, Natural disaster, Fire, Bad batch
  – Software: Defects, Lack of security, Malware
  – Services: DoS/DDOS, “Man-in-the-middle”, Social engineering

#### Threat Modelling

_Threat modelling_ is looking at an environment, system, or application from an attacker’s viewpoint and trying to determine vulnerabilities the attacker would exploit

Many techniques are availabile:

– Microsoft mnemonic STRIDE = Spoofing, Tampering, Repudiation, Information disclosure, Denial of Service, Elevation of privilege
– Operationally critical threat, asset and vulnerability evaluation (OCTAVE)
– Trike threat modelling. Development of data flow diagrams, use/misuse cases

_Vulnerabilities_ are any aspects of the organisation’s operation that could enhance a risk or the possibility of a risk being
realised, e.g.:
– Software
– Physical
– Personnel

### 2.2: Security Governance

#### Security Governance Principles

- Governance is the process of how an organisation is managed. This includes all aspects of how decisions are made for that organisation and can (and usually does) include the policy, roles, and procedures the organisation uses to make those decisions.
- Alignment of security governance to the organisation’s goal is critical. Security is a support function.
- The security practitioner must understand how the organisation functions, then determine how the security department can help the organisation meet its goals.
- Bad security practices can negatively impact the organisation as much as (or more than) the attacks they’re intended to prevent.
- Goal to provide Due Care/Due Diligence
  – Due care: what the organisation owes its customers
  – Due diligence: any activity used to demonstrate or provide due care

#### Policy/Standards/Procedures/Guidelines

- Policy: the written aspect of governance (including security governance)
- Standards: specific mandates explicitly stating expectations of performance or conformance
- Procedures: explicit, repeatable activities to accomplish a specific task
- Guidelines: similar to standards in that they describe practices and expectations of activity to best accomplish tasks and attain goals; however, unlike standards, guidelines are not mandates but rather recommendations and suggestions

#### Organisational Roles and Responsibilities

Typical security roles:

– Senior management generally ultimately accountable
– Security manager/officer/directors typically responsible for overall security program
– Security personnel
– Administrators/technicians
– All users responsible for their own conduct in the context of security

#### Risk Management of Supply Chain

Every organisation has security dependencies with external entities (vendors, suppliers, customers, contractors)

Risk management methodologies should be applied to all of these entities, possibly including:

– Governance review
– Site security review
– Formal security audit
– Penetration testing

When direct review of external entities is not viable, third party assessment and monitoring can be used:

– ISO-certified audits
– CSA STAR evaluation
– AICPA SSAE 16 SOC reports

#### Service Level Agreements

Define the minimum requirements of a business arrangement and codifies their provision:

– Every element of the SLA should include a discrete, objective, numeric metric with which to judge success
or failure
– Often used as a payment discriminator
– Best serve recurring, continual requirements not singular or infrequent events

#### External Requirements for Governance

Governance is required to provide assurance that the controls determined in Section 2.1 are in place and effective

Apart from this need, there are several reasons why external mandates must be addressed within the organisation governance structure:

– Contractual Reasons
– Legal Standards
– Industry Standards
– Regulatory Standards
– Privacy Standards

#### External Requirements for Contracts

- Payment Card Industry Data Security Standard (PCI DSS)
- Voluntary
- Comprehensive and well-designed
- Consequences enforced by the PCI Council
- Multiple merchant levels
- Requirements for protecting cardholder data, not saving the CVV

#### External Requirements for Legal Standards

Case law sets precedents used in future cases; these can become legal standards the courts use to determine expectations such as due care.

#### External Requirements for Industry Standards

- Set by industry participants and concerned entities
- Can eventually evolve into a legal standard
- May be accepted by regulators
- Standards you should be familiar with:
  – ISO
  – CSA STAR
  – Uptime Institute

#### External Requirements for Regulatory Standards

Standards set by government bodies, such as:
– GLBA
– PIPEDA
– SOX
– FISMA

#### External Requirements for Privacy Standards

Privacy Standards examples:

– GDPR (European Union)
– The Privacy Act (Australia)
– HIPAA (US, Health Insurance)
– APPI (Japan)
– Personal Data Protection Law (Argentina)
– Personal Data Protection Law (Singapore)

Common tenets:

– Notification:
– Participation
– Scope
– Limitation
– Accuracy
– Retention
– Security
– Dissemination

Personally identifiable information (PII):

- PII is any data about a human being that could be used to identify that person
- Examples (from various jurisdictions/statutes):
  – Name
  – Tax file identification number
  – Social Security number
  – Home address
  – Mobile telephone number
  – Specific computer data (MAC address, IP address of the user’s machine)
  – Credit card number
  – Bank account number
  – Facial photograph

#### External Requirements for EXIM

EXIM, or Import/Export Controls are important external governance requirements.

Many Countries limit export:

- ITAR
- EAC
- DECO

Some countries limit import of security tools, particularly encryption solutions (Russia, Brunei, Mongolia)

International legal restrictions (Wassenaar Agreement)

### 2.3: Personnel Security Policies and Procedures

#### Candidate Screening and Hiring

- Detailed job descriptions
- Checking references
- Employment history
- Background check
- Financial profile

#### Employment Agreements and Policies

- Employee handbook
- Employment contract
- Nondisclosure agreement (NDA)

## Module 3: Asset management

### Information and assets

Assets that might be valuable to an organisation:

– Information
– People
– Reputation
– Products
– Architectures
– Processes
– Intellectual Property / Ideas
– Software
– Hardware

#### Classification of Assets Based on Value

Identify Discover Assets

– Maintain an inventory (simple things done well)
– Formal Process

Asset Classification based on value:

– Requires management support & commitment
– Accountability
– Policies
– Training/awareness/education

#### Asset discovery

Process of Protection of Valuable Assets Based on Classification

- Identify and Locate Assets Including Information
- Classify Based on Value
- Requires ownership to establish accountability
- Protect Based on Classification
- Baselines for each classification level


### Asset Lifecycle

Steps:

1. Identify & Classify
2. Secure & Store
3. Monitor & Log
4. Recover
5. Disposition
6. Archive OR Destruction


## Module 4: Threat assessment

## Module 5: Controls

## Module 7: Assessment

## Module 9: Accreditation
