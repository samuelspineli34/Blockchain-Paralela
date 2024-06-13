#include "Blockchain.h"

//gcc8 -o TestChain -std=c++11 -fopenmp main.cpp Block.cpp Blockchain.cpp sha256.cpp -lstdc++
//Tempo sequencial: 15 minutos
//Tempo paralelo OpenMP CPU: 3m50.118s
//Tempo paralelo OpenMP GPU: 3m30.938s

int main()
{
    Blockchain bChain = Blockchain();

    cout << "Mining block 1..." << endl;
    bChain.AddBlock(Block(1, "Block 1 Data"));

    cout << "Mining block 2..." << endl;
    bChain.AddBlock(Block(2, "Block 2 Data"));

    cout << "Mining block 3..." << endl;
    bChain.AddBlock(Block(3, "Block 3 Data"));

    return 0;
}
