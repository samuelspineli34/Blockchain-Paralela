#include "Block.h"
#include "sha256.cuh"
#include <iostream>
#include <cuda_runtime.h>

const int BLOCK_SIZE = 256;

__device__ void CalculateHash(uint32_t index, const char* prevHash, time_t time, const char* data, uint32_t nonce, char* hash) {
    // Concatenate inputs into a single string
    char buffer[256];  // Adjust size as needed
    snprintf(buffer, sizeof(buffer), "%u%s%ld%s%u", index, prevHash, time, data, nonce);

    // Call the SHA-256 function
    sha256(buffer, hash);
}

__global__ void mineBlockKernel(uint32_t* nonce, const char* target, uint32_t difficulty, char* hash, uint32_t index, const char* prevHash, time_t time, const char* data) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    uint32_t localNonce = tid;
    char localHash[65];  // Assuming sha256 produces a 64-character hash

    while (true) {
        // Calculate hash for current nonce
        CalculateHash(index, prevHash, time, data, localNonce, localHash);

        // Check if the hash meets the difficulty target
        bool valid = true;
        for (uint32_t i = 0; i < difficulty; ++i) {
            if (localHash[i] != '0') {
                valid = false;
                break;
            }
        }

        if (valid) {
            // Found a valid nonce, store it and break
            if (atomicMin(nonce, localNonce) > localNonce) {
                // Copy the valid hash to the global memory
                memcpy(hash, localHash, 64);
                hash[64] = '\0';
            }
            break;
        }

        // Increment local nonce and continue
        localNonce += gridDim.x * blockDim.x;
    }
}

void Block::MineBlock(uint32_t nDifficulty) {
    // Allocate GPU memory
    uint32_t* devNonce;
    char* devTarget;
    char* devHash;

    cudaMalloc((void**)&devNonce, sizeof(uint32_t));
    cudaMalloc((void**)&devTarget, nDifficulty + 1);
    cudaMalloc((void**)&devHash, 65);  // Assuming 64-character hash plus null terminator

    // Initialize nonce and target on the device
    uint32_t maxNonce = UINT32_MAX;
    cudaMemcpy(devNonce, &maxNonce, sizeof(uint32_t), cudaMemcpyHostToDevice);

    char* target = new char[nDifficulty + 1];
    memset(target, '0', nDifficulty);
    target[nDifficulty] = '\0';
    cudaMemcpy(devTarget, target, nDifficulty + 1, cudaMemcpyHostToDevice);
    delete[] target;

    // Launch kernel
    mineBlockKernel<<<1, BLOCK_SIZE>>>(devNonce, devTarget, nDifficulty, devHash, _nIndex, sPrevHash.c_str(), _tTime, _sData.c_str());

    // Wait for GPU to finish
    cudaDeviceSynchronize();

    // Copy results back to host
    char hostHash[65];
    cudaMemcpy(&_nNonce, devNonce, sizeof(uint32_t), cudaMemcpyDeviceToHost);
    cudaMemcpy(hostHash, devHash, 65, cudaMemcpyDeviceToHost);
    sHash = std::string(hostHash);

    // Cleanup
    cudaFree(devNonce);
    cudaFree(devTarget);
    cudaFree(devHash);

    std::cout << "Block mined: " << sHash << std::endl;
}
