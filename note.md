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
