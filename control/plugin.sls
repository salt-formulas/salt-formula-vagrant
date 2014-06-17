{% from "vagrant/map.jinja" import control with context %}
{%- if control.enabled %}

{%- for name, plugin in control.plugin.iteritems() %}

{%- if name == 'vagrant-windows' %}

{#

vagrant_plugin_{{ name }}_packages:
  pkg.installed:
  - names:
    - ruby-rvm

vagrant_plugin_{{ name }}_rvm_install:
  cmd.run:
  - name: rvm install ruby 2.0.0
  - require:
    - pkg: vagrant_plugin_{{ name }}_packages
  - require_in:
    - cmd: vagrant_install_plugin_{{ name }}

#}

vagrant_install_plugin_{{ name }}:
  cmd.run:
  - name: "vagrant plugin install {{ name }}"
  - unless: "[ -d {{ control.root_dir }}/.vagrant.d/gems/gems/{{ name }}-{{ plugin.version }} ]"

{%- endif %}

{%- endfor %}

{%- endif %}