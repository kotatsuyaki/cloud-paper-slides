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

- AWS and Azure are offering FPGA
- FPGA Good
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
- FPGA Bad
