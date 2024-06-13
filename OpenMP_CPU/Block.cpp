#include "Block.h"
#include "sha256.h"
#include <omp.h> // Incluir o cabeçalho OpenMP

Block::Block(uint32_t nIndexIn, const string &sDataIn) : _nIndex(nIndexIn), _sData(sDataIn) {
    _nNonce = 0;
    _tTime = time(nullptr);
    sHash = _CalculateHash();
}

void Block::MineBlock(uint32_t nDifficulty) {
    char cstr[nDifficulty + 1];
    for (uint32_t i = 0; i < nDifficulty; ++i) {
        cstr[i] = '0';
    }
    cstr[nDifficulty] = '\0';

    string str(cstr);
    bool found = false;

    #pragma omp parallel
    {
        string hash;
        uint32_t local_nonce;
        while (!found) {
            #pragma omp atomic capture
            local_nonce = ++_nNonce;

            hash = sha256(to_string(_nIndex) + sPrevHash + to_string(_tTime) + _sData + to_string(local_nonce));

            if (hash.substr(0, nDifficulty) == str) {
                #pragma omp critical
                {
                    if (!found) {
                        found = true;
                        sHash = hash;
                        cout << "Block mined: " << sHash << endl;
                    }
                }
            }
        }
    }
}

inline string Block::_CalculateHash() const {
    stringstream ss;
    ss << _nIndex << sPrevHash << _tTime << _sData << _nNonce;
    return sha256(ss.str());
}
