#cloud-config

hostname: ${hostname}
manage_etc_hosts: true

# turn off auto update, prevent cloud-init from triggering kernel updates that cause needrestart to reboot and interrupt initialization
package_update: false
package_upgrade: false

# Force use needrestart, disable interactive and automatic restarts globally
write_files:
  - path: /etc/needrestart/conf.d/disable-needrestart.conf
    permissions: '0644'
    content: |
      $nrconf{restart} = 'a';
      $nrconf{kernelhints} = -1;

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

  - path: /etc/systemd/system/k3s-bootstrap.service
    permissions: '0644'
    content: |
      [Unit]
      Description=K3s Node Bootstrapper
      After=network-online.target
      Wants=network-online.target

      [Service]
      Type=oneshot
      ExecStart=/bin/bash /usr/local/bin/bootstrap.sh
      StandardOutput=append:/var/log/bootstrap.log
      StandardError=append:/var/log/bootstrap.log

      [Install]
      WantedBy=multi-user.target

runcmd:
  - systemctl daemon-reload
  - systemctl enable --now k3s-bootstrap.service