---
layout: post
title: "Network and Memory Forensics"
date: "2020-03-16 9:20:10"
comments: false
categories:
- infosec
tags:
- forensics
---

Run by Ajosh Ghosh on 16 March 2020.

Falls into two main families:

Incident response:

* The key is to protect the victim.
* Evidence collection is not the goal

Computer forensics (discover truth, who/what/when/where, benefit of time and hindsight).



ISO 27037 defines forensics:

* Digital evidence, binary data that may be relied on as evidence.
* Digital evidence first responder (DEFR), a person qualified to act first on scene.
* Digital evidence specialist (DES)
* 


TODO: Download ISO standards, through library database.

* RFC 3227 are the guidelines for evidence collection, states an order of volatility, which prioritises an order of capture. For example, CPU registers and cache should be captured before archival files on disk.
* HB171 are the guidelines for management of IT evidence (2003), sponsored by the AFP and AGD.
* Forensic examination of digital evidence (2004) are used by prosecutors in the US. How documentation should be put together.
* ISO 17025 applies to accreditation and standards a forensics lab needs to undergo. It lays out a method for measuring uncertainty. Rare to see actual police labs follow these processes.
* NIST 800-86
* BSI 10008 the British standard on evidential weight and legal admissibility of electronic information (2008). The only document that sets out guides around how lawyers and courts determine how much weight to put on technical evidence.
* ISO 27037, *recommend to familise*, published in 2018, guidelines for identification, collection, acquisition and preservation of digital evidence. Scene setting for a broad plan, more detailed ISO standards are used to drill into these areas (27041, 27042 and 27043).
* S146 evidence made by processes, machines. This applies to a document itself (not the interpretation of the words in the document).



## Standards of proof

In a criminal case, can have a penalty that includes imprisonment or penal servitude. Prosecution beyond reasonable doubt. Defendant is the person who has been accused, on the balance of probabilities (a lower standard, and allowed to cast doubt).

In civil cases, both sides work on the balance of probability.


## Types of evidence

* Testimony, evidence given by a witness (e.g. verbally or formally in a witness box, a report).
* Documentary, part 4.3 of evidence act, such as evidence from processes or machines.
* Physical, a real thing that can be presented in court, such as a picture or video.

## Type of witness

* Lay witness
* Investigator, courts expect that as much *incriminating* and *exculpatory* evidence has been attempted to be collected.
* Expert, to answer specific set of questions are instructed, and no more. Often has a bias.
* Independent expert, weighs heavily in some cases. Like an expert, but has no other interest in the matter at hand.



# Evidence

The life cycle in court:

* Pre-trial, having a report become an *agreed fact*, is a process that can take a long time (months, years) to get agreement between both parties, and multiple experts. If this is not possible, will become a *fact in issue*.
* Evidence in chief, led by the (advocate) barrister of the party that appointed you as the expert (i.e. your advocate).
* Cross examination, led by the adversary barrister, where most technical experts fail. The purpose here is to negate your evidence. Theatrics of the court room. Don't try to answer the question of why or motives for example.
* Re-examination

Two types of evidence:

* *Factual*, something a person saw, heard or perceived. Something that is common knowledge or self-evident.
* *Opinion*, specialised knowledge based on study or expertise. Hearsay (*from section 59 of the evidence act* is an asserted fact).
* *The grey area*, that relates to business records or documents. Often what experts are requested to give an analysis on.

The admissibility of evidence:

* Admitted, as an *agreed fact*, does not require cross examination
* Provisionally admitted
* Rejected

The weighting of evidence, comes down to determining the best artifacts, as part of the theatre of the courtroom. It is beneficial that produced reports are clear and concise.

## Meaning of a document

Any record of information, such as writing or figures, maps, sounds, or anything from which these things can be reproduced.

As an expert you'll be giving to refute or support the presumption that a document was:

* an *ordinarily produced outcome*
* the machine was *properly used*

Asking the question backwards. What are some questions you'd ask if trying to refute the presumption?

* inconsistencies in the specification and meta data
* used alternative word processing packages
* the computer used to author the document contained malware (such as the results are running AV, what date/time was the malware installed, does the date predate that of the warrant).
* software not patched to latest levels
* computer authentication was compromised



# Presenting evidence

Four primary stages.


## Relevant

Is this piece for the right puzzle?

Could affect the assessment of the probability of the existence of a fact in issue in the proceeding.

Factors:

* credibility of witness
* TODO

## Reliable

Are they the right pieces or a cheap knock off?

As an expert, are you appropriately qualified. Truthful and unbiased. Not compromised.

Barristers will work through attacking evidence, then the process, and you as the witness. If at the witness stage, you know you've done a good job as a witness.

The processes, such as the scientific process. Such as tools used. Standards that are applicable. Vendor based white papers (BEWARE, easy to demonstrate the bias in these papers). 

Consider the terms & conditions of cloud providers (such as facebook) carefully. For example, it is not acceptable to have multiple accounts or to provide inaccurate personal details.


## Sufficient

Are there enough pieces to make an argument or opinion?

Subjective, and *it depends*.

Experts that simply cast mere doubt or speculations, are often frowned upon by the court.

If relying on an ordinarily produced outcome, are you able to demonstrate the machine was operating correctly. Is this thesis supported by your peers. Can this outcome be produced in a different way.

Sometimes your hand is forced, due to time/budget constraints, and a best effort conclusion must be delivered based on snippets.


## Persuasive

Can you persuade a decision maker using your thesis.

Experts have to overcome somewhat sceptical decision makers.

Barristers and judges are demanding and have a limited understanding of technology.



# Expert Report

* Its not acceptable to make up an address. The address specified on your drivers licence. Other address such as PO boxes, places of work are not acceptable. It is possible to state a PO box, and follow that up with your real address is known to the NSW police.
* Courts still require reports be signed. A digital signature does not fulfill this.

Tips:

* Be clear about fact vs opinion. Break out each piece of the report into paragraphs. Start paragraph with *in my opinion*. This way its clearer what is stated as factual evidence.
* Write clearly and simply, and in the first person.
* The benefit of first person, is that it eliminates a collective response. In a cross examination, that is an easy target, as each contributor is pulled into the witness box, and inconsistencies in responses are drawn out and exploited.
* Write using logic and critical reasoning. Start with a very base level of understand, and take the reader on a journey. Distilling each answer.
* If something can't be described simply, you probably haven't mastered the subject yourself.
* Draft. The report is expected to be shared as soon as practicable. Keep the document in draft as long as required. Once no longer draft, each version of the non-draft document must be maintained (e.g. such as a wording change).
* Classification of the document is always confidential, as they pertain to litigation.
* The document should be marked privileged (in addition to confidential) whilst draft.
* Bring in analogies to help explain technical concepts (such as the probability of an MD5 collision is similar to the odds of winning lotto).
* Explain common things, like file systems. Such as file are stored on a device such as a hard drive, are actually stored in pieces, and how a (FAT) table can be used to link those pieces back together.


Avoid:

* Using jargon
* Attack other experts.
* Skip over steps and arrive at a conclusion.
* Be honest, if you don't know something, state you don't know.




# Expert Privileges

* not expected to know all rules
* allow to stay in court
* allow to advise counsel (except under examination)
* allow to address court (through judge)

As a result the following responsibilities flow onto an expert:

* confidentiality (cannot discuss matters that related to cases)
* Responsibility is to the court, to find just resolution of disputes according to law as quickly, efficiently and inexpensively as possible. Comply with orders, such as times to file particular documents, how long materials can be retained, reporting illegal conduct, tax avoidance.
* Respect privileges (part 3.10 of evidence act). For example, reading emails between certain parties may not be permitted.
* Limited to instructions. 
* Limited to taxation, regardless of professional (e.g. $375 per hour).
* ACT is the only state that offers immunity (i.e. to slander, deformation)

All states have now adopted the Civil Procedures Rules.





# Forensic Copy

1. Make the copy. Duplicate the data. Justify why this is reliable and sufficient.
1. Make verification data, that can be used to verify the data has not changed. Hashing. 
1. Demonstrate copy is reliable.

When verification data is attached to a copy, its known as a *forensic copy*.

The `E01` or *expert witness* format, is a preferred format by many forensic experts, as it features a number of reliability features.

* Blocked up into chunks of 64 sectors (32k)
* Followed by a CRC (cyclic redundancy check)
* Case header,
* Includes an overall hash (MD5) at the end.
* Has encryption and compression options too.


## Tools

* `dd` a general purpose block based duplication tool.
* `ddflcc` computes hashes on the fly


## Verification failures

Copies can fail:

* Spoilage
* Tampering
* Negligence
* Wear and tear. The process of reading old backup tapes, results in destroying the physical media itself.



# Data Recovery

The essence of data recovery is known as *data carving*. To explain this simply in a courtroom, would take up-to 3 days, after building up on explanation of a file system, blocks, assembling the blocks, and why this process is reliable, and not biased to a particular side.

NIST provides standardised methods and test cases for data carving.

Particular tool choices should be justified, e.g. peers use the tools, and a built up community around their use.

## Tools

* `scalpel`
* `foremost`
* `recoveryjpg`
* `photorec`



# Critical thinking

TODO: refer to socrates slide, about deduction and observation.






# Tools needed for home setup (COVID-19)

* Graphviz
* QGIS, with Open Street Map (OSM), and NSW Gov Spatial Images



# Network forensics

Relates to the collection of IP packets, email, non-IP protocols (e.g. zigbee, H.323), old protocols (SNA, X.25).

## Challenges

* Time. Resequencing events. In Australia, the official time source should be the synchronisation service provided by the National Measurement Institute (NMI). Asking for at least one months worth of data, helps shed some light around date format confusion.
* Complexity, correlation, tools across multiple environments.
* Collection,
* Paradigms
* Collaboration


## Time

Important to follow standards.

ISO 8601, data elements and interchange.

IETF RFC 3339 *Date and Time on the Internet* (2002)

GMT stands for Greenwich Mean Time, the mean solar time at the Royal Observatory in Greenwich on the south bank in Eastern London, UK. When the sun is at its highest point exactly above Greenwich, it is 12 noon GMT. Except: The Earth spins slightly unevenly, so 12 noon is defined as the annual average, mean of when the sun is at its highest, its culmination. In GMT there can never be any leap seconds because Earth’s rotation doesn’t leap.

UTC, which stands for Coordinated Universal Time in English, is defined by atomic clocks, but is otherwise the same. In UTC a second always has the same length. Leap seconds are inserted in UTC to keep UTC and GMT from drifting apart. By contrast, in GMT the seconds are stretched as necessary, so in principle they don’t always have the same length.


## Mapping an IP to a person or geolocation

Starting point is explaining in simple terms to lawyers, the workings of DNS and Internet registries, which is governed by the IANA (Internet Assigned Numbers Authority), in turn delegates to RIR (Regional Internet Registries), which in turn delegates to Local Internet Registries.

*auDA* is the local registry for Australia and has delegated registra2on to accredited registrars.

The auDA provided whois is considered an authoritative data source.


## Tools

* Call charge record (CCR) dumps.
* `log2timeline` tagged data, such as emails, browing history.
* Graphviz, useful for visualising large sets of data, especially data From -> To -> No, such as IP, telephony dumps.







