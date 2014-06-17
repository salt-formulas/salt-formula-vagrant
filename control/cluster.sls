{%- from "vagrant/map.jinja" import control with context %}
{%- if control.enabled %}

{%- for cluster_name, cluster in pillar.vagrant.control.cluster.iteritems() %}

{{ control.base_dir }}/{{ cluster_name }}:
  file.directory:
  - makedirs: true
  - require:
    - file: {{ control.base_dir }}

{{ control.base_dir }}/{{ cluster_name }}/Vagrantfile:
  file.managed:
  - source: salt://vagrant/conf/Vagrantfile
  - template: jinja
  - defaults:
    cluster_name: "{{ cluster_name }}"

{{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys:
  file.directory:
  - makedirs: true
  - require:
    - file: {{ control.base_dir }}/{{ cluster_name }}

{%- for node_name, node in cluster.node.iteritems() %}

{%- if server.master is defined %}

{{ control.base_dir }}/{{ name }}/salt/{{ server.name }}:
  file.directory:
  - makedirs: true
  - require:
    - file: {{ control.base_dir }}/{{ name }}/salt/minion_keys

{{ control.base_dir }}/{{ name }}/salt/{{ server.name }}/minion.conf:
  file.managed:
  - source: salt://vagrant/conf/minion.conf
  - template: jinja
  - defaults:
    server_name: "{{ server.hostname }}"
  - require:
    - file: {{ control.base_dir }}/{{ name }}/salt/{{ server.name }}

{% if pillar.salt is defined %}
{% if pillar.salt.master is defined %}

cp /srv/salt/minion_keys/{{ server.hostname }}.pub {{ control.base_dir }}/{{ name }}/salt/minion_keys/{{ server.hostname }}.pub:
  cmd.run:
  - unless: "[ -f {{ control.base_dir }}/{{ name }}/salt/minion_keys/{{ server.hostname }}.pub ]"
  - require:
    - file: {{ control.base_dir }}/{{ name }}/salt/minion_keys

cp /srv/salt/minion_keys/{{ server.hostname }}.pem {{ control.base_dir }}/{{ name }}/salt/minion_keys/{{ server.hostname }}.pem:
  cmd.run:
  - unless: "[ -f {{ control.base_dir }}/{{ name }}/salt/minion_keys/{{ server.hostname }}.pem ]"
  - require:
    - file: {{ control.base_dir }}/{{ name }}/salt/minion_keys

chmod 644 {{ control.base_dir }}/{{ name }}/salt/minion_keys/{{ server.hostname }}.pem:
  cmd.run:
  - require:
    - cmd: cp /srv/salt/minion_keys/{{ server.hostname }}.pem {{ control.base_dir }}/{{ name }}/salt/minion_keys/{{ server.hostname }}.pem

{% else %}

{{ control.base_dir }}/{{ name }}/salt/minion_keys/{{ server.hostname }}.pub:
  file.managed:
  - source: salt://minion_keys/{{ server.hostname }}.pub
  - require:
    - file: {{ control.base_dir }}/{{ name }}/salt/minion_keys

{{ control.base_dir }}/{{ name }}/salt/minion_keys/{{ server.hostname }}.pem:
  file.managed:
  - source: salt://minion_keys/{{ server.hostname }}.pem
  - require:
    - file: {{ control.base_dir }}/{{ name }}/salt/minion_keys

{%- endif %}
{%- endif %}

{%- endif %}

{% if server.status == "active" %}

start_vagrant_box_{{ server.hostname }}:
  cmd.run:
  - name: vagrant up {{ server.name }}
  - cwd: {{ control.base_dir }}/{{ name }}
  - require:
    - file: {{ control.base_dir }}/{{ name }}/salt/{{ server.name }}/minion.conf

{%- endif %}

{%- endfor %}

{%- endfor %}

{%- endif %}