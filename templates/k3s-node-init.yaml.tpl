#cloud-config

hostname: ${hostname}
manage_etc_hosts: true
%{ if is_master ~}
# configure for Master 
package_update: true
%{ else ~}
# configure for Worker
fqdn: ${hostname}.local
package_update: true
%{ endif ~}

write_files:
  - path: /usr/local/bin/bootstrap.sh
    permissions: '0755'
    content: |
      ${bootstrap_sh}
%{ if is_master ~}
  - path: /usr/local/bin/post-install.sh
    permissions: '0755'
    content: |
      ${post_install_sh}
%{ endif ~}

runcmd:
  - nohup /usr/local/bin/bootstrap.sh > /var/log/bootstrap.log 2>&1 &