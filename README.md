# The Nano-Trigger: Verilog Neural Network for Particle Classification

![Status](https://img.shields.io/badge/Status-In%20Development-yellow)
![Language](https://img.shields.io/badge/Verilog-IEEE%201364--2005-blue)
![Simulation](https://img.shields.io/badge/Simulation-Icarus%20%26%20GTKWave-green)

## 🔬 Project Overview
This project implements a hardware-based Neural Network (Multilayer Perceptron) entirely in **Verilog HDL**, designed to simulate a **Level-1 Trigger** for High-Energy Physics experiments (like CMS or ATLAS at CERN).

The goal is to classify particle collision events (Signal vs. Background) with **deterministic latency** and minimal resource usage, using **8-bit fixed-point arithmetic**.

### Key Features
* **Hardware-in-the-loop simulation:** Training in Python, inference in Verilog.
* **Quantization:** Custom workflow to convert Float32 weights to 8-bit integers.
* **RTL Design:** Manual implementation of Neurons, ReLU activation, and Layer logic.
* **Zero-Latency Ambition:** Pipeline designed for sub-microsecond decision making.

## 🛠️ Tech Stack
* **Simulation & Synthesis:** Icarus Verilog, GTKWave.
* **Data Generation & Training:** Python (NumPy, Scikit-Learn).
* **Development Environment:** VS Code.

## 📂 Project Structure
```text
verilog-l1-trigger/
├── gen_weights.py      # Python script: Generates synthetic CERN data & quantized weights
├── neuron.v            # Verilog module: Single artificial neuron (MAC + ReLU)
├── neuron_tb.v         # Testbench: Validates the single neuron logic
├── weights_L1.hex      # Memory file: Quantized weights for Layer 1 (Generated)
├── test_data.hex       # Memory file: Synthetic events for simulation
└── README.md           # Project documentation

🚀 How to Run
1. Generate Data & Weights
First, run the Python script to create the synthetic particle events and train the reference model.

Bash
python gen_weights.py

Output: weights_L1.hex, weights_L2.hex, test_data.hex

2. Run Verilog Simulation
Compile and run the testbench for the core processing unit (Neuron).

Bash
iverilog -o wave_test neuron.v neuron_tb.v
vvp wave_test

3. View Waveforms
Analyze the signals and clock cycles using GTKWave.

Bash
gtkwave neuron_wave.vcd

📈 Roadmap
[x] Phase 1: Physics Simulation: Data generation and quantization logic (Python).
[x] Phase 2: Digital Brick: Single Neuron RTL implementation and verification.
[ ] Phase 3: The Network: Connecting neurons into fully connected layers (L1 & Output).
[ ] Phase 4: Full System Test: Processing 2000 events in a continuous stream.

Author: Salvatore Target: CERN Summer Student Programme Project