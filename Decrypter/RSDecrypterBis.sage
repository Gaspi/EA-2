# import main classes
load "GRSCode.sage"
load "RSCryptosystem.sage"


def Decrypt( publicKey, verbose=True):
    
    def Verb(msg):
        if verbose:
            print msg
    
    Verb("Initializing...")
    
    M = publicKey.get("M")
    t = publicKey.get("t")
    
    Field = M.base_ring()
    (k,n) = M.dimensions()
    q = Field.order()
    c = Field.characteristic() # probably 2
    e = log_b(q,c)   # q = c ^ e 
    
    
    Verb("Computing echelon matrix...")
    b = M.echelon_form()
    
    Verb("Computing alpha...")
    
    c = [ b[i,k] for i in range(k) ]
    
    ratio = c[0] / c[1]
    Verb( "Ratio  = " + str(ratio) )
    alphak = -ratio / ( (b[0,k+1] / b[1,k+1]) - ratio)
    
    alpha = [ Field(0), Field(1)] \
          + [ alphak - c[i] * alphak * b[0,k+1] / c[0] / b[i,k+1]  for i in range(2,k)] \
          + [Field(0)] \
          + [ -ratio / ( (b[0,j] / b[1,j]) - ratio) for j in range(k+1,n) ]
    
    
    
    tab = [ True for i in range(q) ]
    for el in alpha:
        tab[ int(el.int_repr()) ] = False
    
    # astuce pour trouver un élément différent des autres ? dans un corps
    
    i = 0
    while not tab[i]:
        i+=1
    
    !!! Error here !!!
    ar = Field(i)
    Field.fetch_int(i)
    
    
    alpha = [ 1/ (ar -  el) for el in alpha]
    alpha[k] = 0
    
    Verb("Possible alpha vector found.")
    
    
    Verb("Computing x vector")
    def L(i, j):
        res = 1
        for l in range(k):
            if (l != i):
                res *= (alpha[j] - alpha[l])
        return res
    
    x =   [ L(j, k) / L(j,j) / b[j,k] for j in range(k) ]
    x +=  [ b[0,j] / b[0,k] * L(0, k) / L(0, j)  for j in range(k,n)]
    
    
    
    Verb("Computing Gpp...")
    Gpp = MatrixSpace(Field, k, k)()
    for i in range(k):
        for j in range(k):
            Gpp[i,j] = x[j] * alpha[j] ^ i
    
    
    Verb("Computing H matrix...")
    H = M[0:k,0:k] * Gpp^(-1)
    
    
    Verb("Computing test code")
    rsd = RSCryptosystem(e, n, k)
    rsd.init_param(alpha, x, H)
    
    if verbose:
        print "Testing solution..."
        if M == rsd.M:
            print "  ->  Code successfully broken !"
        else:
            print "  ->  Algorithm failed..."
    
    return rsd
    
    

