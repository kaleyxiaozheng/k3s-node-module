#k3s-master-init.yaml.tpl

hostname: ${hostname}
fqdn: ${hostname}.local
manage_etc_hosts: true
package_update: true

write_files:
  - path: /usr/local/bin/bootstrap.sh
    permissions: '0755'
    content: |
      ${indent(6, file("scripts/bootstrap-master.sh"))}
  - path: /usr/local/bin/post-install.sh
    permissions: '0755'
    content: |
      ${indent(6, file("scripts/post-install.sh"))}

runcmd:
  - nohup /usr/local/bin/bootstrap.sh > /var/log/bootstrap.log 2>&1 &