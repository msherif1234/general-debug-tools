# phyton3
from datetime import datetime
from datetime import timedelta
import re
from collections import defaultdict
import pprint
import sys

file_name = sys.argv[1]
total = 0.0

fh = open(file_name)
ts_diff = defaultdict(list)
dict = defaultdict(list)

pp = pprint.PrettyPrinter(indent=4)
for line in fh:
    try:
        if "Reattaching pod" in line:
            pod_name = re.search("pod (.+?) to SDN", line).group(1).strip("''")
            dict[pod_name].append(line[6:21])
              
        if "CNI_ADD" in line:
            pod_name = re.search('CNI_ADD (.+?) got IP', line).group(1)
            dict[pod_name].append(line[6:21])
    except:
        pass
    

for k, v in dict.items():
    if len(v) > 1:
        d1 = datetime.strptime(v[0], "%H:%M:%S.%f")
        d2 = datetime.strptime(v[1], "%H:%M:%S.%f")
        ts_diff[k].append(timedelta.total_seconds(d2 - d1))
        total = total + timedelta.total_seconds(d2 - d1)

sorted_x = sorted(ts_diff.items(), key=lambda kv: kv[1])
pp.pprint(sorted_x)  
pp.pprint(total)
#pp.pprint(ts_diff)

fh.close()
