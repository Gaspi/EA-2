
from sage.misc.randstate import current_randstate

randrange = current_randstate().python_random().randrange

try: verbose
except: verbose = True
def Verb(msg):
    if verbose:
        print msg

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
    

def BaseP(Field, e):
    if Field.polynomial().degree() > 1:
        X = Field(Field.variable_name())
    else:
        X = Field(1)
    p = Field.characteristic()
    power = Field(1)
    res = Field(0)
    while e > 0:
        res += power * Field(e % p)
        power *= X
        e = e // p
    return res

def random_distinct_elements(Field, n = None):
    o = Field.order()
    if n == None:
        n = o
    for e in random_distinct_int(0,o,n):
        yield BaseP(Field,e)
    
    
def random_permutation(Field):
    return [ e for e in random_distinct_elements(Field)]




