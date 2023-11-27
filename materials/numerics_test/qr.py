import numpy as np
from scipy.linalg import qr
import time

# Generate a random 1000x1000 matrix
matrix_np = np.random.rand(1000, 1000)

# Benchmark NumPy row reduction to echelon form using QR decomposition
start_time = time.time()
_, echelon_np = qr(matrix_np, mode='r')
end_time = time.time()

elapsed_time = end_time - start_time
print(f"NumPy rref time using QR decomposition: {elapsed_time} seconds")
