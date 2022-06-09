# Abstract

- FPGA is rising
  - good: hardware flexibility
  - bad: need hardware knowledge
- Why need FPGA virt?
  - Abstractions for app devs
  - Share FPGA between users and accele apps
    - tradition: FPGA is for single-user, single-app
- This article
  - Review system archs for FPGA virt
  - Ident objectives of FPGA virt
  - Summarize techniques for FPGA virt

# Intro

## FPGA Good

1. FPGA is good for streaming data
   - CPU / GPU are for (block?) memory data
   - Move data between PEs, no mem access
   - High throughput, low latency
2. Adaptable architecture
   - Spatial & temporal (pipeline) parallelism
   - For both high-concurrency and high-dependency (why?)
3. Low power
   - Thermal stable
   - Less cooling, less energy use

## FPGA Bad

1. Need HDL
   - Software devs don't do that
   - HLS lets you run OpenCL
     - but hardware knowledge is required for *performance*
2. Flows are tied to hardware
   - Binary is for specific FPGA chip only
3. Vendor tools don't allow *sharing FPGA between users and apps*
   - Bad for multi-tenancy cloud
   - Maybe solution: decouple app (portable) & kernel design (non-portable)

## Objectives of FPGA virt

1. Abstractions
   - Hide hardware stuff from app devs
   - Give simple, familiar interface for "virtual" resources
2. Sharing
   - Space sharing
   - Time sharing
   - ... and still retain high resource utilization
3. Provision & Manage FPGA resources
4. Isolation
   - Performance isolation
   - Data isolation

## Early Surveys

- "Three approaches"
  1. Temporal partition
  2. Virtualized execution
  3. Virtual machine
- "Three categories based on level of abstraction" (Vaishnav)
  1. Resource level: virtualize hardware & IO on **a single FPGA**
  2. Node level
  3. Multi-node level
- ... (skipped some surveys)

### Drawbacks of Early Surveys

- Overlapping categories
- No linkage between virt. tech. and virt. objectives
- Does not talk about FPGA system architectures

### This Survey is Better

- Review:
  1. System architecture (hard & soft)
  2. FPGA virt techs
  3. "their associations" (what?)
- 4 Objectives
  - each with solution (i.e. What virt tech solves this objective?)
- Table 1: System archs
- Table 2: FPGA virt techs, with objective category
- Bonus: review isolation & security papers
