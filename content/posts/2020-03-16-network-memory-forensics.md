---
layout: post
title: "Network and Memory Forensics"
date: "2020-03-16 9:20:10"
draft: true
comments: false
categories:
- infosec
tags:
- forensics
---

Wisdom imparted from Ajosh Ghosh during the week 16 - 20 March 2020.



# In a nutshell

* Expert reports are finicky (e.g. even down to details such as specifying your address)
* Open source dominate this space (e.g. volatility, elasticsearch, graphviz, qgis, wireshark, `nfsen`, `flow-export` ,`dcfldd`)
* There are several standards and formal methods when it comes to forensics, be familiar with them.
* There are several legal acts that dictate this field (such as the evidence act). Be familar with them.
* As a technical expert, always go above and beyond to justify the who/what/when/where (never the why).



# Computer forensics

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


TODO: Download ISO standards, through uni library database.

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
* `dcfldd` a patched version of `dd` with forensics focused enhancements (hashing on the fly, status output, secure wipes, piped output and logs).

Examples:

    dcfldd if=/dev/source hash=md5,sha512 hashwindow=1G md5log=md5.txt sha512log=sha512.txt \
    hashconv=after bs=512 conv=noerror,sync split=1G splitformat=aa of=image.dd


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



# Memory forensics

The analysis of data from volatile memory.

Its rare to dump a memory capture in the field directy. These are normally provided by the first incident responders.

Useful things to harvest:

* Browsing history (TOR sessions)
* Communications
* Clipboard contents
* Encryption keys
* Recently executed processes
* System activity and logs
* Network connections
* User data


Its challenging to present results to a courtroom.

* Secret extraction on Windows by harvesting virtual memory (i.e. `pagefile.sys` and `hiberfil.sys`).
* TOR browser cache.
* Password managers (LastPass, KeePass, etc) remannts in memory.

Tools for dumping:

* Magnet RAM capture


Tools for analysis:

* Volatility Framework
* Magnet AXIOM
* BlackBag BlackLight
* BinText
* Belkasoft Evidence Center
* WindowsSCOPE
* FireEye Memoryze


Live demos of Magnet RAM capture, using volatility, and using the Cellebrite UFED to do phone extracts.



# nfsen

Program (perl and web based) for doing netflow dump analysis.

We ran through the Task 5 Netflow Exercise from the *ENISA Network Forensics Toolset, Document for students (2015)*. The European Union Agency for Network and Information Security provide this training material for free, and highlights from real world application of both network and memory forensics.


`nfzen` provides a number of aggregation and filtering capabilities. A *Time Window* option presents a visual timebox with sliders, to select the time box of interest.

Netflow processing can help to figure out what is being attacked. Reduce the time window to
accelerate this process. In this example the timeslot was Feb 24 from 04:00 to 09:00 according to the
top 10 statistics about the destination IP ordered by flows, packets, bytes or bits per second (bps). The
screen below shows the statistics generated by the packets.

The stats of the flow records can be used with the dstIP aggregated

195.88.49.121 is probably the attack target.
This identifies the potential target of the attack and – from the earlier analysis – it is clear that the
attack was performed via UDP traffic. If in doubt about UDP traffic, netflow processing can be used:
top 10 with protocol aggregation and the ‘dst host 195.88.49.121’ filter. It is clear that the UDP activity
(packets, bytes, flows) is huge when compared with other protocols.

Almost all traffic to this server was 80/TCP, so this is probably a WWW server. The goal of the DDoS
may be to disable the site.
Conclusion:
The attack was DoS or DDoS performed via UDP traffic and was targeted on a WWW server
(195.88.49.121).




# Telco activity

ACMA radio map, search for telstra as the client, search for alice springs, zoom to condence to needed region, download the site as an exported file. THis should provide the lat/long and name of the site. The name of the site should correlate to that in the CCR.

https://web.acma.gov.au/rrl/site_proximity.main_page


mmqgis - smooths the process of geocoding from CSV

Web Service Geocode 




# Mobile Forensics

As a forensic expert, cannot work with materials that have been illegally obtained, or considered sensative to parties involved. Courts using their discretion to tune how hard they can come down on forensic labs depending on the level of due dilligence applied.

The person or entity that legally owns the phone, are the only person that can authorise access the phone.

This can be overcome by gaining legal council from the organisation.

* Cannot authorise illegal access. Inappropriately acquired evidence can be tolerated on the discretion of the court, on the basis of natural justice.
* Prohibited access, such as workplace surveillance, or court orders.
* Exceptions prevent disclosure.


Need to decide whether you are going to rely on output of a process, machine or device, and be able to withstand a challenge by an expert engaged by the adversary.

One way to mitigate this is to use the same software are used by the other expert, and a different toolchain. This is useful for justifying the reliablility of the outcome.


## Legal definitions

As defined in the Telecommunication (Interception and Access) Act 1979

*Communication* includes conversation and a message, and any part of a conversation or message, whether:

(a) in the form of: speech, music or other sounds, data, text, visual images, whether or not animated, signals
(b) in any other form or in any combination of forms.



Section 6 of Telecommunication (Interception and Access) Act 1979

*Stored communication* means a communication that:

(a) is not passing over a telecommunications system; and
(b) is held on equipment that is operated by, and is in the possession of, a carrier; and
(c) cannot be accessed on that equipment, by a person who is not a party to the communication, without the assistance of an employee of the carrier.


## Legal permission

* Is your client (e.g. HR manager, CEO, in-house lawyer) authorised to hand over material to you (as an expert)?
* To get around this, only take instructions from the court or lawyers. These instructions can be used as the basic for moving forward.
* Letter of instruction should confirm there are no outstanding court orders, which this forensic undertaking could influence.
* 



## Onus of proof

The onus of proof is on the party seeking to establish that *outcome produced by a process, machine or device* is unreliable.

Standard of proof depends on whether your testimony is being called by prosecution or defendant (there is no ownership in the testimony of an expert - argument of Margret CunneenSC when seeking to use mobile phone evidence).

Once that is established, the onus is on the party relying on the *outcome* to prove it is reliable.

Always provide testimony regarding the reliability of your own evidence:

1. Your own testing of the particular process
1. Your prior experience and the experience of your peers
1. Relevant research



## Sources of data

You are not allowed to do anything illegal. However, if another party has done somthing illegal, which in turn belongs to an organisation or party willing to handover, any material is up for grabs.

* the phone itself (device extraction, backup, surveillace or spyware) - if exists as a result of spyware, which was not knowingly installed by the owner, this is free game for use in forensics.
* the telco (call charge records - i.e. CCR, mandatory data retension - i.e. MDR, montly account)
* content provider (e.g. apple, google, may be possible to sopenia, law enforement assistance request, )
* the recipient (simple matter of asking the recipient of communications is a low hanging fruit)
* communications (e.g. wireless access points)



## Android

* Root the root (Framaroot, TowelRoot, ActiveRoot, KingoRoot, or SuperOneClick)
* Copy the data thru shell, partition (e.g. dd), selected artefacts using program such as *Andriller*





# Major assignment notes

All 4 parts are to be a single PDF submission.


Part 1: Expert report based on the nitroba example:

* Due on last day of semester
* Doesn't care about preliminaries (e.g. expertise).
* Appropriate address declarations.
* About 10-30 pages including attachments.
* use the australian legal referencing format, for references.
* short succint

Part 2:

* based on the dabber activity!
* dot point report
* why wireshark and nfsen were used, why they are reliable, 
* can be done in report or essay style, up to you.
* describe any alternate reliability tests needed (e.g. you might estimate another 4 hours - but dont actually have to do this)
* determine the $10K cost is appropriate, by working through justification


Part 3 short essay: 

* against the use of cellebrite UFED and XRY
* looking for succinct and accurate description of position either for (proponent) or against (detractor)
* Ajoy personally is a detractor, but he has seen good essays as the proponent


Part 4 select a challenge that forensic experts face:

* examples, such as time, performance, complexity
* doesnt want to read about AI against big data challenges in the broad sense, but instead specific examples of the application of AI
* drill into 2-4 very specific ways of overcoming that challenge
* 

