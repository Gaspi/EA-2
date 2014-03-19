

load "RandomFunc.sage"
load "RSDecrypter.sage"

p = 197
h = 24
q = p ^ h
r = 3
bF = GF(p)
F.<X> = GF(p^h)


g = F.multiplicative_generator()
gpr = g^( (q-1)/(p^r-1) )
pi = random_permutation(F.base_ring())
d = randrange(q)
t = F.random_element()
while t.minimal_polynomial().degree() < h:
    t = F.random_element()

# # Quite long to compute ...
# c= [ 0 for i in range(p) ]
# for i in range(p):
#     c[i] = (d + discrete_log(t+pi[i], g) ) % (q-1)
#     print i


gc = [ g^d*(t + e) for e in pi ]
gprc = [ gci^( (q-1)/(p^r-1) ) for gci in gc ]



baseInv = Mat(bF, h, h)()
for i in range(r):
    v = (gpr^(p^i))._vector_()
    for j in range(h):
        baseInv[i,j] = v[j]
for i in range(r, h):
    baseInv[i,i] = 1

b = baseInv ^(-1)



def MCoeff(u):
    aux = [ (gprci^u)._vector_() * b for gprci in gprc ]
    return Mat(F, r, p)( [  [ aux[i][j] for i in range(p) ] for j in range(r) ] )

def LCoeff(l):
    lines = r * len(l)
    res = Mat(F, lines, p)()
    
    for i in range(len(l)):
        u = l[i]
        aux = [ (gprci^u)._vector_() * b for gprci in gprc ]
        for j in range(p):
            for k in range(r):
                res[i * r + k, j] = aux[j][k]
    return res


# example of tests
LCoeff([1,2,p+1]).rank()        # 9 as expected 
LCoeff([1,2,p+1,p^2+1]).rank()  # only 9 because p^2+1 = p^2 * (p+1)  (rotation)
LCoeff([1,2,p+1,3, 2*p+1, p+2]).rank()  # 18 because p^2+1 = p^2 * (p+1)  (rotation)
LCoeff([1,2,p+1,3, 2*p+1, p+2, p^2+p+1]).rank()  # only 19 surprisingly

M = LCoeff([1,2,p+1,3, 2*p+1, p+2,4,p+3,3*p+1,2*p+2,2*p^2+p+1])
M.rank()
# 33
# On a 33 lignes indépendantes qui sont des évaluations en les pi(i)
# de polynomes de degrés 32 = 4*8 maximum (h/r = 8 et le poids max modulo p est 4)
# Ceci devrait permettre de rétrouver  pi alors qu'on a choisit r petit (racine de h environ 5)






# def H(u):
#     return [ (A + p * B)^u for p in pi ]
# 
# def MCoeff(u):
#     aux = [ ((A + e * B)^u)._vector_() for e in pi ]
#     return Mat(F, h, p)( [  [ aux[i][j] for i in range(p) ]  for j in range(h) ] )
# 
# def GetKey(u):
#     return {"M" : MCoeff(u), "t": (p - h) // 2}