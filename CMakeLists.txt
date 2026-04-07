cmake_minimum_required(VERSION 3.18)

project(MRTR_GPU LANGUAGES CXX CUDA)

# -----------------------------
# C++ and CUDA standards
# -----------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

# -----------------------------
# Include directories
# -----------------------------
include_directories(${CMAKE_SOURCE_DIR}/include)

# -----------------------------
# Automatically gather all .cu sources
# -----------------------------
file(GLOB_RECURSE CUDA_SOURCES ${CMAKE_SOURCE_DIR}/src/*.cu)

# -----------------------------
# Build executable
# -----------------------------
add_executable(run ${CUDA_SOURCES})

# -----------------------------
# GPU architectures for fat binaries
# Turing (7.5) + Ampere (8.6)
# -----------------------------
set_target_properties(run PROPERTIES
    CUDA_ARCHITECTURES "75;86"
)

# -----------------------------
# Optional: Statically link CUDA runtime
# Uncomment if you want to include the CUDA runtime in the executable
# -----------------------------
# set_target_properties(run PROPERTIES CUDA_RUNTIME_LIBRARY Static)

# -----------------------------
# Optional: Separable compilation (speeds up incremental builds)
# -----------------------------
# set_target_properties(run PROPERTIES CUDA_SEPARABLE_COMPILATION ON)

# -----------------------------
# Optional: Optimization flags
# For release builds, uncomment the next line
# -----------------------------
# target_compile_options(run PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-O3>)
