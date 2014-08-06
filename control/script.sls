{%- from "vagrant/map.jinja" import control with context %}

{%- if control.script.enabled %}

include:
- vagrant.control.cluster

{%- for cluster_name, cluster in control.cluster.iteritems() %}

{%- for node_name, node in cluster.node.iteritems() %}
{%- set node_fqdn = node_name + '.' + cluster.domain %}

{%- if control.script.user is defined %}

{%- set mount_dir = control.script.user.home + '/vagrant/'+ cluster_name + "/" + node_name %}

{{ mount_dir }}:
  file.directory:
  - user: {{ control.script.user.name }}
  - group: {{ control.script.user.name }}
  - makedirs: true

{%- else %}
{%- set mount_dir = "" %}
{%- endif %}

{{ control.base_dir }}/{{ cluster_name }}/{{ node_name }}:
  file.managed:
  - source: salt://vagrant/files/run.sh
  - template: jinja
  - mode: 777
  - defaults:
    node_name: "{{ node_name }}"
    cluster_name: "{{ cluster_name }}"
    node_fqdn: "{{ node_fqdn }}"
    mount_dir: "{{ mount_dir }}"
    user_name: "{{ control.script.user.name }}"
  - require:
    - file: {{ control.base_dir }}/{{ cluster_name }}

{%- endfor %}

{%- endfor %}

{%- endif %}