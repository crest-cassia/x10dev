import sys
import json
import time
import random
print sys.argv
mu = float(sys.argv[1])
sigma = float(sys.argv[2])
seed = int(sys.argv[3])

random.seed(seed)
r = random.gauss(mu, sigma)

time.sleep(r);
o = {'duration': r }
f = open('_output.json', 'w')
f.write( json.dumps(o) )
f.flush
