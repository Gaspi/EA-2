# import main classes
load "GRSCode.sage"
load "RSCryptosystem.sage"

# Main parameters
#e=5
#n=10
#k=4
e=10
n=1000
k=700


rsc = RSCryptosystem(e, n, k)
rsc.init_random()

q = rsc.q  # q = 1024
Field.<a> = rsc.F # define the working field GF(q)


publicKey = rsc.public_key()
M = publicKey.get("M")
t = publicKey.get("t")

print "Public key generated"

b = M.echelon_form()
print "Echelon matrix computed"


# here we try to guess the ratio cb1/cb2
# this ratio should not be equal to any b1j/b2j
ratio = a^(-1)
keepOn = True

count = 0
while keepOn:
    ratio *= a
    count += 1
    keepOn = False
    print str(count) + "-th try. Ratio  = " + str(ratio)
    
    
    alpha = [0 for i in range(n)]
    alpha[1] = 1
    j = k
    while j < n:
        if (b[1,j] != 0) & (ratio == b[0,j] / b[1,j]):
            j = k
            ratio *= a
        else:
            j += 1
    
    alpha[k:n] = [ -ratio / ( (b[0,j] / b[1,j]) - ratio) for j in range(k,n) ]
    
    
    for i in range(2,k):
        l = k+1
        aux = 0
        while (aux == 0) & (l < n):
            rk = b[0,k] / b[i,k]
            rl = b[0,l] / b[i,l]
            aux = (rk * alpha[k] - rl * alpha[l]) / (alpha[k] - alpha[l])
            l += 1
        if (l == n) & (aux == 0):
            print "Fail : " + str(i)
            keepOn = True
            break
        else:
            alpha[i] = alpha[k] - rl * alpha[l] / aux
    

print "Possible alpha computed. Ratio chosen " + str(ratio)


Mpp = M[0:k,0:k]

sol1 = Mpp.solve_right(M[0:k,k])
c = [sol1[i,0] for i in range(k)] + [1]
 
Gp = rsc.kkMatSpace()
for i in range(k):
    for j in range(k):
        Gp[i,j] = c[j] * alpha[j] ^ i

print 3

Ck = Mat(Field, k,1)([ -c[k] * alpha[k] ^ i for i in range(k)])
print 3
sol = Gp.solve_right(Ck)
print 3
x = [sol[i,0] for i in range(k)] + [0 for i in range(k+1,n)] + [1]


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

