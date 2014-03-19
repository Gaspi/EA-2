# import main classes
#load "GRSCode.sage"
#load "RSCryptosystem.sage"
load "RSDecrypter.sage"
load "RandomFunc.sage"
import sys, time

# Clock function
t0 = 0
times = []
def Clock():
    times.append(time.time() - t0)


try: r
except: r = 3
try: hsr
except: hsr = 8
h = hsr * r

try: p
except: p = 53

q = p ^ h
bF = GF(p)
F.<X> = GF(p^h)

g = F.multiplicative_generator()
# Find a random generator of F_p^r


gpr = g^( (q-1)/(p^r-1) )
aux = randrange(1, p^r-1)
while gcd(aux, p^r-1) != 1:
    aux = randrange(1, p^r-1)
gpr = gpr ^ aux


pi = random_permutation(bF)
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


def MCoeff(u):
    aux = [ (gprci^u)._vector_() * basis for gprci in gprc ]
    return Mat(F, r, p)( [  [ aux[i][j] for i in range(p) ] for j in range(r) ] )

def LCoeff(l):
    lines = r * len(l)
    res = Mat(bF, lines, p)()
    for i in range(len(l)):
        u = l[i]
        aux = [ (gprci^u)._vector_() * basis for gprci in gprc ]
        for j in range(p):
            for k in range(r):
                res[i * r + k, j] = aux[j][k]
    return res

def LCoeff2(l, lines):
    res = Mat(bF, lines, p)()
    ind = 0
    
    for i in range(len(l)):
        u = l[i]
        aux = Mat(bF,p,r)([ e for e in [ (gprci^u)._vector_() * basis for gprci in gprc ] ])
        
        for row in aux.columns():
            res[ind,:] = row
            if res.rank() == (ind+1) :
                ind += 1
            if ind == lines:
                return res

def LightWords(u):
    res= []
    for i in range(0,(u+1)^r):
        weight = 0
        word = 0
        ip = i
        for j in range(r):
            weight += ip % (u+1)
            word = word * p + ip % (u+1)
            ip = ip // (u+1)
        if weight <= u:
            res.append(word)
    return res



# init clock
t0 = time.time()


gprc = [ gci^( (q-1)/(p^r-1) ) for gci in gc ]



baseInv = Mat(bF, h, h)()
for i in range(r):
    v = (gpr^(p^i))._vector_()
    for j in range(h):
        baseInv[i,j] = v[j]
for i in range(r, h):
    for j in range(h):
        baseInv[i,j] = F(randrange(p))

basis = (baseInv^(-1))[:,0:r]

print "Init. done. r : " + str(r) + "  -  hsr : " + str(hsr)






Clock()

# M = LCoeff2([1,2,p+1,3,2*p+1,p+2,4,3*p+1,2*p+2,p^2+p+2,5,4*p+1,3*p+2,p^2+p+3,p^2+2*p+2,0] , 46)
w = 5
M = LCoeff2( LightWords(w) , w * hsr + 1)

Clock()

# Try to find pi
(k,n) = M.dimensions()
b = M.echelon_form()
c = [ b[i,k] for i in range(k) ]
ratio = c[0] / c[1]
alphak = -ratio / ( (b[0,k+1] / b[1,k+1]) - ratio)
alpha = [ bF(0), bF(1)] \
      + [ alphak - c[i] * alphak * b[0,k+1] / c[0] / b[i,k+1]  for i in range(2,k)] \
      + [bF(0)] \
      + [ -ratio / ( (b[0,j] / b[1,j]) - ratio) for j in range(k+1,n) ]

Clock()


nbPossibilities = 0
for c1 in bF:
    if not c1 in alpha:
        for a1 in bF:
            for b1 in bF:
                nbPossibilities += 1
                aux = [ a1 + b1 / (el - c1) for el in alpha]
                aux[k] = a1
                if aux == pi:
                    Verb("Jackpot !")

Verb("Number of possible permutations : " + str(nbPossibilities) )

Clock()

print "Time1 : " + str(times)


