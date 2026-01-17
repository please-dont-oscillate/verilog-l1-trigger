import numpy as np
from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split

# 1. THE USUAL SUSPECTS (Setup phase)
SCALE_FACTOR = 127.0
np.random.seed(42)  # 42: The answer to life, the universe, and reproducible bugs
n_samples = 2000

# Background Noise (The boring stuff nobody wants)
# Gaussian distribution of mediocrity
bg_energy = np.random.normal(20, 10, n_samples)
bg_isol = np.random.normal(0.2, 0.1, n_samples)
bg_data = np.column_stack((bg_energy, bg_isol))
bg_labels = np.zeros(n_samples) # Label 0: Total trash

# Signal Events (The "Eureka!" moments)
# High energy, high isolation. The cool kids.
sig_energy = np.random.normal(60, 10, n_samples)
sig_isol = np.random.normal(0.8, 0.1, n_samples)
sig_data = np.column_stack((sig_energy, sig_isol))
sig_labels = np.ones(n_samples) # Label 1: Nobel Prize material

# Merge and Normalize (Making everyone feel equally important)
X = np.vstack((bg_data, sig_data))
y = np.hstack((bg_labels, sig_labels))
max_val = np.max(X, axis=0)
X = X / max_val # Squishing the universe into a 0 to 1 box

# Shuffle (Chaos mode engaged)
# Because ordered data makes neural networks lazy
indices = np.arange(X.shape[0])
np.random.shuffle(indices)
X = X[indices]
y = y[indices]

print(f"Generating {len(y)} events for hardware validation (Good luck, silicon)...")

# 2. EXPORTING TO THE REAL WORLD (Verilog)
# Format: HexEnergy HexIsol ExpectedTrigger (The Rosetta Stone for hardware)
with open("validation_data.hex", "w") as f:
    for i in range(len(y)):
        # Quantize inputs: Welcome to the low-res 8-bit life
        # 0.5 becomes 63. Precision is overrated anyway.
        eng_int = int(X[i][0] * SCALE_FACTOR)
        iso_int = int(X[i][1] * SCALE_FACTOR)
        
        # Safety Clamp: Preventing numeric explosions and overflow tears
        eng_int = max(min(eng_int, 127), -128)
        iso_int = max(min(iso_int, 127), -128)
        
        label = int(y[i])
        
        # Write to file: XX YY Z (e.g., 1a 05 0)
        # The "& 0xff" is basically an exorcism for negative number formatting
        f.write(f"{eng_int & 0xff:02x} {iso_int & 0xff:02x} {label}\n")

print("Done! 'validation_data.hex' created. Go feed the machine.")
print("Preview of the sacred texts:", open("validation_data.hex").readlines()[:3])