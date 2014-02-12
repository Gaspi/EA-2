# import main classes
#load "GRSCode.sage"
#load "RSCryptosystem.sage"
load "RSDecrypterBis.sage"

verbose = True
small_case = False


def Verb(msg):
    if verbose:
        print msg

# Main parameters
if small_case:
    e=5
    n=10
    k=4
else:
    e=10
    n=1000
    k=700


Verb("Generating code and public key...")

rsc = RSCryptosystem(e, n, k)
rsc.init_random()

Decrypt( rsc.public_key(), verbose )