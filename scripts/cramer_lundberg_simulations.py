import numpy as np
from numpy.random import exponential as expn
from numpy.random import poisson as poiss


def novos_clientes(N, lbds, i):
    clientes = N*0.95**(i-1) + 20*(1 -(0.95)**(i-1))*poiss(lbds)
    return int(clientes)


def sin_convoluto(alpha, cliente):
    N = poiss(0.1 * cliente)
    S = expn(alpha, N)
    return np.sum(S)


def testa_ruina(K, N0, lbds, alpha, U0, C):
    U = np.array([])

    ncliente = novos_clientes(N0, lbds, 1)
    P1 = C * ncliente
    S1 = sin_convoluto(alpha, ncliente)
    U = np.append(U, U0)
    U[0] = U[0] + P1 + S1

    R = 0
    for i in range(1, K):
        ncliente = novos_clientes(N0, lbds, i)
        P = C * ncliente
        S = sin_convoluto(alpha, ncliente)
        new_U = U[i-1] + P - S
        U = np.append(U, new_U)
        if U[i] < 0:
            R = 1
            break

    return R

def prob_ruina(NSIM, K=120, N0=50, lbds=50, alpha=5000, U0=10000, C=500):
    ruinas = np.array([])
    for _ in range(NSIM):
        ruinas = np.append(ruinas, testa_ruina(K, N0, lbds, alpha, U0, C))
    return np.sum(ruinas) / NSIM

%timeit print(prob_ruina(5000))