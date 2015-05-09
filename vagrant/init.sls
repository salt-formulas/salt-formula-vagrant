
include:
{% if pillar.vagrant.control is defined %}
- vagrant.control
{% endif %}
