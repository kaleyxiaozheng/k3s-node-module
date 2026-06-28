#k3s-master-init.yaml.tpl

hostname: ${hostname}
manage_etc_hosts: true

write_files:
  - path: /usr/local/bin/bootstrap.sh
    permissions: '0755'
    content: |
      ${bootstrap_sh}
  - path: /usr/local/bin/post-install.sh
    permissions: '0755'
    content: |
      ${post_install_sh}

runcmd:
  - nohup /usr/local/bin/bootstrap.sh > /var/log/bootstrap.log 2>&1 &