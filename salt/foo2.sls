/tmp/test2:
  file.managed:
    - contents: {{ salt['pillar.get']('foobar:bar1', '') }}
