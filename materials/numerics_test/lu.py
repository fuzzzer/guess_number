import numpy as np
from scipy.linalg import lu
import time

# Generate a random 1000x1000 matrix
matrix_np = np.random.rand(1000, 1000)

# Benchmark NumPy row reduction to echelon form using LU decomposition
start_time = time.time()
_, _, echelon_np = lu(matrix_np)
end_time = time.time()

elapsed_time = end_time - start_time
print(f"NumPy rref time using LU decomposition: {elapsed_time} seconds")
