import numpy as np
import time

# Generate a random 1000x1000 matrix
matrix_np = np.random.rand(1000, 1000)

# Benchmark NumPy row reduction to echelon form
start_time = time.time()
rref_np = np.linalg.matrix_rank(matrix_np)
end_time = time.time()

elapsed_time = end_time - start_time
print(f"NumPy rref time: {elapsed_time} seconds")
