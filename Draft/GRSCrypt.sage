
class GRSCrypt:
    
    
    def __init__(self, e=5, n=10, k=4, seed=0):
        set_random_seed(seed)
        self.e = e
        self.q = 2^e
        if n > self.q:
            raise "n is too big"
        self.n = n
        if k >= n-2:
            raise "k is too big"
        self.k = k
        self.t = (n-k) / 2
        
        Field.<a> = GF(self.q, modulus='minimal_weight')
        self.F = Field
        self.knMatSpace = MatrixSpace(self.F, self.k, self.n)
        self.kkMatSpace = MatrixSpace(self.F, self.k, self.k)
        
        self._y = [ self.nonzerorandelt() for i in range(self.n) ]
        self._alpha = []
        for i in range(n):
            aux = self.randelt()
            while aux in self._alpha:
                aux = self.randelt()
            self._alpha.append(aux)
            
        self._matG = self.knMatSpace()
        for i in range(self.k):
            for j in range(self.n):
                self._matG[i,j] = self._y[j] * ( self._alpha[j] ^  i)
        
        self._matH = self.kkMatSpace()
        # Fill H here ...
        for i in range(self.k):
            for j in range(self.k):
                if i == j:
                    self._matH[i,j] = self.nonzerorandelt()
                else:
                    self._matH[i,j] = 0
        # Here, H is only a diagonal random matrix
        # -> guarantees it is invertible
        # -> fast to generate, to invert and to multiply
        
        # The public key
        self.M = self._matH * self._matG
        
    def randelt(self):
        return self.F.random_element()
    
    def nonzerorandelt(self):
        res = self.randelt()
        while res == 0:
            res = self.randelt()
        return res
    
    def getKey(self):
        return {"M" : self.M, "t": self.t}
    
    def encode(self, word):
        err = [0 for i in range(self.n) ]
        for i in range(self.t):
            err[ ZZ.random_element(self.n) ] = self.randelt()
        return Mat(self.F, 1, self.k)(word) * self.M + Mat(self.F, 1, self.n)(err)
        
    def decode(self, codeword):
        return 0
    
    
    
    
