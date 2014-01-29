# import main classes
load "GRSCode.sage"
load "RSCryptosystem.sage"

# Main parameters
e=5
n=10
k=4
#e=10
#n=1000
#k=700


rsc = RSCryptosystem(e, n, k)
q = rsc.q  # q = 1024
Field.<a> = rsc.F # define the working field GF(q)

rsc.init_random()

publicKey = rsc.public_key()
M = publicKey.get("M")
t = publicKey.get("t")

b = M.echelon_form()
alpha = [0 for i in range(n)]
alpha[1] = 1


# here we try to guess the ratio cb1/cb2
# this ratio should not be equal to any b1j/b2j
ratio = 1
j = k+1
while j < n:
    if ratio == b[0,j] / b[1,j]:
        j = k+1
        ratio *= a
    else:
        j += 1

alpha[k:n] = [ -ratio/( (b[0,j] / b[1,j]) - ratio) for j in range(k,n) ]

for i in range(0,k):
    rk = b[0,k  ] / b[i,k  ]
    rk1= b[0,k+1] / b[i,k+1]
    aux = (rk * alpha[k] - rk1 * alpha[k+1]) / (alpha[k] - alpha[k+1])
    alpha[i] = alpha[k] - rk * alpha[k] / aux

Mpp = M[0:k,0:k]

sol1 = Mpp.solve_right(M[0:k,k])
c = [sol1[i,0] for i in range(k)] + [1]
 
Gp = rsc.kkMatSpace()
for i in range(k):
    for j in range(k):
        Gp[i,j] = c[j+1] * alpha[j+1] ^ i
 
C1 = Mat(Field, k,1)([ -c[0] * alpha[0] ^ i for i in range(k)])
sol = Gp.solve_right(C1)
x = [1] + [sol[i,0] for i in range(k)] + [0 for i in range(k+1,n)]


Gpp = rsc.kkMatSpace()
for i in range(k):
    for j in range(k):
        Gpp[i,j] = x[j] * alpha[j] ^ i
 
H = Mpp * Gpp^(-1)
G = H^(-1) * M # = H^(-1) * E(M)

for i in range(k+1,n):
    x[i] = G[0,i]
 
 
Gtest = rsc.knMatSpace()
for i in range(k):
    for j in range(n):
        Gtest[i,j] = x[j] * alpha[j] ^ i

# Gtest est la matrce du GRS code construite
# à partir aux valeurs de alpha et x calculées
# Htest vérifie M = H * Gtest





# Premier tests avec M = E(M)

# 
# 
# c = [ -b[i,k] for i in range(k)] + [1]
# 
# Gp = rsc.kkMatSpace()
# for i in range(k):
#     for j in range(k):
#         Gp[i,j] = c[j+1] * alpha[j+1] ^ i
# 
# C1 = Mat(Field, k,1)([ -c[0] * alpha[0] ^ i for i in range(k)])
# sol = Gp.solve_right(C1)
# x = [1] + [sol[i,0] for i in range(k)] + [0 for i in range(k+1,n)]
# 
# Gpp = rsc.kkMatSpace()
# for i in range(k):
#     for j in range(k):
#         Gpp[i,j] = x[j] * alpha[j] ^ i
# 
# H = Gpp^(-1)
# G = Gpp * b # = H^(-1) * E(M)
# 
# for i in range(k+1,n):
#     x[i] = G[0,i]
# 
# 
# Gtest = rsc.knMatSpace()
# for i in range(k):
#     for j in range(n):
#         Gtest[i,j] = x[j] * alpha[j] ^ i
# 
# # Gtest est la matrce du GRS code associée aux valeurs de alpha et x calculées
# # H vérifie H*Gtest = b
# # on sait qu'il existe Hp tq Hp b = M
# 

