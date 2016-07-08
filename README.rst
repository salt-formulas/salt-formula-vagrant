
=======
Vagrant 
=======

Vagrant provides easy to configure, reproducible, and portable work environments built on top of industry-standard technology and controlled by a single consistent workflow to help maximize the productivity and flexibility of you and your team.

To achieve its magic, Vagrant stands on the shoulders of giants. Machines are provisioned on top of VirtualBox, VMware, AWS, or any other provider. Then, industry-standard provisioning tools such as shell scripts, Chef, or Puppet, can be used to automatically install and configure software on the machine.

Sample pillars
==============

Vagrant with VirtualBox cluster

.. code-block:: yaml

    vagrant:
      control:
        enabled: true
        cluster:
          clustername:
            provider: virtualbox
            domain: local.domain.com
            control:
              engine: salt
              host: salt.domain.com
            node:
              box1:
                status: suspended 
                image: ubuntu1204
                memory: 512
                cpus: 1
                networks:
                - type: hostonly
                  address: 10.10.10.110

Vagrant with Windows plugin

.. code-block:: yaml

    vagrant:
      control:
        enabled: true
        plugin:
          vagrant-windows:
            version: 1.2.3

Vagrant with presseded images

.. code-block:: yaml

    vagrant:
      control:
        enabled: true
        image:
          ubuntu1204:
            source: http://files.vagrantup.com/precise64.box

Usage
=====

Scripts make simple runnable script for every server in systems

.. code-block:: bash

    vagrant up <nodename>

    vagrant ssh <nodename>

Read more
=========

* http://www.vagrantup.com/
* http://docs.vagrantup.com/v2/
* http://docs.vagrantup.com/v2/synced-folders/
* http://liquidat.wordpress.com/2014/03/03/howto-vagrant-libvirt-multi-multi-machine-ansible-and-puppet/
