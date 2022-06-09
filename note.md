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

# Background

## Virtualization

- Create virtual abstraction
  - of: computing resources
  - to: hide hardware stuff
- User gets illusions:
  - Unlimited access
  - Exclusive access

### GPU Virt

- gVirtuS
  - "split driver" approach
  - frontend component in guest
  - backend component manages and manages requests
- rCuda
  - For HPC
  - Access remotely
  - Client stubs forward API calls
  - Server performs GPU multiplexing

## Objectives

### Old Objectives are Bad

- multi-tenancy
- resource management
- isolation
- resilience (what?)
- (x) scalability: **cloud in general**
- (x) performance: ~
- (x) security: ~
- (x) flexibility: **objs of HLS**
- (x) programmer's productivity: ~

### New Objectives

- Abstraction: Hide hardware stuff
- Multi-tenancy: share among users and apps
- Resource Management: Provision, balancing, fault tolerance
- Isolation: Perf & data isolation among users and apps
  - covers *security*
  - covers *resilience*

## FPGA Virt is Hard

- FPGA is reconfigurable
  - but virtualization is not hardware-agnostic
- Multi-tenancy is hard
  - since FPGA is traditionally embeded & for single app
  - new tech: *partial reconfiguration* (PR)
    - flows are not mature
- Provision in cloud is hard
  - since buildng HDL code takes long time
- Resource Management is hard
  - since hardware is tied to vendored design flows

## Terminologies

- Shell
  - "static region" on FPGA, pre-implemented
  - "hardware OS", "static region", "hull"
- Role
  - "dynamic region" on FPGA
  - Role = PRR + ... + PRR (partially-reconfigurable region)
  - Each PRR can be reconf. without interrupting others
- vFPGA
  - Virtual abstraction of the physical device
  - 1+ PRR mapped to one vFPGA
- Accelerator
  - a PRR / vFPGA programmed with an app
- Hypervisor
  - Gives software apps abstraction of FPGA
  - Manage vFPGA resources
  - "OS", "Resource Management System", "VMM", "RTM", ...

## Programming Models

1. DSL
   - Write in C-like language
   - Loops are transformed as FPGA kernels (using HLS)
2. HDL
   - Verilog, SystemVerilog, VHDL, ...
   - Requires effort & knowledge
3. HLS
   - OpenCL, Java, ...
   - Less hardware knowledge needed
   - Productivity goes brrr
   - e.g. Intel FPGA SDK for OpenCL: Compiler, Emulator, Runtime

# FPGA Virt System Architectures

## Hardware

- Host Interface
  1. On-Chip Host Interface
     - FPGA hardware <=> Soft / Hard CPU on chip
     - Soft: MicroBlaze
     - Hard: Zynq
     - Low latency but wastes area
  2. Local Host Interface
     - FPGA hardware <== PCIe ==> CPU host
  3. Remote Host Interface
     - Connects via network
     - Hight latency but improves scalibility

- Shell
  1. System Memory Controller
     - Allow FPGA kernel access DDR / SDRAM
     - = DMA controller
  2. Host Interface Controller
     - on-chip / local / remote (see "host interface")
     - = PCIe module
  3. Network Interface Controller
     - Allow FPGA to access network **without host CPU**

- Role
  1. Flat compilation
     - Whole role is reconf'ed for one app
  2. Partial reconfiguration
     - Multiple "DPR regions" configured independently
     - Reduce reconfig time using "Intermediate Fabrics" (what?)

## Software

### Overlay

- "Intermediate fabric"
  - Provide uniform architecture on top of real FPGA
  - Apps are portable on this overlay arch
  - Like JVM
  - Reduce compile time
  - Good portability
  - Good dev productivity
  - Bad utilization & performance
- Configuration
  1. Spacially Configured ( SC ): Functional units have fixed tasks
  2. Time-multiplexed ( TM ): Overlay operation changes every cycle
- Granularity
  1. Fine-grained overlay
     - Operate at bit-level
  2. Coarse-grained overlay
     - "Coarse-grained reconfigurable arrays" (CGRA)
       - Array of PEs in 2D network
       - or other topologies
       - "NoC topology" communicates via routers (flexible)
     - or just **processors**
- Recent work: NoC-based overlay
  - Torus network
  - Packet communication
  - High-level C++ library

# Objectives

## Abstraction

- Overlay architecture
  - Performance & utilization penalty
  - Mitigate: Choose overlay arch from multiple of them
  - Single abstraction across vendors
- OS-based approache
  - Feniks OS: Big shell for management
  - OS4RS: "device node"
  - RACOS: load / unload accelerators
  - AmorphOS
    - "Morphlets" (= vFPGA)
    - Read / write data over transport layer
  - Accelerator marketplace on OpenStack


## Multi-Tenancy

- Spactial or Temporal Multiplex
  - spacial: device is partitioned
  - temporal: reconfig time has to be fast

## Resource Management

- Transparent Provision & Management
  - for balancing & fault tolerance
- PRRs

