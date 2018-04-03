#!/usr/bin/env python
import os
import re

backet = {}

regex_line = re.compile("(^([0-9]{1,3}\.){3}[0-9]{1,3})\s+(.*)")

if os.path.exists('local_data.conf'):
  os.remove('local_data.conf')

with open('local_data.hosts','r') as hostlist:
  for line in hostlist:
    result = regex_line.search(line)

    if result is not None:
      ip_record = result.group(1).rstrip()
      rr_record = result.group(3).rstrip(".").split()

      for rr in rr_record:
        if rr != 'localhost':
          if ip_record != '255.255.255.255':
            backet[ rr ] = ip_record

  for key,value in backet.iteritems():
     local_data = 'local-data: "%s IN A %s"'
     f_data = local_data % (key,value)

     l = open('local_data.conf','a')
     l.write(f_data)
     l.write('\n')
     l.close()
