# Imports de pacotes ---------------------------------------------------------
using Distributions
using BenchmarkTools
using DataFrames, PrettyTables, CSV


# Funções bases do modelo de Cramer-Lundberg ---------------------------------

# calcula o número de novos clientes com 5% de desistência ao mês,
# considerando a distribuição de Poisson(λ).
function novos_clientes(N₀, poiss, t)
    C = N₀*0.95^t + 20*(1 -0.95^t)*rand(poiss)
    round(Int, C)
end
  
# calcula o sinistro convoluto considerando N~Poisson(λ) e X~Exponential(α).
function sin_convol(expn, cliente)
    N = rand(Poisson(0.1 * cliente))
    sum(rand(expn, N))
end

# função que simula o caminho de 120 meses e verifica se houve ruína ou não.
function testa_ruina(k, N₀, λ, α, U₀, c)

    # vetor do patrimônio líquido
    U = Vector{Float64}(undef, k)

    # gera os tipos de distribuições do modelo
    poiss = Poisson(λ)
    expn  = Exponential(α)

    # executa o primeiro mês para considerar o argumento U₀
    ncliente = novos_clientes(N₀, poiss, 1)
    P₁ = c * ncliente
    S₁ = sin_convol(expn, ncliente)
    U[1] = U₀ + P₁ - S₁

    # executa os demais caminhos para verificar se houve ruína
    R = 0
    for i in 2:k
        ncliente = novos_clientes(N₀, poiss, i)
        Pᵢ = c * ncliente
        Sᵢ = sin_convol(expn, ncliente)
        U[i] = U[i-1] + Pᵢ - Sᵢ
        if U[i] < 0
            R = 1
            break
        end
    end

    return R
end

# executa n_sim vezes o teste de ruina e calcula a probabilidade respectiva
function prob_ruina(n_sim; k=120, N₀=50, λ=50.0, α=5000.0, U₀=10000.0,  c=500.0)
    R = Vector{Float64}(undef, n_sim)
    for i in 1:n_sim
        R[i] = testa_ruina(k, N₀, λ, α, U₀, c)
    end
    return sum(R)/n_sim
end


# Gera os cenários a simular -------------------------------------------------

capital = Float64[0, 10000, 30000, 50000, 70000, 100000, 500000, 1000000];
nseg = [50, 80, 100];
combin_prod = Base.product(nseg, capital) |> collect
combin = [combin_prod...]


# Executa a simulação de todos os cenários k vezes ---------------------------

k_sim = 5000        # 5000, 50000, 100000

probs_ruina = map(combin) do x
    prob_ruina(k_sim, N₀ = x[1], U₀ = x[2])
end


# Coleta os resultados em dataframe e salva em .csv ---------------------------

results = [vcat(collect.(combin)'...) probs_ruina];

df_ruina = DataFrame(nseg = results[:,1],
                    cap_ini = results[:,2],
                    prob_ruina = 100 * results[:,3])

pretty_table(df_ruina,
            nosubheader=true,
            title = "\nResultado das 5 mil simulações";
            formatters = (ft_printf("%6.0f", 2), 
                ft_printf("%5.2f", 3)) )

CSV.write("data/result_$(k_sim)_simul.csv", df_ruina)