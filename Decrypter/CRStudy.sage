

load "RandomFunc.sage"
load "RSDecrypterBis.sage"

p = 17
h = 6
u = 3
F.<X> = GF(p^h)


pi = random_permutation(F.base_ring())

A = F.random_element()
B = F.random_element()


def H(u):
    return [ (A + p * B)^u for p in pi ]

def MCoeff(u):
    aux = [ ((A + e * B)^u)._vector_() for e in pi ]
    return Mat(F, h, p)( [  [ aux[i][j] for i in range(p) ]  for j in range(h) ] )

def GetKey(u):
    return {"M" : MCoeff(u), "t": (p - h) // 2}