#!/bin/sh

{%- for system in pillar.vagrant.controller.systems  %}
{%- if system.name == system_name %}
{%- for server in system.servers  %}
{%- if server.name == server_name %}

cd /srv/vagrant/{{ system.name }}
vagrant up {{ server.name }}
vagrant ssh {{ server.name }}

{%- endif %}
{%- endfor %}

{%- endif %}
{%- endfor %}