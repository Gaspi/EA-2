


class GRSCode:
    
    
    def __init__(self, e=5,n=10,k=4):
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
        self.PR = PolynomialRing(self.F, 'x')
        self.g0 = None
        
    
    # initialize the code assuming G is a well formed matrix representing a Reed-Solomon code
    def init(self, G):
        self.G = G
        self.y = [ self.G[0,i] for i in range(self.n) ]
        self.alpha = [self.G[1,i] / self.y[i] for i in range(self.n) ]
    
    # Generate a random Reed-Solomon code
    def init_random(self, seed=0):
        set_random_seed(seed)
        
        self.y = [ self.nonzerorandelt() for i in range(self.n) ]
        self.alpha = []
        for i in range(self.n):
            aux = self.randelt()
            while aux in self.alpha:
                aux = self.randelt()
            self.alpha.append(aux)
            
        self.G = self.knMatSpace()
        for i in range(self.k):
            for j in range(self.n):
                self.G[i,j] = self.y[j] * ( self.alpha[j] ^  i)
        
        
    def randelt(self):
        return self.F.random_element()
    
    def nonzerorandelt(self):
        res = self.F.random_element()
        while res == 0:
            res = self.F.random_element()
        return res
    
    def random_error(self, weight=-1):
        if weight < 0:
            weight = self.t
        err = [0 for i in range(self.n) ]
        for i in range(weight):
            err[ ZZ.random_element(self.n) ] = self.randelt()
        return Mat(self.F, 1, self.n)(err)
    
    
    def vect_from_integers(self, l):
        return Mat(self.F, 1, len(l))( [ self.F.fetch_int(l[i]) for i in range(len(l)) ]  )
    
    def integers_from_vect(self, vect):
        return [ vect[0,i].int_repr() for i in range(self.k) ]
    
    def encode(self, vect):
        return vect * self.G
    
    
    def decode(self, codeword):
        # implement here the decoding algorithm of Gao
        # http://www.math.clemson.edu/~sgao/papers/RS.pdf
        if self.g0 is None:
            self.g0 = 1
            for i in range(self.n):
                self.g0 *= (x - self.alpha[i])
        g1 = self.PR.lagrange_polynomial( [ (self.alpha[i], codeword[0,i]) for i in range(self.n) ] )
        # Problem : How to divide polynomials ??
        return (g1, self.g0)
    
    
    
    
