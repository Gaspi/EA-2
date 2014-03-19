load "RandomFunc.sage"
load "RSDecrypter.sage"


#r = 2
#hsr = 2
h = hsr * r
# h = 120

try: p
except: p = 251

q = p ^ h
bF = GF(p)
F.<X> = GF(p^h)

# Find a random generator of F_p^r
g = F.multiplicative_generator()
gpr = g^( (q-1)/(p^r-1) )
aux = randrange(1, p^r-1)
while gcd(aux, p^r-1) != 1:
    aux = randrange(1, p^r-1)
gpr = gpr ^ aux


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
    for j in range(h):
        baseInv[i,j] = F(randrange(p))

b = baseInv ^(-1)

print "Init. done. r : " + str(r) + "  -  hsr : " + str(hsr)


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
# LCoeff([1,2,p+1]).rank()        # 9 as expected 
# LCoeff([1,2,p+1,p^2+1]).rank()  # only 9 because p^2+1 = p^2 * (p+1)  (rotation)
# LCoeff([1,2,p+1,3, 2*p+1, p+2]).rank()  # 18 because p^2+1 = p^2 * (p+1)  (rotation)
# LCoeff([1,2,p+1,3, 2*p+1, p+2, p^2+p+1]).rank()  # only 19 surprisingly

# M = LCoeff([1,2,p+1,3, 2*p+1, p+2,4,p+3,3*p+1,2*p+2,2*p^2+p+1])
# M.rank()
# 33
# On a 33 lignes indépendantes qui sont des évaluations en les pi(i)
# de polynomes de degrés 33 = 4*8 + 1 maximum (h/r = 8 et le poids max modulo p est 4)
# Ceci devrait permettre de rétrouver  pi alors qu'on a choisit r petit (racine de h environ 5)



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


u = 0
ra = 0
ok = ""
# while (u < hsr) & (ra < u * hsr + 1):
while (u < hsr+3) & (ra < u * hsr + 1):
    u += 1
    ra = LCoeff(LightWords(u)).rank()
    if ra >= u * hsr + 1:
        ok = "  (OK)"
    print str(u) + " : " + str(ra) + " -> " + str(u*hsr+1) + ok
    


hsr+=1



#print "Success : " + str(u)
#print "Degree max : " + str(u*hsr+1)


# Problemes :
# - Comment calculer plus efficacement le log discret (discrete_log ne semble pas etre très efficace...)

