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
    
    generator = Field.gen() # typically : a
    
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
    Gpp = MatrixSpace(Field, k, k)()
    for i in range(k):
        for j in range(k):
            Gpp[i,j] = x[j] * alpha[j] ^ i
    
    
    Verb("Computing H matrix...")
    H = M[0:k,0:k] * Gpp^(-1)
    
    
    Verb("Computing test code")
    rsd = RSCryptosystem(e, n, k)
    rsd.init_param(alpha, x, H)
    
    
    Verb("Testing solution...")
    if M == rsd.M:
        print "  ->  Code successfully broken !"
    else:
        print "  ->  Algorithm failed..."
    
    return rsd


