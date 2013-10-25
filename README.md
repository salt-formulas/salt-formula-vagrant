
# Vagrant 

Vagrant provides easy to configure, reproducible, and portable work environments built on top of industry-standard technology and controlled by a single consistent workflow to help maximize the productivity and flexibility of you and your team.

To achieve its magic, Vagrant stands on the shoulders of giants. Machines are provisioned on top of VirtualBox, VMware, AWS, or any other provider. Then, industry-standard provisioning tools such as shell scripts, Chef, or Puppet, can be used to automatically install and configure software on the machine.

## Sample pillar:

    vagrant:
      controller:
        enabled: true
        plugins:
        - vagrant-salt
        images:
        - name precise64
          url: http://files.vagrantup.com/precise64.box
        systems:
        - name: systemname
          servers:
          - name: box1
            status: suspended 
            image: precise64
            hostname: box1.local.domain.com
            master: salt-master.domain.com
            memory: 512
            cpus: 1
            networks:
            - type: hostonly
              address: 10.10.10.110
            - type: bridged
              interface: wlan0
            sync_folders:
            - name: srv

## Read more

* http://www.vagrantup.com/
* http://docs.vagrantup.com/v2/
* http://docs.vagrantup.com/v2/synced-folders/
