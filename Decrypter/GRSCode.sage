
from sage.misc.randstate import current_randstate

randrange = current_randstate().python_random().randrange


def random_distinct_int(start, end, number):
    size = end - start
    if size < 0:
        raise BaseException("Invalid interval")
    if number > size:
        raise BaseException("Too small interval")
    
    if number <= size / 2:
        ans = []
        for i in range(number):
            t = randrange(start,end)
            while t in ans:
                t = randrange(start,end)
            ans.append(t)
            yield t
    else:
        # We shuffle and take the first "number" elements
        ans = [i for i in range(start, end)]
        for i in range(0, number):
            r = randrange(i, size)
            ( ans[i], ans[r] ) = ( ans[r], ans[i] )
            yield ans[i]
    





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
        
    def init_param(self, alpha, y):
        self.y = y
        self.alpha = alpha
        self.G = self.knMatSpace()
        for i in range(self.k):
            for j in range(self.n):
                self.G[i,j] = self.y[j] * ( self.alpha[j] ^  i)
    
    
    # Generate a random Reed-Solomon code
    def init_random(self, generalized = True, seed=0):
        set_random_seed(seed)
        
        if generalized:
            y = [ self.nonzerorandelt() for i in range(self.n) ]
        else:
            y = [ 1 for i in range(self.n) ]
        
        alpha = [ self.F.fetch_int(e) for e in random_distinct_int(0, self.q, self.n)  ]
        
        GRSCode.init_param(self,alpha, y)
    
    
    def randelt(self):
        return self.F.random_element()
    
    def nonzerorandelt(self):
        return self.F.fetch_int( randrange(1,self.q) )
    
    
    def random_error(self, weight=-1):
        if weight < 0:
            weight = self.t
        err = [0 for i in range(self.n) ]
        for i in random_distinct_int(0, self.n, weight):
            err[ i ] = self.randelt()
        return Mat(self.F, 1, self.n)(err)
    
    
    def vect_from_integers(self, l):
        return Mat(self.F, 1, len(l))( [ self.F.fetch_int(l[i] % self.q) for i in range(len(l)) ]  )
    
    def integers_from_vect(self, vect):
        return [ vect[0,i].int_repr() for i in range(self.k) ]
    
    
    def encode(self, vect):
        return vect * self.G
    
    def encode_int(self, list):
        return self.encode( self.vect_from_integers(list))
    
    
    def decode(self, codeword):
        
        c = [codeword[0,i] / self.y[i] for i in range(self.n)]
        
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
        


