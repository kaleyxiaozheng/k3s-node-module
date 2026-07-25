#cloud-config

hostname: ${hostname}
manage_etc_hosts: true

%{ if is_master ~}
package_update: true
%{ else ~}
fqdn: ${hostname}.local
package_update: true
%{ endif ~}

write_files:
  # 1. write bootstrap script
  - path: /usr/local/bin/bootstrap.sh
    permissions: '0755'
    content: |
      ${bootstrap_sh}
%{ if is_master ~}
  # 2. write post-install script
  - path: /usr/local/bin/post-install.sh
    permissions: '0755'
    content: |
      ${post_install_sh}
%{ endif ~}

  # 3. create independent Systemd service (彻底避免被 Cloud-Init 清理杀死)
  - path: /etc/systemd/system/k3s-bootstrap.service
    permissions: '0644'
    content: |
      [Unit]
      Description=K3s Node Bootstrapper
      After=network-online.target cloud-final.service
      Wants=network-online.target

      [Service]
      Type=oneshot
      ExecStart=/bin/bash /usr/local/bin/bootstrap.sh
      StandardOutput=append:/var/log/bootstrap.log
      StandardError=append:/var/log/bootstrap.log

      [Install]
      WantedBy=multi-user.target

# Start the Systemd service
runcmd:
  - systemctl daemon-reload
  - systemctl enable --now k3s-bootstrap.service