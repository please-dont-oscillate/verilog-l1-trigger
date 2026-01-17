# The Nano-Trigger: FPGA Neural L1 Trigger 🚀

![Status](https://img.shields.io/badge/Status-Completed-success)
![Language](https://img.shields.io/badge/Verilog-IEEE%201364--2005-blue)
![Accuracy](https://img.shields.io/badge/Hardware_Accuracy-91.0%25-brightgreen)
![Simulation](https://img.shields.io/badge/Simulation-Icarus%20%26%20GTKWave-orange)

## 🔬 Project Overview
This project implements a hardware-based **Deep Neural Network** entirely in **Verilog HDL**, designed to simulate a Level-1 (L1) Trigger for particle physics experiments (like CMS or ATLAS).

The goal is to classify particle collision events (Signal vs. Background) with **deterministic latency** and minimal resource usage, using **8-bit fixed-point arithmetic**. The system distinguishes high-energy signal events (e.g., Higgs Boson decays) from background noise in real-time.

### Key Features
* **Hardware-in-the-Loop:** Automated Python workflow (`master_config.py`) that trains the AI and auto-generates Verilog parameters (`weights.vh`).
* **Zero-Latency Architecture:** Fully parallel pipeline designed for single-clock cycle decision making.
* **Optimized Arithmetic:** Implemented custom bit-shifting normalization (`>>> 7`) to replace expensive division and prevent DSP saturation.
* **High Specificity:** Tuned to prioritize signal purity (0 False Positives achieved).

## 🛠️ Tech Stack
* **Simulation & Synthesis:** Icarus Verilog, GTKWave.
* **Data Generation & Training:** Python (NumPy, Scikit-Learn).
* **Development Environment:** VS Code.

## 🧠 System Architecture

The system implements a fully parallel dense neural network (Multilayer Perceptron):
* **Input Layer:** 2 physical features (Energy, Isolation) normalized to 8-bit integers.
* **Hidden Layer (Layer 1):** 3 neurons in parallel with ReLU activation.
* **Output Layer (Layer 2):** 1 neuron with binary threshold classification.
* **Data Flow:** `Inputs` → `Layer 1 (Feature Extraction)` → `Layer 2 (Decision)` → `TRIGGER`.

## 📊 Results & Validation

The hardware logic was validated against **4,000 simulated collision events**.

| Metric | Software Model (Float) | Hardware (Verilog 8-bit) |
| :--- | :---: | :---: |
| **Accuracy** | 99.9% | **91.0%** |
| **False Positives** | 0 | **0** (Perfect Specificity) |
| **Missed Events** | 2 | 359 |

> **Note:** The trade-off between sensitivity and specificity was managed via integer quantization. The system successfully rejected 100% of background noise.

## 📂 Project Structure
```text
verilog-l1-trigger/
├── master_config.py    # MASTER SCRIPT: Generates data, trains NN, writes Verilog weights
├── nano_trigger.v      # TOP MODULE: Connects Layer 1 and Layer 2
├── layer_1.v           # Parallel processing layer (3 Neurons)
├── layer_2.v           # Decision layer (Weighted Sum)
├── neuron.v            # Basic processing unit (MAC + ReLU + Bit-Shift Normalization)
├── weights.vh          # Auto-generated file containing trained weights (Do not edit)
├── validation_data.hex # Auto-generated synthetic events for mass testing
├── verification_tb.v   # Automated Testbench: Validates 4000 events
└── README.md           # Project documentation


🚀 How to Run
1. Generate Weights & Configure Hardware
Run the Python master script. This will train a fresh neural network, check for stability (>90%), and generate the hardware configuration files.

Bash
python master_config.py

Output: weights.vh (Verilog parameters) and validation_data.hex (Test patterns).

2. Run Verilog Simulation
Compile the entire processor and the verification testbench.

Bash
iverilog -o trigger_sim neuron.v layer_1.v layer_2.v nano_trigger.v verification_tb.v
vvp trigger_sim

3. Analyze Waveforms (Optional)
To see the internal decision process for specific events:

Bash
gtkwave verification.vcd

📈 Roadmap (Completed)
[x] Phase 1: Physics Simulation: Data generation and quantization logic (Python).

[x] Phase 2: Digital Brick: Single Neuron RTL implementation.

[x] Phase 3: The Network: Connecting neurons into fully connected layers (L1 & L2).

[x] Phase 4: Optimization: Fixed "Stuck-at-One" bugs using bit-shift normalization.

[x] Phase 5: Validation: Mass testing on 4000 events with >90% accuracy.

Author: Salvatore