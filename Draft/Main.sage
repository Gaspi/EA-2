#e=10
#q=2^e # q=1024
#n=1000
#k=700
#t=38


e=5
q=2^e # q=1024
n=10
k=4
t=2


code = GRSCode(e,n,k)
code.init_random()

input = [2,3,5,7]
v = code.encode( code.vect_from_integers(in) )
w = v + code.random_error
output = code.integers_from_vect( code.decode(w) )
