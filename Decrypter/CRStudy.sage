

load "RandomFunc.sage"
load "RSDecrypterBis.sage"

p = 197
h = 24
q = p ^ h
r = 3
F.<X> = GF(p^h)


g = F.gen()
pi = random_permutation(F.base_ring())
d = randrange(q)
t = F.random_element()
while t.minimal_polynomial().degree() < h:
    t = F.random_element()

# c = [ d + discrete_log(t+pi[i], g) for i in range(p)]
gc = [ g^d*(t + e) for e in pi ]
gprc = [ gci^( (q-1)/(p^r-1) ) for gci in gc ]



def MCoeff(u):
    aux = [ (gprci^u)._vector_() for gprci in gprc ]
    return Mat(F, h, p)( [  [ aux[i][j] for i in range(p) ]  for j in range(h) ] )

# Deux problemes :
# - Comment calculer le log discret (discrete_log ne semble pas marcher...)
# - Comment exprimer un elements de \F_{p^r} dans une certaine base ?



# def H(u):
#     return [ (A + p * B)^u for p in pi ]
# 
# def MCoeff(u):
#     aux = [ ((A + e * B)^u)._vector_() for e in pi ]
#     return Mat(F, h, p)( [  [ aux[i][j] for i in range(p) ]  for j in range(h) ] )
# 
# def GetKey(u):
#     return {"M" : MCoeff(u), "t": (p - h) // 2}