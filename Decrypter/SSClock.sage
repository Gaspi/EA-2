# import main classes
#load "GRSCode.sage"
#load "RSCryptosystem.sage"
load "RSDecrypter.sage"
load "RandomFunc.sage"
import sys




def TimingSS( kInit, nInit, kStep=999999999, nStep=999999999 , p=2, e=8, iterations=2000 ):
    print "p = " + str(p) + "   /   e = " + str(e) + "   /   q = " + str(p^e)
    print "iterations = " + str(iterations)
    n = nInit
    while n <= p^e:
        k = kInit
        while k < n-2:
            rsc = RSCryptosystem(p, e, n, k)
            rsc.init_random()
            pk = rsc.public_key()
            ClockGo()
            for i in range(iterations):
                rsd = QuickDecrypt( pk )
            t = 1000 * ClockGet() / iterations
            print "k = " + str(k) + "   /   n = " + str(n) + "   /   m = " + str(t)
            k+= kStep
        n += nStep
    print "Done."