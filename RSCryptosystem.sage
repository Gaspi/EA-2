


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
    
    # Generate a random Reed-Solomon code
    def init_random(self, seed=0):
        GRSCode.init_random(self, seed)
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
        # Here, H is only a diagonal random matrix
        # -> guarantees it is invertible
        # -> fast to generate, to invert and to multiply
        
        self.M = self.H * self.G # The public key
    
    # Generate a random Reed-Solomon code
    def init_random_debug(self, seed=0):
        GRSCode.init_random_debug(self, seed)
        self.H    = self.kkMatSpace()
        self.Hinv = self.kkMatSpace()
        # Fill H and Hinv here ...
        for i in range(self.k):
            for j in range(self.k):
                if i == j:
                    e = self.nonzerorandelt()
                    self.H[i,j] = 1
                    self.Hinv[i,j] = 1
                else:
                    self.H[i,j] = 0
                    self.Hinv[i,j] = 0
        self.M = self.G # The public key
    
    
    def public_key(self):
        return {"M" : self.M, "t": self.t}
    
    
    def encode(self, message, errors = -1):
        if len(message) != self.k:
            raise "word is not the right size"
        return self.vect_from_integers(message) * self.M + self.random_error(errors)
    
    def decode(self, codeword):
        corrected_word = GRSCode.decode(self, codeword)
        return self.Hinv * corrected_word 
    
    
    
    
    
    