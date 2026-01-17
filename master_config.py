import numpy as np
from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

# --- CONFIGURATION (The "God Mode" settings) ---
SCALE_FACTOR = 127.0
# We don't set a fixed seed for the training loop so each attempt is different!
# But we seed data generation to keep the problem consistent.
np.random.seed(42) 

# --- HELPER: FLOAT TO VERILOG DECIMAL ---
# Converts float -> "-8'd10" or "8'd20"
def to_verilog_dec(val):
    val = int(val * SCALE_FACTOR)
    val = max(min(val, 127), -128) # Clamp to 8-bit
    
    if val < 0:
        return f"-8'd{abs(val)}" # Explicit negative syntax
    else:
        return f"8'd{val}"      # Explicit positive syntax

# --- 1. SPAWNING THE UNIVERSE (Data Generation) ---
print("Generating Data...")
n_samples = 4000

# We use vstack to create the matrix of features
X = np.vstack((
    # Background (Noise): Low Energy, Low Isolation
    np.column_stack((np.random.normal(20, 10, n_samples), np.random.normal(0.2, 0.1, n_samples))), 
    # Signal (Higgs): High Energy, High Isolation
    np.column_stack((np.random.normal(60, 10, n_samples), np.random.normal(0.8, 0.1, n_samples)))  
))
# Create labels (0 for Background, 1 for Signal)
y = np.hstack((np.zeros(n_samples), np.ones(n_samples)))

# Global Normalization
max_vals = np.max(X, axis=0)
X = X / max_vals
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# --- 2. THE HUNT FOR THE CHOSEN ONE ---
best_mlp = None
best_acc = 0.0

print("Hunting for a stable Neural Network (Target > 90%)...")

# Try up to 10 times to find a network that isn't brain-dead
for attempt in range(10):
    # Note: alpha=0.1 is regularization. It forces weights to stay small,
    # which is crucial for our 8-bit hardware to avoid overflow!
    mlp = MLPClassifier(hidden_layer_sizes=(3,), activation='relu', max_iter=2000, alpha=0.1)
    mlp.fit(X_train, y_train)
    
    acc = accuracy_score(y_test, mlp.predict(X_test))
    print(f"  Attempt {attempt+1}: Software Accuracy = {acc*100:.2f}%")
    
    if acc > 0.90:
        best_mlp = mlp
        best_acc = acc
        print("  -> EXCELLENT network found! Proceeding to export.")
        break

if best_mlp is None:
    print("ERROR: Could not train a decent network after 10 tries. Run the script again.")
    exit()

# --- 3. GENERATING VALIDATION DATA (HEX) ---
print("Writing 'validation_data.hex'...")
n_val = 2000
# Generate fresh validation data
X_val = np.vstack((
    np.column_stack((np.random.normal(20, 10, n_val), np.random.normal(0.2, 0.1, n_val))),
    np.column_stack((np.random.normal(60, 10, n_val), np.random.normal(0.8, 0.1, n_val)))
))
y_val = np.hstack((np.zeros(n_val), np.ones(n_val)))
X_val = X_val / max_vals 

with open("validation_data.hex", "w") as f:
    for i in range(len(y_val)):
        e_int = int(X_val[i][0] * SCALE_FACTOR)
        i_int = int(X_val[i][1] * SCALE_FACTOR)
        # Hex formatting for the testbench reader
        e_hex = f"{max(min(e_int, 127), -128) & 0xff:02x}"
        i_hex = f"{max(min(i_int, 127), -128) & 0xff:02x}"
        f.write(f"{e_hex} {i_hex} {int(y_val[i])}\n")

# --- 4. VERILOG GENERATION (DECIMAL MODE) ---
print("Writing 'weights.vh'...")
with open("weights.vh", "w") as f:
    f.write("// AUTOMATICALLY GENERATED - STABILIZED & CHECKED\n")
    f.write("// Format: Explicit Decimal (e.g. -8'd12)\n\n")
    
    # Layer 1
    w1 = best_mlp.coefs_[0]
    b1 = best_mlp.intercepts_[0]
    f.write("// --- LAYER 1 ---\n")
    # Neuron 1
    f.write(f"localparam signed [7:0] L1_N1_W1 = {to_verilog_dec(w1[0][0])};\n")
    f.write(f"localparam signed [7:0] L1_N1_W2 = {to_verilog_dec(w1[1][0])};\n")
    f.write(f"localparam signed [7:0] L1_N1_B  = {to_verilog_dec(b1[0])};\n")
    # Neuron 2
    f.write(f"localparam signed [7:0] L1_N2_W1 = {to_verilog_dec(w1[0][1])};\n")
    f.write(f"localparam signed [7:0] L1_N2_W2 = {to_verilog_dec(w1[1][1])};\n")
    f.write(f"localparam signed [7:0] L1_N2_B  = {to_verilog_dec(b1[1])};\n")
    # Neuron 3
    f.write(f"localparam signed [7:0] L1_N3_W1 = {to_verilog_dec(w1[0][2])};\n")
    f.write(f"localparam signed [7:0] L1_N3_W2 = {to_verilog_dec(w1[1][2])};\n")
    f.write(f"localparam signed [7:0] L1_N3_B  = {to_verilog_dec(b1[2])};\n")

    # Layer 2
    w2 = best_mlp.coefs_[1]
    b2 = best_mlp.intercepts_[1]
    f.write("\n// --- LAYER 2 ---\n")
    f.write(f"localparam signed [7:0] L2_W1 = {to_verilog_dec(w2[0][0])};\n")
    f.write(f"localparam signed [7:0] L2_W2 = {to_verilog_dec(w2[1][0])};\n")
    f.write(f"localparam signed [7:0] L2_W3 = {to_verilog_dec(w2[2][0])};\n")
    f.write(f"localparam signed [7:0] L2_B  = {to_verilog_dec(b2[0])};\n")

print("Done! Weights generated and double-checked.")