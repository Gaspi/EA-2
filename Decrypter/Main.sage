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



Verb("Generating code and public key (original cryptosystem : rsc)")

rsc = RSCryptosystem(e, n, k)
rsc.init_random()

Verb("Attack on the public key (new cryptosystem : rsd)")

rsd = Decrypt( rsc.public_key(), verbose )

Verb("Encrypting list on integers")
message = [i for i in range(k) ]
ciphered = rsc.cipher_int( message )

Verb("Decrypting using new cryptosystem")
deciphered = rsd.decipher_int(ciphered)

if deciphered == message:
    Verb("Successfully deciphered !")
else:
    Verb("Error during deciphering...")