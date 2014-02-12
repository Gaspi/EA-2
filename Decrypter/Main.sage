# import main classes
load "GRSCode.sage"
load "RSCryptosystem.sage"

verbose = False
small_case = False


def Verb(msg):
    if verbose:
        print msg

# Main parameters
if small_case:
    e=5
    n=10
    k=4
else:
    e=10
    n=1000
    k=700


Verb("Generating code and public key...")

rsc = RSCryptosystem(e, n, k)
rsc.init_random()

q = rsc.q  # q = 2^e = 1024
Field.<a> = rsc.F # define the working field GF(q)
generator = Field.gen() # typically : a

publicKey = rsc.public_key()
M = publicKey.get("M")
t = publicKey.get("t")


Verb("Computing echelon matrix...")
b = M.echelon_form()


Verb("Computing alpha...")
# Here we try to guess the ratio cb1/cb2
def tryRatio(ratio = 1,count = 1):
    Verb( str(count) + "-th try. Ratio  = " + str(ratio) )
    
    for j in range(k,n):
        if ratio == b[0,j] / b[1,j] :
            return tryRatio(ratio * generator, count+1)
            # the ratio should not be equal to any b1j/b2j
    
    alpha = [0 for i in range(n)]
    alpha[1] = 1
    alpha[k:n] = [ -ratio / ( (b[0,j] / b[1,j]) - ratio) for j in range(k,n) ]
    
    
    for i in range(2,k):
        rk   = b[0,k  ] / b[i,k  ]
        rkp1 = b[0,k+1] / b[i,k+1]
        aux = (rk * alpha[k] - rkp1 * alpha[k+1]) / (alpha[k] - alpha[k+1])
        if aux == 0:
            Verb( "Fail : " + str(i) )
            return tryRatio(ratio * generator, count+1)
        else:
            alpha[i] = alpha[k] - rk * alpha[k] / aux
    
    return (alpha, ratio)

(alpha, ratio) = tryRatio()

Verb("Possible alpha vector found. Ratio chosen : " + str(ratio))


Verb("Computing x vector")
def L(i, j):
    res = 1
    for l in range(k):
        if (l != i):
            res *= (alpha[j] - alpha[l])
    return res

x = [ L(j, k) / L(j,j) / b[j,k] for j in range(k) ] +  [ b[0,j] / b[0,k] * L(0, k) / L(0, j)  for j in range(k,n)]


Verb("Computing Gpp...")
Gpp = rsc.kkMatSpace()
for i in range(k):
    for j in range(k):
        Gpp[i,j] = x[j] * alpha[j] ^ i


Verb("Computing H matrix...")
H = M[0:k,0:k] * Gpp^(-1)


Verb("Computing test code")
rsd = RSCryptosystem(e, n, k)
rsd.init_param(alpha, x, H)


Verb("Testing solution...")
if rsc.M == rsd.M:
    print "  ->  Code successfully broken !"
else:
    print "  ->  Algorithm failed..."







#Algorithme de Wieschebrink suivi à la lettre


# Verb("Generating matrix Gp...")
# 
# Mpp = M[0:k,0:k]
# sol1 = Mpp.solve_right(M[0:k,k])
# c = [sol1[i,0] for i in range(k)] + [-1]
# 
# Gp = rsc.kkMatSpace()
# for i in range(k):
#     for j in range(k):
#         Gp[i,j] = c[j] * alpha[j] ^ i
# Verb("Done.")
# 
# 
# Verb("Computing Ck...")
# Ck = Mat(Field, k,1)([ -c[k] * alpha[k] ^ i for i in range(k)])
# Verb("Done.")
# 
# 
# Verb("Computing sol...")
# sol = Gp.solve_right(Ck)
# Verb("Done.")
# 
# 
# Verb("Computing x...")
# x = [sol[i,0] for i in range(k)] + [1] + [0 for i in range(k+1,n)]
# Verb("Done.")

# G = H^(-1) * M # = H^(-1) * E(M)
# for i in range(k+1,n):
#     x[i] = G[0,i]




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

