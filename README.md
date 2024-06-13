# Comparação de otimização do K-means para a classificação de regiões de acordo com a taxa de poluição utilizando OpenMP e MPI
Integrantes: Lucas Fiori Magalhaes Machado\
             Rafael Ferreira Garcia Almeida\
             Samuel Spineli Rodrigues
# ⚙️ Como executar
Para compilar o programa no Parcode é necessário utilizar o comando mpic++ -std=c++11 -o polutionkmeans pollutionkmeans.cpp -fopenmp, observe que é necessário utilizar a clausula de comando -std=c++11, pois o compilador do Parcode está em uma versão desatualizada de 2011, o -fopenmp é para a utilização do openmp enquanto o mpic++ é para a utilização do MPI.\
Para compilar a versão somente com o openMP a linha de comando é a seguinte nvcc -o TestChain -std=c++11 main.cpp Blockchain.cpp sha256.cu Block.cu -lstdc++ -Wno-deprecated-gpu-targets.

# Como funciona
O programa utiliza tecnicas de paralelismo na classe block.cpp pois ela é responsável pelo algoritmo de mineração na blockchain.

# Função paralelizada

MineBlock: 
\
OpenMP (CPU): Utilização de diretivas como #pragma omp parallel for para distribuir o trabalho entre múltiplos threads na CPU.
\
OpenMP (GPU): Diretiva #pragma omp target map(tofrom: found, local_sHash) com map(to: _nIndex, sPrevHash, _tTime, _sData) para direcionar a execução para a GPU e mapear dados para os dispositivos de memória da GPU.
\
CUDA: Uso de kernels CUDA definidos com __global__ void mineBlockKernel(...) para executar operações intensivas na GPU, como cálculo de hashes.
kmeans: Função principal para executar o algoritmo, o MPI é utilizado aqui afim de distribuir os dados de um centroíde para diferentes processos. Após os centróides terem seus dados atualizados, é realizado o broadcast dos processos para que esse novo valor seja recebido para todos os processos.

# Desempenho alcançado
Tempo Sequencial : 15 minutos (O código não terminou de executar no parcode e após 15 minutos a sessão é encerrada)

OpenMP (CPU): 3 minutos e 50 segundos \
Speedup: 3,91 

OpenMP (GPU): 3 minutos e 30 segundos \
Speedup: 4,28 

CUDA: \
Speedup: 

# TestChain (Código utilizado como base para o trabalho)
Here are the files for the TestChain C++ tutorial I have placed on my website http://davenash.com/2017/10/build-a-blockchain-with-c/
