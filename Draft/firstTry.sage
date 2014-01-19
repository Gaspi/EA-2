e=10
q=2^e
""" q=1024 """
n=1000
k=700
t=38


F.<a> = GF(q, modulus='minimal_weight')


def randelt():
    return F.random_element()


FVectors = MatrixSpace(F, k)
FMatrixkn = MatrixSpace(F, k, n)

y = [ 0 for i in range(n) ]
for i in range(n):
    aux = randelt()
    while aux == 0:
        aux = randelt()
    y[i] = aux

alpha = []
for i in range(n):
    aux = randelt()
    while aux in alpha:
        aux = randelt()
    alpha.append(aux)


m = FMatrixkn()
for i in range(k):
    for j in range(n):
        m[i,j] = y[j] * ( alpha[j] ^  i)



