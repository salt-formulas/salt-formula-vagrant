#!/bin/sh

cd /srv/vagrant/{{ cluster_name }}
vagrant up {{ node_name }}
{%- if not mount_dir == "" %}
set -e
su {{ user_name }} -c 'sshfs root@{{ node_fqdn }}:/srv {{ mount_dir }}'
su {{ user_name }} -c 'subl {{ mount_dir }}'
{%- endif %}
vagrant ssh {{ node_name }}