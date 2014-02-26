
from sage.misc.randstate import current_randstate

randrange = current_randstate().python_random().randrange


def random_distinct_int(start, end, number):
    size = end - start
    if size < 0:
        raise "Invalid interval"
    if number > size:
        raise "Too small interval"
    
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
    

def random_distinct_elements(Field, n = None):
    o = Field.order()
    if n == None:
        n = o
    for e in random_distinct_int(0,o,n):
        yield Field(e)
    
    
def random_permutation(Field):
    return [ e for e in random_distinct_elements(Field)]




