# Intro

## Why FPGA

- FPGA becomes attractive
  - high throughput
  - **predictable latency**
  - low power
- Can accele many apps
  - ML
  - Data Analysis
  - Graph Processing
- FPGA started to appear in cloud
  - AWS
  - Azure

## Problems for FPGA in Cloud

1. Bad utilization
   - Currently cloud allocate one **physical** FPGA for an app
   - *internal fragmentation*
   - FPGA capacity is growing
2. Scaling up is hard for devs
   - Design flow only support single-device programming
   - Dev has to manually partition the app
   - Dev has to handle inter-FPGA communication

### Why is FPGA Virt Hard?

**Because FPGA is not virtualized**

- Virtualizing FPGA is harder than CPU / GPU
  - CPU/GPU use **sequence** of instructions (**temporal**)
  - FPGA use circuits (**spatial**)
- Cannot just use the CPU/GPU virt stuff on FPGA
- FPGA compile is slow
  - Cannot just recompile the kernels
  - ... so utilization on cloud is bad

### Why Existing Works Don't Solve the Problems?

- The *overlay architecture*
  - Helps productivity
  - But **only on a single device**
  - No multi-user cloud support
- Some *frameworks*
  - Uses **static resource allocation**
  - No runtime resource management (so "1. Bad utilization" is unsolved)
- Some *works*
  - Use vFPGA as the granularity
  - Still has internal fragmentation
  - ("2. Scaling up is hard for devs" is unsolved)
- AmorphOS
  - Better FPGA sharing by "low-latency mode" vs "high-throughput mode"
  - low-latency mode = vFPGA
  - high-throughput mode = link (*this is my own term) many apps into one app
  - No 100% utilization (bc lack of multi-FPGA support)
  - No runtime resource allocation (resource is allocated at link time)

### How Does ViTAL Solve the Problems?

1. "Architecture Layer" solves "1. Bad utilization"
   - Abstract into **homogeneous** array of **virtual blocks**
   - App =Compiler=> Group of virtual blocks => Dynamic allocate at runtime
   - Virtual blocks can be mapped onto **multiple devices**
   - Also virtualize peripherals (DRAM, Ethernet, etc.)
2. "Programming & Compilation Layer" solves "2. Scaling up is hard for devs"
   - "Programming Layer" gives illusion of **single large FPGA** for devs
   - "Compilation Layer" maps apps to **groups of virtual blocks**
     1. Allocate number of virtual blocks
     2. Partition? (what?)
   - One device divided into 3 regions
     - Comm & Service Region (reserved)
     - User Region: Several **identical** physical blocks <=> **virtual blocks**
       - 1-to-1 phys-virt block mapping
       - Relocatable at runtime
3. "System Layer"
   - Map app to 1 or many FPGAs
   - Multi-FPGA may reduce throughput (bc communication)
     - Runtime management has to be aware of communication
     - Balance **utilization** <=> **throughput**

---

- Developing is hard
- Save dev time by reuse proprietary tools from vendors

### Contributions of ViTAL

1. Homogeneous abstraction
   - Decouple Compile <=> Resource Allocation
   - Enable fine-grained FPGA sharing
   - Reduce programming complexity
   - Supports scaling (by infty large illusive FPGA)
2. Demo benefit of ViTAL by experiments

---

- Section 2: Background
- Section 3: Details for the **layers**
- Section 4: Details of **tools**
- Section 5: Evaluation
- Section 6: Discuss related work
- Section 7: Conclude

# Background

## FPGA Arch

- Island-style, **heterogeneous arch**
- 2D array of ...
  - CLB - Logic blocks
    - which contains many LUTs
  - SB - Switch blocks
  - CB - Connection blocks
  - Hard IP blocks (BRAM, DSP, etc.)

## FPGA Flow

- FPGA Compilation: Data flow => Physical hardware
- Two phases
  1. HLS: High-level lang => RTL lang
  2. Synth:
     1. Parser: Verilog => IRs (CDFGs, DFGs, Netlist)
     2. Tech mapping: Netlist => LUTs & FFs
     3. Optimization
        - Cluster, Pack, PnR
        - Takes hours (or days), bc *millions* of primitives

# The ViTAL Layers

## Programming Layer

- Supports C/C++/OpenCL/DSLs
- The compiler provides interface to HLS tool
- Parts
  - Illusion of single, infinite FPGA
  - Runtime resource management system for "util and concurrency"
- The 2 parts reduce programming complexity

## Architecture Layer

- Sits between **physical FPGA** and **compilation layer**
- Decouples **compilation** and **allocation**
  - By **position-independent mapping**
  - Tradidionally, app are deployed to fixed location
    - Certain type of resource is only avail. at certain loc.
- By **homogeneous abstraction** - every block has:
  - same amount of programmable resources
  - same interface to peripherals (DRAMs etc.)
  - same latency-insensitive interface to other blocks
    - "hides latency difference" (how??)
  - Partitioning is simple
  - Functional correctness is simple (i.e. no timing failure)
  - User logic is gated behind "yes have data" wire
- Virtual memory for off-chip DRAM
  - Apps can use virt addr to access it
  - Memory accesses are monitored for security
- Every physical FPGA is partitioned into 3 regions
- The **user region** contains **identical blocks**. How?
  - FPGA has heterogeneous resources
  - ... so it has to be carefully partitioned
  - i.e. FPGA is column-based => Blocks is row-based
- User logic is **offline compiled** for a **physical block** (relocatable)

---

- Modern FPGA is complex
  - "Clock-regions"
    - Have to think about clock skew within physical block
  - "Multi-die"
    - Physical block is always in a single die

## Compilation Layer

- Xilinx tools is reused

### Compilation Steps

1. Synthesis
   - HLS => Verilog RTL => Netlist of LUTs
2. Partition (new in ViTAL)
   - Partition netlist into **virtual blocks**
   - Algorithm talked in section 4
   - Can be done in many levels:
     - CDFGs
     - DFGs
     - Netlists <== used in ViTAL
   - Why partition at netlist level?
     1. Netlist is language-agnostic
     2. Netlist lets you see resource usage (LUTs, BRAMs)
3. Lat-Ins Interface Generation
4. Local PnR
   - Virtual block => Physical block
   - Lat-ins interface => commu region
   - Reuse PnR in existing tool
5. Relocation
6. Global PnR
   - Reuse PnR in existing tool

## System Layer

- One DB for current resource usages
- One DB for bitstreams
- Deploys using **partial reconfiguration**
- Tries to allocate app onto a **single FPGA**
  - ... then try 2 FPGAs
  - ... then try 3 FPGAs
- (Not implemented) Share identical physical block between apps
  - why not? because it **reduces perf** for each user
  - why not? because in cloud the compiled apps are **encrypted**
  - **not** sharing prevents "side-channel attack", etc.

## Discussions

### Back-Pressure and Deadlock

- User logic is gated once the output buffer is full
  - So back-pressure is solved
- Some mechanisms to avoid deadlock
  - Guarantee "at least one input buf is not empty"

### System-Reserved Resource

- We want the reserved regions (System & Commu) to be small
  - System is small, no problem
    - Can do better by using a hard IP block to do it
  - Commu is **not** small
    - Intra-FPGA buffers are removed to fix this

## Partition Algorithm

- Affects performance a lot
- "Placement-based" partition algo
  1. Apps are placed onto 2D space
  2. Partition based on placement results
- Minimize num. of inter-block conn
- Maximize "operation frequency"

### Packing

- Greedily pack logic into **clusters**

### Global Placement

- "Quadratic placement method"
  1. Solve linear eq.
     - Minimize total len. of routing paths
  2. Create legal placement (using SA)
     - (Step 1 creates illegal solution)
     - Eliminate over-util
     - Minimize move dist.
  3. Pseudo Cluster & Connections
     - (what??)
  4. Repeat step 2 and 3
     - $\beta$ is slowly increased
     - Move clusters away from over-util blocks

# Evaluation

- Evaluate each layer

## Bench Selection
