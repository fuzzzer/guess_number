import numpy as np
from sympy import Matrix
import time

# Create a random 1000x1000 matrix
matrix = np.random.rand(150, 150)

# Convert the NumPy array to a SymPy Matrix
sym_matrix = Matrix(matrix)

# Start the timer
start_time = time.time()

# Compute the reduced row-echelon form (RREF)
rref_matrix, pivot_columns = sym_matrix.rref()

# Stop the timer
end_time = time.time()

# Calculate the elapsed time
elapsed_time = end_time - start_time

print(f"Time taken to find RREF: {elapsed_time} seconds")
