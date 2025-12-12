# Project Documentation
**Version:** 1.0

## Tools

| Software | Version |
| :--- | :--- |
| **Vivado ML Edition** | 2023.1 |
| **MATLAB** | R2024b |

### MATLAB Toolboxes & Add-ons

* Simulink (v24.2)
* Communications Toolbox (v24.2)
* Signal Processing Toolbox (v24.2)
* DSP System Toolbox (v24.2)
* Wireless HDL Toolbox (v24.2)
* RFSoC Explorer Toolbox (v3.3.0)
* Fixed-Point Designer (v24.2)
* HDL Coder (v24.2)
* DSP HDL Toolbox (v24.2)
* Embedded Coder (v24.2)
* HDL Verifier (v24.2)
* *SoC Blockset:* Support Package for AMD FPGA and SoC Devices (v24.2.1)
* *Embedded Coder:* Support Package for AMD SoC Devices (v24.2.11)
* *Embedded Coder:* Support Package for ARM Cortex-A Processors (v24.2.1)
* *HDL Coder:* Support Package for Xilinx FPGA and SoC Devices (v24.2.1)
* *HDL Verifier:* Support Package for AMD FPGA and SoC Devices (v24.2.10)

## Project Folder

```text
.
├── data/                           # Stored MATLAB data (e.g. lut tx bits)
├── models/                         # Simulink models for subsystem simulation
├── src/                            # MATLAB files
│   ├── functions/                  # MATLAB functions used by scripts
│   │   ├── analyzeIQSignal.m       # Time and frequency analysis
│   │   ├── apskConst.m             # Generates 16/64 APSK constellations
│   │   ├── interpChain.m           # Interpolation chain design
│   │   ├── OFDMmod.m               # Performs OFDM modulation
│   │   ├── pwr2IQamp.m             # Computes amplitude required for a given power level
│   │   ├── SCfirInterp.m           # Interpolator design for Single-Carrier modulation path
│   │   └── SCmod.m                 # Performs Single-Carrier modulation
│   │
│   └── scripts/                    # Execution scripts
│       ├── basebandSim.m           # Algorithm floating-point simulation
│       ├── NCOmetrics.m            # NCO metrics evaluation
│       └── init.m                  # Loads workspace data for IP model and AXI4-Lite registers
│
├── RFSoC/                          # Hardware implementation and configuration files
│   ├── soc_model.slx               # Top-level Simulink model for IP core generation
│   ├── gs_soc_model_setup.m        # IP core interface port description
│   ├── gs_soc_model_interface.m    # AXI4-Lite interface configuration
│   ├── soc_model_rfdc_setup.m      # Data converters configuration file
│   ├── RF_Init.cfg                 # Data converters initialization file
│
└── project_setup.m                 # setup paths for MATLAB environment
