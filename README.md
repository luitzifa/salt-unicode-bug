### Description of Issue/Question
When i store string values with utf-8 characters, i'm unable to use them within file.managed. But not in all cases.

pillar.get ist working:
```
root@monsieurhost:/srv/salt > salt 'mon*' pillar.get foobar:bar1
monsieurhost:
    srtg'ft€@µ§edg!"$%&/()=?`sg
```

### Setup
```
######### pillar/foo.sls #########
# -*- coding: utf-8 -*-
foobar:
  bar1: srtg'ft€@µ§edg!"$%&/()=?`sg
  bar2: §srtg'ft€@µ§edg!"$%&/()=?`sg
  bar3: srtgftedgsg
  bar4: rtgsedrtgsfdgdsrf

######### pillar/top.sls #########
base:
  '*':
    - foo

######### salt/file.jinja #########
{{ salt['pillar.get']('foobar:bar1', 'failed to get pillar') }}

######### salt/file.utf8 #########
# -*- coding: utf-8 -*-
foobar:
  bar1: §srtg'ft€@µ§edg!"$%&/()=?`sg
  bar2: asdfghjghds
  bar3: srtgftedgsg
  bar4: rtgsedrtgsfdgdsrf

######### salt/foo1.sls #########
/tmp/test1:
  file.managed:
    - contents_pillar: foobar:bar1

######### salt/foo2.sls #########
/tmp/test2:
  file.managed:
    - contents: {{ salt['pillar.get']('foobar:bar1', '') }}

######### salt/foo3.sls #########
/tmp/test3:
  file.managed:
    - source: salt://file.jinja
    - template: jinja

######### salt/foo4.sls #########
/tmp/test4:
  file.managed:
    - source: salt://file.utf8

######### salt/top.sls #########
base:
  '*':
    - foo1
    - foo2
    - foo3
    - foo4
```

### Steps to Reproduce Issue
**contents_pillar is working:**
```
root@monsieurhost:/srv/salt > salt 'mon*' state.sls foo1
monsieurhost:
----------
          ID: /tmp/test1
    Function: file.managed
      Result: True
     Comment: File /tmp/test1 updated
     Started: 16:22:16.600100
    Duration: 47.092 ms
     Changes:   
              ----------
              diff:
                  New file

Summary for monsieurhost
------------
Succeeded: 1 (changed=1)
Failed:    0
------------
Total states run:     1
Total run time:  47.092 ms
```
**contents with jinja not:**
```
root@monsieurhost:/srv/salt > salt 'mon*' state.sls foo2
monsieurhost:
    Data failed to compile:
----------
    Rendering SLS 'base:foo2' failed: Jinja error: 'ascii' codec can't decode byte 0xe2 in position 7: ordinal not in range(128)
Traceback (most recent call last):
  File "/usr/lib/python2.7/dist-packages/salt/utils/templates.py", line 368, in render_jinja_tmpl
    output = template.render(**decoded_context)
  File "/usr/lib/python2.7/dist-packages/jinja2/environment.py", line 989, in render
    return self.environment.handle_exception(exc_info, True)
  File "/usr/lib/python2.7/dist-packages/jinja2/environment.py", line 754, in handle_exception
    reraise(exc_type, exc_value, tb)
  File "<template>", line 3, in top-level template code
UnicodeDecodeError: 'ascii' codec can't decode byte 0xe2 in position 7: ordinal not in range(128)

; line 3

---
/tmp/test2:
  file.managed:
    - contents: {{ salt['pillar.get']('foobar:bar1', '') }}    <======================

Traceback (most recent call last):
  File "/usr/lib/python2.7/dist-packages/salt/utils/templates.py", line 368, in render_jinja_tmpl
    output = template.render(**decoded_context)
  File "/usr/lib/python2.7/dist-packages/jinja2/environment.py", line 989, in render
[...]
---
ERROR: Minions returned with non-zero exit code
```
**template-file with jinja not:**
```
root@monsieurhost:/srv/salt > salt 'mon*' state.sls foo3
monsieurhost:
----------
          ID: /tmp/test3
    Function: file.managed
      Result: False
     Comment: Unable to manage file: Jinja error: 'ascii' codec can't decode byte 0xe2 in position 7: ordinal not in range(128)
              Traceback (most recent call last):
                File "/usr/lib/python2.7/dist-packages/salt/utils/templates.py", line 368, in render_jinja_tmpl
                  output = template.render(**decoded_context)
                File "/usr/lib/python2.7/dist-packages/jinja2/environment.py", line 989, in render
                  return self.environment.handle_exception(exc_info, True)
                File "/usr/lib/python2.7/dist-packages/jinja2/environment.py", line 754, in handle_exception
                  reraise(exc_type, exc_value, tb)
                File "<template>", line 1, in top-level template code
              UnicodeDecodeError: 'ascii' codec can't decode byte 0xe2 in position 7: ordinal not in range(128)
              
              ; line 1
              
              ---
              {{ salt['pillar.get']('foobar:bar1', 'failed to get pillar') }}    <======================
              
              Traceback (most recent call last):
                File "/usr/lib/python2.7/dist-packages/salt/utils/templates.py", line 368, in render_jinja_tmpl
                  output = template.render(**decoded_context)
                File "/usr/lib/python2.7/dist-packages/jinja2/environment.py", line 989, in render
              [...]
              ---
     Started: 16:22:30.039266
    Duration: 61.106 ms
     Changes:   

Summary for monsieurhost
------------
Succeeded: 0
Failed:    1
------------
Total states run:     1
Total run time:  61.106 ms
ERROR: Minions returned with non-zero exit code
```
**just file from salt-filesystem obviously works:**
```
root@monsieurhost:/srv/salt > salt 'mon*' state.sls foo4
monsieurhost:
----------
          ID: /tmp/test4
    Function: file.managed
      Result: True
     Comment: File /tmp/test4 updated
     Started: 16:22:32.009920
    Duration: 44.473 ms
     Changes:   
              ----------
              diff:
                  New file
              mode:
                  0644

Summary for monsieurhost
------------
Succeeded: 1 (changed=1)
Failed:    0
------------
Total states run:     1
Total run time:  44.473 ms
```

### Versions Report
master/minion on same host
```
Salt Version:
           Salt: 2016.3.4
 
Dependency Versions:
           cffi: 1.5.2
       cherrypy: Not Installed
       dateutil: 2.4.2
          gitdb: 0.6.4
      gitpython: 1.0.1
          ioflo: Not Installed
         Jinja2: 2.8
        libgit2: 0.24.0
        libnacl: Not Installed
       M2Crypto: 0.21.1
           Mako: 1.0.3
   msgpack-pure: Not Installed
 msgpack-python: 0.4.6
   mysql-python: 1.3.7
      pycparser: 2.14
       pycrypto: 2.6.1
         pygit2: 0.24.0
         Python: 2.7.12 (default, Nov 19 2016, 06:48:10)
   python-gnupg: Not Installed
         PyYAML: 3.11
          PyZMQ: 15.2.0
           RAET: Not Installed
          smmap: 0.9.0
        timelib: Not Installed
        Tornado: 4.2.1
            ZMQ: 4.1.4
 
System Versions:
           dist: Ubuntu 16.04 xenial
        machine: x86_64
        release: 4.4.0-47-generic
         system: Linux
        version: Ubuntu 16.04 xenial
```

### Test current rc2-release on Ubuntu same results

```
root@monsieurhost:~ > rm -rf /tmp/test?

root@monsieurhost:~ > salt 'mon*' state.sls foo1
monsieurhost:
----------
          ID: /tmp/test1
    Function: file.managed
      Result: True
     Comment: File /tmp/test1 updated
     Started: 16:46:51.954611
    Duration: 7.021 ms
     Changes:   
              ----------
              diff:
                  New file

Summary for monsieurhost
------------
Succeeded: 1 (changed=1)
Failed:    0
------------
Total states run:     1
Total run time:   7.021 ms

root@monsieurhost:~ > salt 'mon*' state.sls foo2
monsieurhost:
    Data failed to compile:
----------
    Rendering SLS 'base:foo2' failed: Jinja error: 'ascii' codec can't decode byte 0xe2 in position 7: ordinal not in range(128)
Traceback (most recent call last):
  File "/usr/lib/python2.7/dist-packages/salt/utils/templates.py", line 368, in render_jinja_tmpl
    output = template.render(**decoded_context)
  File "/usr/lib/python2.7/dist-packages/jinja2/environment.py", line 989, in render
    return self.environment.handle_exception(exc_info, True)
  File "/usr/lib/python2.7/dist-packages/jinja2/environment.py", line 754, in handle_exception
    reraise(exc_type, exc_value, tb)
  File "<template>", line 3, in top-level template code
UnicodeDecodeError: 'ascii' codec can't decode byte 0xe2 in position 7: ordinal not in range(128)

; line 3

---
/tmp/test2:
  file.managed:
    - contents: {{ salt['pillar.get']('foobar:bar1', '') }}    <======================

Traceback (most recent call last):
  File "/usr/lib/python2.7/dist-packages/salt/utils/templates.py", line 368, in render_jinja_tmpl
    output = template.render(**decoded_context)
  File "/usr/lib/python2.7/dist-packages/jinja2/environment.py", line 989, in render
[...]
---
ERROR: Minions returned with non-zero exit code

root@monsieurhost:~ > salt 'mon*' state.sls foo3
monsieurhost:
----------
          ID: /tmp/test3
    Function: file.managed
      Result: False
     Comment: Unable to manage file: Jinja error: 'ascii' codec can't decode byte 0xe2 in position 7: ordinal not in range(128)
              Traceback (most recent call last):
                File "/usr/lib/python2.7/dist-packages/salt/utils/templates.py", line 368, in render_jinja_tmpl
                  output = template.render(**decoded_context)
                File "/usr/lib/python2.7/dist-packages/jinja2/environment.py", line 989, in render
                  return self.environment.handle_exception(exc_info, True)
                File "/usr/lib/python2.7/dist-packages/jinja2/environment.py", line 754, in handle_exception
                  reraise(exc_type, exc_value, tb)
                File "<template>", line 1, in top-level template code
              UnicodeDecodeError: 'ascii' codec can't decode byte 0xe2 in position 7: ordinal not in range(128)
              
              ; line 1
              
              ---
              {{ salt['pillar.get']('foobar:bar1', 'failed to get pillar') }}    <======================
              
              Traceback (most recent call last):
                File "/usr/lib/python2.7/dist-packages/salt/utils/templates.py", line 368, in render_jinja_tmpl
                  output = template.render(**decoded_context)
                File "/usr/lib/python2.7/dist-packages/jinja2/environment.py", line 989, in render
              [...]
              ---
     Started: 16:46:57.283693
    Duration: 39.461 ms
     Changes:   

Summary for monsieurhost
------------
Succeeded: 0
Failed:    1
------------
Total states run:     1
Total run time:  39.461 ms
ERROR: Minions returned with non-zero exit code

root@monsieurhost:~ > salt 'mon*' state.sls foo4
monsieurhost:
----------
          ID: /tmp/test4
    Function: file.managed
      Result: True
     Comment: File /tmp/test4 updated
     Started: 16:46:59.159555
    Duration: 55.5 ms
     Changes:   
              ----------
              diff:
                  New file
              mode:
                  0644

Summary for monsieurhost
------------
Succeeded: 1 (changed=1)
Failed:    0
------------
Total states run:     1
Total run time:  55.500 ms

root@monsieurhost:~ > salt --versions-report
Salt Version:
           Salt: 2016.11.0rc2
 
Dependency Versions:
           cffi: 1.5.2
       cherrypy: Not Installed
       dateutil: 2.4.2
          gitdb: 0.6.4
      gitpython: 1.0.1
          ioflo: Not Installed
         Jinja2: 2.8
        libgit2: 0.24.0
        libnacl: Not Installed
       M2Crypto: 0.21.1
           Mako: 1.0.3
   msgpack-pure: Not Installed
 msgpack-python: 0.4.6
   mysql-python: 1.3.7
      pycparser: 2.14
       pycrypto: 2.6.1
         pygit2: 0.24.0
         Python: 2.7.12 (default, Nov 19 2016, 06:48:10)
   python-gnupg: Not Installed
         PyYAML: 3.11
          PyZMQ: 15.2.0
           RAET: Not Installed
          smmap: 0.9.0
        timelib: Not Installed
        Tornado: 4.2.1
            ZMQ: 4.1.4
 
System Versions:
           dist: Ubuntu 16.04 xenial
        machine: x86_64
        release: 4.4.0-47-generic
         system: Linux

```

### Test current release available in pip on Fedora 24 with different results results

Different results on Fedora and salt 2016.11.0 (not rc2) from pip:
```
[root@casteblack:~]
# salt-call --local state.sls foo1
[ERROR   ] Unable to manage file: 'ascii' codec can't encode character u'\u20ac' in position 7: ordinal not in range(128)
local:
----------
          ID: /tmp/test1
    Function: file.managed
      Result: False
     Comment: Unable to manage file: 'ascii' codec can't encode character u'\u20ac' in position 7: ordinal not in range(128)
     Started: 16:55:23.497153
    Duration: 7.13 ms
     Changes:   

Summary for local
------------
Succeeded: 0
Failed:    1
------------
Total states run:     1
Total run time:   7.130 ms

[root@casteblack:~]
# salt-call --local state.sls foo2
[ERROR   ] Unable to manage file: 'ascii' codec can't encode character u'\u20ac' in position 7: ordinal not in range(128)
local:
----------
          ID: /tmp/test2
    Function: file.managed
      Result: False
     Comment: Unable to manage file: 'ascii' codec can't encode character u'\u20ac' in position 7: ordinal not in range(128)
     Started: 16:55:25.656501
    Duration: 6.901 ms
     Changes:   

Summary for local
------------
Succeeded: 0
Failed:    1
------------
Total states run:     1
Total run time:   6.901 ms

[root@casteblack:~]
# salt-call --local state.sls foo3
local:
----------
          ID: /tmp/test3
    Function: file.managed
      Result: True
     Comment: File /tmp/test3 updated
     Started: 16:55:27.329333
    Duration: 12.859 ms
     Changes:   
              ----------
              diff:
                  New file
              mode:
                  0664

Summary for local
------------
Succeeded: 1 (changed=1)
Failed:    0
------------
Total states run:     1
Total run time:  12.859 ms

[root@casteblack:~]
# salt-call --local state.sls foo4
local:
----------
          ID: /tmp/test4
    Function: file.managed
      Result: True
     Comment: File /tmp/test4 updated
     Started: 16:55:29.322574
    Duration: 11.154 ms
     Changes:   
              ----------
              diff:
                  New file
              mode:
                  0664

Summary for local
------------
Succeeded: 1 (changed=1)
Failed:    0
------------
Total states run:     1
Total run time:  11.154 ms

[root@casteblack:~]
# salt-call --versions-report
Salt Version:
           Salt: 2016.11.0
 
Dependency Versions:
           cffi: Not Installed
       cherrypy: Not Installed
       dateutil: Not Installed
          gitdb: Not Installed
      gitpython: Not Installed
          ioflo: Not Installed
         Jinja2: 2.8
        libgit2: Not Installed
        libnacl: Not Installed
       M2Crypto: 0.21.1
           Mako: Not Installed
   msgpack-pure: Not Installed
 msgpack-python: 0.4.8
   mysql-python: Not Installed
      pycparser: Not Installed
       pycrypto: 2.6.1
         pygit2: Not Installed
         Python: 2.7.12 (default, Sep 29 2016, 13:30:34)
   python-gnupg: Not Installed
         PyYAML: 3.12
          PyZMQ: 16.0.2
           RAET: Not Installed
          smmap: Not Installed
        timelib: Not Installed
        Tornado: 4.4.2
            ZMQ: 4.1.6
 
System Versions:
           dist: fedora 24 Twenty Four
        machine: x86_64
        release: 4.8.6-201.fc24.x86_64
         system: Linux
        version: Fedora 24 Twenty Four
 
```

