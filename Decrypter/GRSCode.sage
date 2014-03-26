
load "RandomFunc.sage"


class GRSCode:
    
    
    def __init__(self, p=2, e=5,n=10,k=4):
        self.e = e
        self.p = p
        self.q = p^e
        if n > self.q:
            raise BaseException("n is too big : " + str(n) + " > " + str(self.q))
        self.n = n
        if k >= n-2:
            raise BaseException("k is too big : " + str(k) + " >= " + str(n-2) )
        self.k = k
        self.t = (n-k-1) // 2
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
        
    def init_param(self, alpha, y):
        self.y = y
        self.alpha = alpha
        self.G = self.knMatSpace()
        for i in range(self.k):
            for j in range(self.n):
                self.G[i,j] = self.y[j] * ( self.alpha[j] ^  i)
    
    
    # Generate a random Reed-Solomon code
    def init_random(self, seed=0, generalized = True):
        set_random_seed(seed)
        
        if generalized:
            y = [ self.nonzerorandelt() for i in range(self.n) ]
        else:
            y = [ 1 for i in range(self.n) ]
        
        alpha = [ el for el in random_distinct_elements(self.F, self.n)  ]
        
        GRSCode.init_param(self,alpha, y)
    
    
    def randelt(self):
        return self.F.random_element()
    
    def nonzerorandelt(self):
        return BaseP(self.F, randrange(1,self.q) )
    
    
    def random_error(self, weight=-1):
        if weight < 0:
            weight = self.t
        err = [0 for i in range(self.n) ]
        for i in random_distinct_int(0, self.n, weight):
            err[ i ] = self.randelt()
        return Mat(self.F, 1, self.n)(err)
    
    
    def vect_from_integers(self, l):
        return Mat(self.F, 1, len(l))( [  BaseP(self.F, el % self.q) for el in l ]  )
    
    def integers_from_vect(self, vect):
        return [ vect[0,i].int_repr() for i in range(self.k) ]
    
    
    def encode(self, vect):
        return vect * self.G
    
    def encode_int(self, list):
        return self.encode( self.vect_from_integers(list))
    
    
    def decode(self, codeword):
        c = [codeword[0,i] / self.F(self.y[i]) for i in range(self.n)]
        S = Mat( self.F, self.n, 2*self.t + self.k)()
        for j in range(self.t):
            for i in range(self.n):
                S[i,j] = -c[i] * self.alpha[i]^j
        for j in range(self.t + self.k):
            for i in range(self.n):
                S[i, self.t + j] = self.alpha[i]^j
        v = Mat( self.F, self.n, 1)( [ c[i] * self.alpha[i] ^ self.t for i in range(self.n) ] )
        
        res = S.solve_right(v)
        
        R.<X> = (self.F)[]
        
        E = R( X ^ self.t)
        for j in range(self.t):
            E += R( res[j,0] * (X ^ j) )
        
        Ef = R(0)
        for j in range(self.t + self.k):
            Ef += R( res[self.t + j,0] * (X ^ j) )
        
        (f,g) = Ef.quo_rem(E)
        
        if g != 0:
            raise "Error occurred in decoding"
        
        return Mat( self.F, 1, self.k)( f.list() )
        
    
    def decode_int(self, codeword):
        print self.decode(codeword)
        return self.integers_from_vect( self.decode(codeword))
    



    def decode_gao(self, codeword):
            # implement here the decoding algorithm of Gao
            # http://www.math.clemson.edu/~sgao/papers/RS.pdf
            if self.g0 is None:
                self.g0 = 1
                for i in range(self.n):
                    self.g0 *= (x - self.alpha[i])
            g1 = self.PR.lagrange_polynomial( [ (self.alpha[i], codeword[0,i]) for i in range(self.n) ] )
            # Problem : How to divide polynomials ??
            return (g1, self.g0)
        


