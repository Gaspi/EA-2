
load "GRSCode.sage"


class RSCryptosystem(GRSCode):
    
    def __init__(self, e=5,n=10,k=4):
        GRSCode.__init__(self, e, n, k)
        self.kkMatSpace = MatrixSpace(self.F, self.k, self.k)
        
    
    
    # initialize the code assuming G is a well formed matrix representing a Reed-Solomon code
    def init(self, G, H, Hinv = None):
        GRSCode.init(self, G)
        self.H = H
        if Hinv == None:
            self.Hinv = H.inverse()
        else:
            self.Hinv = Hinv
        self.M = self.H * self.G # The public key
    
    
    def init_param(self, alpha, y, H, Hinv=None):
        GRSCode.init_param(self, alpha, y)
        self.H = H
        if Hinv == None:
            self.Hinv = H.inverse()
        else:
            self.Hinv = Hinv
        self.M = self.H * self.G # The public key
    
    
    # Generate a random Reed-Solomon code
    def init_random(self, seed=0, algo='vandermonde'):
        GRSCode.init_random(self, seed)
        if algo == 'debug':
            self.H      = self.kkMatSpace().identity_matrix()
            self.Hinv   = self.kkMatSpace().identity_matrix()
        elif algo == 'diag':
            self.H    = self.kkMatSpace()
            self.Hinv = self.kkMatSpace()
            # Fill H and Hinv here ...
            for i in range(self.k):
                for j in range(self.k):
                    if i == j:
                        e = self.nonzerorandelt()
                        self.H[i,j] = e
                        self.Hinv[i,j] = e^(-1)
                    else:
                        self.H[i,j] = 0
                        self.Hinv[i,j] = 0
                        # Here, H is only a diagonal random matrix (invertible &  fast to generate, to invert and to multiply )
        elif algo == 'vandermonde':
            self.H    = self.kkMatSpace()
            aux = [ self.F.fetch_int(e) for e in random_distinct_int(1, self.q, self.k)  ]
            perm =[ i for i in random_distinct_int(0, self.k, self.k)]
            for j in range(self.k):
                y = self.nonzerorandelt()
                for i in range(self.k):
                    self.H[perm[i],j] = y * ( aux[j] ^  i)
            self.Hinv = self.H.inverse()
            
        self.M = self.H * self.G # The public key
     
    
    def public_key(self):
        return {"M" : self.M, "t": self.t}
    
    
    def cipher_vect(self, v, errors = -1):
        return v * self.M + self.random_error(errors)
    
    def cipher_int(self, message, errors = -1):
        if len(message) != self.k:
            raise "word is not the right size"
        return self.cipher_vect( self.vect_from_integers(message), errors)
    
    
    def decipher_vect(self, codeword):
        corrected_word = self.decode(codeword)
        return self.Hinv * corrected_word 
    
    def decipher_int(self, codeword):
        v = self.decipher_vect(codeword)
        return [ int(v[0,i].int_repr() ) for i in range(self.k) ]
    
    
    
    
    
    