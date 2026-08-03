#cloud-config

hostname: ${hostname}
manage_etc_hosts: true

package_update: false
package_upgrade: false

user: ubuntu
password: ${vm_password}
chpasswd: { expire: False }
ssh_authorized_keys:
  - ${ssh_public_key}

write_files:
  - path: /etc/needrestart/conf.d/disable-needrestart.conf
    permissions: '0644'
    content: |
      $nrconf{restart} = 'a';
      $nrconf{kernelhints} = -1;

  - path: /etc/k3s-bootstrap.env
    permissions: '0600'
    content: |
      IS_MASTER="${is_master}"
      HOSTNAME_VAL="${hostname}"
      TAILSCALE_KEY="${tailscale_auth_key}"
      MASTER_HOST_VAL="${master_ip}"
      K3S_TOKEN_VAL="${k3s_token}"

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

  # Create Systemd service
  - path: /etc/systemd/system/k3s-bootstrap.service
    permissions: '0644'
    content: |
      [Unit]
      Description=K3s Node Bootstrapper
      After=network-online.target
      Wants=network-online.target

      [Service]
      Type=oneshot
      EnvironmentFile=/etc/k3s-bootstrap.env
      ExecStart=/bin/bash /usr/local/bin/bootstrap.sh
      StandardOutput=append:/var/log/bootstrap.log
      StandardError=append:/var/log/bootstrap.log

      [Install]
      WantedBy=multi-user.target

runcmd:
  - systemctl daemon-reload
  - systemctl enable --now k3s-bootstrap.service
