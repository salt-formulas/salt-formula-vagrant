
{#
{% if os == "Windows" %}

{% set base_dir = "c:" %}

{%- if pillar.vagrant.controller.user is defined %}

{%- for user in pillar.system.users %}
{%- if user.name == pillar.vagrant.controller.user %}

{% set base_dir = user.home %}

{%- endif %}
{%- endfor %}

{%- endif %}

{{ base_dir }}\vagrant:
  file:
  - directory
  - makedirs: true

{%- if pillar.vagrant.controller.plugins is defined %}
{%- for plugin in pillar.vagrant.controller.plugins %}

{% if plugin.name == 'vagrant-salt' %}

{% endif %}

{%- endfor %}
{%- endif %}

{%- for image in pillar.vagrant.controller.images %}

{%- endfor %}

{%- for system in pillar.vagrant.controller.systems %}

{{ base_dir }}\vagrant\{{ system.name }}:
  file:
  - directory
  - makedirs: true
  - require:
    - file: {{ base_dir }}\vagrant

{{ base_dir }}\vagrant\{{ system.name }}\Vagrantfile:
  file:
  - managed
  - source: salt://vagrant/conf/Vagrantfile
  - template: jinja
  - defaults:
    system_name: "{{ system.name }}"
  - require:
    - file: {{ base_dir }}\vagrant\{{ system.name }}

{{ base_dir }}\vagrant\{{ system.name }}\salt:
  file:
  - directory
  - makedirs: true
  - require:
    - file: {{ base_dir }}\vagrant\{{ system.name }}\Vagrantfile

{%- for server in system.servers %}

{%- if server.sync_folders is defined %}
{%- for folder in server.sync_folders %}

{{ base_dir }}\vagrant\{{ system.name }}\{{ folder.name }}:
  file:
  - directory
  - makedirs: true
  - require:
    - file: {{ base_dir }}\vagrant\{{ system.name }}
    - file: {{ base_dir }}\vagrant\{{ system.name }}\Vagrantfile

{%- endfor %}
{%- endif %}

{%- if server.master is defined %}

{{ base_dir }}\vagrant\{{ system.name }}\salt\{{ server.name }}:
  file:
  - directory
  - makedirs: true
  - require:
    - file: {{ base_dir }}\vagrant\{{ system.name }}\salt

{{ base_dir }}\vagrant\{{ system.name }}\salt\{{ server.name }}\minion.conf:
  file:
  - managed
  - source: salt://vagrant/conf/minion.conf
  - template: jinja
  - defaults:
    server_name: "{{ server.hostname }}"
  - require:
    - file: {{ base_dir }}\vagrant\{{ system.name }}\salt\{{ server.name }}

{{ base_dir }}\vagrant\{{ system.name }}\salt\minion_keys\{{ server.hostname }}.pub:
  file:
  - managed
  - source: salt://minion_keys/{{ server.hostname }}.pub
  - require:
    - file: {{ base_dir }}\vagrant\{{ system.name }}\salt\{{ server.name }}

{{ base_dir }}\vagrant\{{ system.name }}\salt\minion_keys\{{ server.hostname }}.pem:
  file:
  - managed
  - source: salt://minion_keys/{{ server.hostname }}.pem
  - require:
    - file: {{ base_dir }}\vagrant\{{ system.name }}\salt\{{ server.name }}

{%- endif %}

{% if server.status == "active" %}

start_vagrant_box_{{ server.hostname }}:
  cmd.run:
  - name: "C:\\HashiCorp\\Vagrant\\bin\\vagrant.bat up {{ server.name }}"
  - cwd: "{{ base_dir }}\\vagrant\\{{ system.name }}"
  - require:
    - file: {{ base_dir }}\vagrant\{{ system.name }}\salt\{{ server.name }}\minion.conf

{%- endif %}

{%- endfor %}

{{ base_dir }}\vagrant\setup.bat:
  file:
  - managed
  - source: salt://vagrant/conf/setup.bat
  - template: jinja

{%- endfor %}

{%- endif %}
#}
