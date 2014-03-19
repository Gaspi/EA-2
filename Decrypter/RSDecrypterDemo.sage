# import main classes
#load "GRSCode.sage"
#load "RSCryptosystem.sage"
load "RSDecrypter.sage"
load "RandomFunc.sage"
import sys

try: size_case
except: size_case = 4


# Main parameters
p = 2
askMsg = False
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
elif size_case == 4:
    p=53
    e=1
    n=50
    k=40
    askMsg = True


Verb("q = " + str(p) + " ^ " + str(e) + "  -  n = " + str(n) + "  -  k = " + str(k))
Verb("Generating code and public key (original cryptosystem : rsc)")

rsc = RSCryptosystem(p, e, n, k)
rsc.init_random()

Verb("Attack on the public key (new cryptosystem : rsd)")

rsd = Decrypt( rsc.public_key() )
 
Verb("Encrypting message")
if askMsg:
    print "Enter message (" + str(k) + " characters) : "
    txtMessage = sys.stdin.read(k)
    message = [ ord(c) for c in txtMessage ]
    Verb("Message : " + txtMessage)
else:
    message = [i for i in range(k) ]
    if k <= 20:
        Verb("message : " + str(message))

ciphered = rsc.cipher_int( message )

Verb("Decrypting using new cryptosystem")
deciphered = rsd.decipher_int(ciphered)

if k <= 20:
    Verb("Deciphered message : " + str([chr(c) for c in deciphered]) )

if deciphered == message:
    Verb("Successfully deciphered !")
else:
    Verb("Failed deciphering...")