
{% set os = salt['grains.item']('os')['os'] %}

{% set os_family = salt['grains.item']('os_family')['os_family'] %}

{% set cpu_arch = salt['grains.item']('cpuarch')['cpuarch'] %}

{% set kernel = salt['grains.item']('kernel')['kernel'] %}

{% if pillar.vagrant.controller.version is defined %}
{% set vagrant_version = pillar.vagrant.controller.version %}
{% else %}
{% set vagrant_version = '1.3.5' %}
{% endif %}

{% if vagrant_version == "1.2.7" %}
{% set vagrant_hash = '7ec0ee1d00a916f80b109a298bab08e391945243' %}
{% elif vagrant_version == "1.3.3" %}
{% set vagrant_hash = 'db8e7a9c79b23264da129f55cf8569167fc22415' %}
{% elif vagrant_version == "1.3.5" %}
{% set vagrant_hash = 'a40522f5fabccb9ddabad03d836e120ff5d14093' %}
{% endif %}

{% set vagrant_base_url_fragments = [ 'http://files.vagrantup.com/packages/', vagrant_hash ] %}
{% set vagrant_base_url = vagrant_base_url_fragments|join('') %}

{% set vagrant_base_file_fragments = [ 'vagrant_', pillar.vagrant.version, '_x86_64.deb' ] %}
{% set vagrant_base_file = vagrant_base_file_fragments|join('') %}

{%- if pillar.vagrant.controller.enabled %}

{%- if kernel == "Linux" %}

vagrant_download_package:
  cmd.run:
  - name: wget {{ vagrant_base_url }}/{{ vagrant_base_file }}
  - unless: "[ -f /root/{{ vagrant_base_file }} ]"
  - cwd: /root

vagrant_package:
  pkg.installed:
  - sources:
    - vagrant: /root/{{ vagrant_base_file }}
  - require:
    - cmd: vagrant_download_package

/srv/vagrant:
  file:
  - directory
  - makedirs: true
  - require:
    - pkg: vagrant_package

{%- for plugin in pillar.vagrant.controller.plugins %}
{% if plugin.name == 'vagrant-salt' %}
vagrant_install_plugin_{{ plugin.name }}:
  cmd.run:
  - name: "vagrant plugin install {{ plugin.name }}"
  - unless: "[ -d /root/.vagrant.d/gems/gems/vagrant-salt-0.4.0
 ]"
{% endif %}
{%- endfor %}

{%- for image in pillar.vagrant.controller.images %}
vagrant_install_image_{{ image.name }}:
  cmd.run:
  - name: "vagrant box add {{ image.name }} {{ image.url }}"
  - unless: "[ -d /root/.vagrant.d/boxes/{{ image.name }} ]"
{%- endfor %}

{%- for system in pillar.vagrant.controller.systems %}

/srv/vagrant/{{ system.name }}:
  file:
  - directory
  - makedirs: true
  - require:
    - file: /srv/vagrant

/srv/vagrant/{{ system.name }}/Vagrantfile:
  file:
  - managed
  - source: salt://vagrant/conf/Vagrantfile
  - template: jinja
  - defaults:
    system_name: "{{ system.name }}"

{#
/srv/vagrant/{{ system.name }}/salt:
  file:
  - directory
  - makedirs: true
  - require:
    - file: /srv/vagrant/{{ system.name }}
#}

{%- for server in system.servers %}

{#
{%- if server.sync_folders is defined %}
{%- for folder in server.sync_folders %}
/srv/vagrant/{{ system.name }}/{{ folder.name }}:
  file:
  - directory
  - makedirs: true
  - require:
    - file: /srv/vagrant/{{ system.name }}
{%- endfor %}
{%- endif %}
#}

{#
{%- if server.master is defined %}
/srv/vagrant/{{ system.name }}/salt/minion_keys:
  file:
  - directory
  - makedirs: true
  - require:
    - file: /srv/vagrant/{{ system.name }}/salt

/srv/vagrant/{{ system.name }}/salt/{{ server.name }}:
  file:
  - directory
  - makedirs: true
  - require:
    - file: /srv/vagrant/{{ system.name }}/salt

/srv/vagrant/{{ system.name }}/salt/{{ server.name }}/minion.conf:
  file:
  - managed
  - source: salt://vagrant/conf/minion.conf
  - template: jinja
  - defaults:
    server_name: "{{ server.hostname }}"
  - require:
    - file: /srv/vagrant/{{ system.name }}/salt/{{ server.name }}

/srv/vagrant/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pub:
  file:
  - managed
  - source: salt://minion_keys/{{ server.hostname }}.pub
  - require:
    - file: /srv/vagrant/{{ system.name }}/salt/minion_keys

/srv/vagrant/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pem:
  file:
  - managed
  - source: salt://minion_keys/{{ server.hostname }}.pem
  - require:
    - file: /srv/vagrant/{{ system.name }}/salt/minion_keys
{%- endif %}
#}

{#
{% if server.status == "active" %}
start_vagrant_box_{{ server.hostname }}:
  cmd.run:
  - name: vagrant up {{ server.name }}
  - cwd: /srv/vagrant/{{ system.name }}
  - require:
    - file: /srv/vagrant/{{ system.name }}/salt/{{ server.name }}/minion.conf
{%- endif %}
#}

{%- endfor %}

{%- endfor %}

{%- endif %}

{%- endif %}
