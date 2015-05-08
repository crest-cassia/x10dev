import sys
import json
import time
print sys.argv[1]
print sys.argv

time.sleep(1);
o = {'result': 1234.56789 }
f = open('_output.json', 'w')
f.write( json.dumps(o) )
