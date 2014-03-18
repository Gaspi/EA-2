# import main classes
#load "GRSCode.sage"
#load "RSCryptosystem.sage"
import sys
load "RSDecrypterBis.sage"
load "RandomFunc.sage"


p=53
e=1
n=10
k=4


Verb("Generating code and public key (original cryptosystem : rsc)")

rsc = RSCryptosystem(p, e, n, k)
rsc.init_random()

Verb("Attack on the public key (new cryptosystem : rsd)")

rsd = Decrypt( rsc.public_key() )
 
Verb("Encrypting message")
message = [i for i in range(k) ]
Verb("message : " + str(message))

ciphered = rsc.cipher_int( message )

Verb("Decrypting using new cryptosystem")
deciphered = rsd.decipher_int(ciphered)

Verb("Deciphered message : " + ("".join([str(c) for c in deciphered])) )

if deciphered == message:
    Verb("Successfully deciphered !")
else:
    Verb("Error during deciphering...")