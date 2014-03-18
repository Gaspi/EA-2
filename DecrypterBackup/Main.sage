# import main classes
#load "GRSCode.sage"
#load "RSCryptosystem.sage"
load "RSDecrypterBis.sage"
import sys

try: size_case
except: size_case = 2

try: verbose
except: verbose = True
def Verb(msg):
    if verbose:
        print msg


# Main parameters
if size_case == 1:
    e=5
    n=10
    k=4
elif size_case == 2:
    e=8
    n=40
    k=20
elif size_case == 3:
    e=10
    n=1000
    k=700



Verb("Generating code and public key (original cryptosystem : rsc)")

rsc = RSCryptosystem(e, n, k)
rsc.init_random()

Verb("Attack on the public key (new cryptosystem : rsd)")

rsd = Decrypt( rsc.public_key(), verbose )
 
Verb("Encrypting message")
if size_case != 2:
    message = [i for i in range(k) ]
    if size_case == 1:
        Verb("message : " + str(message))
else:
    print "Enter message (" + str(k) + " characters) : "
    txtMessage = sys.stdin.read(k)
    message = [ ord(c) for c in txtMessage ]
    Verb("Message : " + txtMessage)

ciphered = rsc.cipher_int( message )

Verb("Decrypting using new cryptosystem")
deciphered = rsd.decipher_int(ciphered)

if size_case == 2:
    Verb("Deciphered message : " + ("".join([chr(c) for c in deciphered])) )

if deciphered == message:
    Verb("Successfully deciphered !")
else:
    Verb("Error during deciphering...")