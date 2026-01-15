import numpy as np
import matplotlib.pyplot as plt
from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

# --- 1. CONFIGURATION (aka “how to fit floats into 8 bits without crying”) ---
SCALE_FACTOR = 127.0   # Because apparently our hardware likes drama: -128..127

def quantized_to_hex(val):
    """Turns a signed int into a hex string. Yes, computers like fancy notation."""
    val = int(val)
    if val < 0: 
        val = (1 << 8) + val
    return f'{val & 0xff:02x}' # Example: 255 -> ff

# --- 2. DATA GENERATION (aka 'fake CERN events, don't tell anyone') ---
# let's create 2000 events.
# Input features (What the sensor sees):
# X1: total energy (GeV)
# X2:"Transverse" energy (concentration)
# X3: Isolation (how clean the signal around it is)

np.random.seed(42)
n_samples = 2000

# Background (boring stuff): low energy, messy
bg_energy = np.random.normal(20, 10, n_samples)
bg_isol = np.random.normal(0.2, 0.1, n_samples)
bg_data = np.column_stack((bg_energy, bg_isol))
bg_labels = np.zeros(n_samples) # Label 0, because background = sad

# Signal (Higgs-ish, fancy stuff): high energy, clean
sig_energy = np.random.normal(60, 10, n_samples)
sig_isol = np.random.normal(0.8, 0.1, n_samples)
sig_data = np.column_stack((sig_energy, sig_isol))
sig_labels = np.ones(n_samples) # Label 1, because signal = awesome

# Combine them, because why not?
X = np.vstack((bg_data, sig_data))
y = np.hstack((bg_labels, sig_labels))

# Normalize everything between 0 and 1. Hardware hates floats bigger than 1.
X = X / np.max(X, axis=0)

# Train/test split (the obligatory ritual)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# --- 3. NEURAL NETWORK TRAINING (MLP, because we love pain) ---
# Architecture: 2 Inputs -> 3 Hidden Neurons -> 1 Output 
#  We use ReLU because it's super easy in hardware (if x
mlp = MLPClassifier(hidden_layer_sizes=(3,), activation='relu', solver='adam', max_iter=1000)
mlp.fit(X_train, y_train)

# Test accuracy. Because feelings don’t count, numbers do.
preds = mlp.predict(X_test)
print(f"Software Accuracy (Float32): {accuracy_score(y_test, preds) * 100:.2f}%")

# --- 4. QUANTIZATION MAGIC (aka “Make this poor FPGA happy”) ---
print("\n--- Estrazione Pesi per Verilog ---")

# MLP has weights (coefs_) and bias (intercepts_) matrices
# Layer 1: Input -> Hidden
w1 = mlp.coefs_[0]      # Matrices 2x3
b1 = mlp.intercepts_[0] # Vector 3

# Layer 2: Hidden -> Output
w2 = mlp.coefs_[1]      # Matrices 3x1
b2 = mlp.intercepts_[1] # Vector 1

# Function to save in Verilog readable format ($readmemh)
def export_layer(weights, biases, name):
    print(f"Exporting {name}...")
    with open(f"{name}.hex", "w") as f:
        # weights
        # We iterate by target neuron
        rows, cols = weights.shape
        for c in range(cols): # For each neuron in the next layer
            line = []
            # Weights connected to this neuron
            for r in range(rows):
                w_float = weights[r][c]
                w_int = int(w_float * SCALE_FACTOR)
                # Clamp for safety between -127 and 127
                w_int = max(min(w_int, 127), -128)
                line.append(quantized_to_hex(w_int))
            
            # Bias of this neuron
            b_float = biases[c]
            b_int = int(b_float * SCALE_FACTOR)
            b_int = max(min(b_int, 127), -128)
            line.append(quantized_to_hex(b_int))
            
            # We write: W1 W2... Bias
            f.write(" ".join(line) + "\n")
            print(f"  Neuron {c}: {line} (Raw: {weights[:,c]}, Bias: {biases[c]})")

export_layer(w1, b1, "weights_L1")
export_layer(w2, b2, "weights_L2")

# Save a tiny sample for Verilog testbench. Only 10, because we're nice.
with open("test_data.hex", "w") as f:
    for i in range(10): 
        # Inputs need to be scaled for the testbench too!
        in1 = int(X_test[i][0] * SCALE_FACTOR) 
        in2 = int(X_test[i][1] * SCALE_FACTOR)
        label = int(y_test[i])
        f.write(f"{quantized_to_hex(in1)} {quantized_to_hex(in2)} {label}\n")

print("\nnDone! .hex files ready. FPGA is waiting. Or crying. Probably both.")
print("  - weights_L1.hex: First layer weights")
print("  - weights_L2.hex: Output layer weights")
print("  - test_data.hex:  Data to test your circuit")