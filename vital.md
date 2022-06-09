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
