{%- from "vagrant/map.jinja" import control with context %}
{%- if control.enabled %}

include:
- vagrant.control.service

{%- for cluster_name, cluster in control.cluster.iteritems() %}

{{ control.base_dir }}/{{ cluster_name }}:
  file.directory:
  - makedirs: true
  - require:
    - file: {{ control.base_dir }}

{{ control.base_dir }}/{{ cluster_name }}/Vagrantfile:
  file.managed:
  - source: salt://vagrant/files/Vagrantfile
  - template: jinja
  - defaults:
    cluster_name: "{{ cluster_name }}"

{%- if cluster.config.engine == "salt" %}

{{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys:
  file.directory:
  - makedirs: true
  - require:
    - file: {{ control.base_dir }}/{{ cluster_name }}

{%- for node_name, node in cluster.node.iteritems() %}
{%- set node_fqdn = node_name+'.'+cluster.domain %}

{{ control.base_dir }}/{{ cluster_name }}/salt/{{ node_name }}:
  file.directory:
  - makedirs: true
  - require:
    - file: {{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys

{{ control.base_dir }}/{{ cluster_name }}/salt/{{ node_name }}/minion.conf:
  file.managed:
  - source: salt://vagrant/files/minion.conf
  - template: jinja
  - defaults:
    node_name: "{{ node_name }}"
    cluster_name: "{{ cluster_name }}"
  - require:
    - file: {{ control.base_dir }}/{{ cluster_name }}/salt/{{ node_name }}

{% if pillar.salt is defined %}
{% if pillar.salt.master is defined %}

cp /srv/salt/minion_keys/{{ node_fqdn }}.pub {{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys/{{ node_fqdn }}.pub:
  cmd.run:
  - unless: "[ -f {{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys/{{ node_fqdn }}.pub ]"
  - require:
    - file: {{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys

cp /srv/salt/minion_keys/{{ node_fqdn }}.pem {{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys/{{ node_fqdn }}.pem:
  cmd.run:
  - unless: "[ -f {{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys/{{ node_fqdn }}.pem ]"
  - require:
    - file: {{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys

chmod 644 {{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys/{{ node_fqdn }}.pem:
  cmd.run:
  - require:
    - cmd: cp /srv/salt/minion_keys/{{ node_fqdn }}.pem {{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys/{{ node_fqdn }}.pem

{% else %}

{{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys/{{ node_fqdn }}.pub:
  file.managed:
  - source: salt://minion_keys/{{ node_fqdn }}.pub
  - require:
    - file: {{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys

{{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys/{{ node_fqdn }}.pem:
  file.managed:
  - source: salt://minion_keys/{{ node_fqdn }}.pem
  - require:
    - file: {{ control.base_dir }}/{{ cluster_name }}/salt/minion_keys

{%- endif %}
{%- endif %}

{%- endfor %}

{%- endif %}

{%- for node_name, node in cluster.node.iteritems() %}

{% if node.get('status', 'suspended') == "active" %}

start_vagrant_box_{{ cluster_name }}_{{ node_name }}:
  cmd.run:
  - name: vagrant up {{ node_name }}
  - cwd: {{ control.base_dir }}/{{ cluster_name }}

{%- endif %}

{%- endfor %}

{%- endfor %}

{%- endif %}