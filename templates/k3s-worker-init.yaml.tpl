#k3s-worker-init.yaml.tpl

hostname: ${hostname}
fqdn: ${hostname}.local
manage_etc_hosts: true
package_update: true

write_files:
  - path: /usr/local/bin/bootstrap.sh
    permissions: '0755'
    content: |
      ${indent(6, file("scripts/bootstrap-worker.sh"))}

runcmd:
  # Must use nohup to run the process in the background, otherwise it will block Cloud-Init
  - nohup /usr/local/bin/bootstrap.sh > /var/log/bootstrap.log 2>&1 &