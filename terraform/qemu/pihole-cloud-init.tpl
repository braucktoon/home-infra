#cloud-config

packages:
  - curl
  - unbound
  - qemu-guest-agent
  - keepalived
  - fail2ban
  - rsyslog
  - sqlite3

write_files:
  - path: /etc/unbound/unbound.conf.d/pi-hole.conf
    content: |
      server:
        verbosity: 1

        interface: 127.0.0.1
        port: 5335
        do-ip4: yes
        do-ip6: yes
        do-udp: yes
        do-tcp: yes

        # May be set to yes if you have IPv6 connectivity
        prefer-ip6: no

        # Use this only when you downloaded the list of primary root servers!
        root-hints: "/var/lib/unbound/root.hints"

        # Trust glue only if it is within the server's authority
        harden-glue: yes

        # Require DNSSEC data for trust-anchored zones, if such data is absent, the zone becomes bogus
        harden-dnssec-stripped: yes

        # Don't use Capitalization randomization as it known to cause DNSSEC issues sometimes
        use-caps-for-id: no

        # Reduce EDNS reassembly buffer size.
        edns-buffer-size: 1232

        # Ensure kernel buffer is large enough to not lose messages in traffic spikes
        so-rcvbuf: 1m

        # Perform prefetching of close-to-expiry message cache entries
        prefetch: yes

        # One thread should be sufficient, can be increased on beefy machines
        num-threads: 1

        # Ensure privacy of local IP ranges
        private-address: 192.168.0.0/16
        private-address: 169.254.0.0/16
        private-address: 172.16.0.0/12
        private-address: 10.0.0.0/8
        private-address: fd00::/8
        private-address: fe80::/10

  - path: /var/lib/unbound/root.hints
    content: |
      .	3600000	IN	NS	a.root-servers.net.
      a.root-servers.net.	3600000	IN	A	198.41.0.4
      .	3600000	IN	NS	b.root-servers.net.
      b.root-servers.net.	3600000	IN	A	199.9.14.201
      .	3600000	IN	NS	c.root-servers.net.
      c.root-servers.net.	3600000	IN	A	192.33.4.12
      .	3600000	IN	NS	d.root-servers.net.
      d.root-servers.net.	3600000	IN	A	199.7.91.13
      .	3600000	IN	NS	e.root-servers.net.
      e.root-servers.net.	3600000	IN	A	192.203.230.10
      .	3600000	IN	NS	f.root-servers.net.
      f.root-servers.net.	3600000	IN	A	192.5.5.241
      .	3600000	IN	NS	g.root-servers.net.
      g.root-servers.net.	3600000	IN	A	192.112.36.4
      .	3600000	IN	NS	h.root-servers.net.
      h.root-servers.net.	3600000	IN	A	198.97.190.53
      .	3600000	IN	NS	i.root-servers.net.
      i.root-servers.net.	3600000	IN	A	192.36.148.17
      .	3600000	IN	NS	j.root-servers.net.
      j.root-servers.net.	3600000	IN	A	192.58.128.30
      .	3600000	IN	NS	k.root-servers.net.
      k.root-servers.net.	3600000	IN	A	193.0.14.129
      .	3600000	IN	NS	l.root-servers.net.
      l.root-servers.net.	3600000	IN	A	199.7.83.42
      .	3600000	IN	NS	m.root-servers.net.
      m.root-servers.net.	3600000	IN	A	202.12.27.33

  - path: /etc/pihole/setupVars.conf
    content: |
      PIHOLE_INTERFACE=eth0
      PIHOLE_DNS_1=127.0.0.1#5335
      PIHOLE_DNS_2=
      QUERY_LOGGING=true
      INSTALL_WEB_SERVER=true
      INSTALL_WEB_INTERFACE=true
      LIGHTTPD_ENABLED=true
      CACHE_SIZE=10000
      DNS_FQDN_REQUIRED=true
      DNS_BOGUS_PRIV=true
      DNSMASQ_LISTENING=local
      BLOCKING_ENABLED=true
      DNSSEC=true

  - path: /etc/keepalived/keepalived.conf
    content: |
      vrrp_instance VI_1 {
        state MASTER
        interface eth0
        virtual_router_id 55
        priority 150
        advert_int 1
        unicast_src_ip 10.0.0.17
        unicast_peer {
            10.0.0.234
        }

        authentication {
            auth_type ${keepalived_auth_type}
            auth_pass ${keepalived_pass}
        }

        virtual_ipaddress {
            10.0.0.235/24
        }
      }

  - path: /etc/fail2ban/jail.local
    content: |
      [sshd]
      enabled = true
      port    = 22
      filter  = sshd
      logpath = /var/log/auth.log
      maxretry = 3
      
runcmd:
  # Update SSH configuration to be more secure.
  - sed -i '/^PasswordAuthentication/s/.*/PasswordAuthentication no/' /etc/ssh/sshd_config || echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
  - sed -i '/^PermitRootLogin/s/.*/PermitRootLogin no/' /etc/ssh/sshd_config || echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
  - sed -i '/^UseDNS/s/.*/UseDNS no/' /etc/ssh/sshd_config || echo 'UseDNS no' >> /etc/ssh/sshd_config
  - sed -i '/^PermitEmptyPasswords/s/.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config || echo 'PermitEmptyPasswords no' >> /etc/ssh/sshd_config
  - sed -i '/^ChallengeResponseAuthentication/s/.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config || echo 'ChallengeResponseAuthentication no' >> /etc/ssh/sshd_config
  - sed -i '/^X11Forwarding/s/.*/X11Forwarding no/' /etc/ssh/sshd_config || echo 'X11Forwarding no' >> /etc/ssh/sshd_config
  - sed -i '/^GSSAPIAuthentication/s/.*/GSSAPIAuthentication no/' /etc/ssh/sshd_config || echo 'GSSAPIAuthentication no' >> /etc/ssh/sshd_config

    # install pihole silently, relies on setupVars.conf file being present in /etc/pihole. it is set above
  - |
    curl -sSL https://install.pi-hole.net | bash -s -- --unattended
    
    #add some pihole configuration to save disk space and block icloud pr.  
  - |
    echo 'MAXDBDAYS=90' >> /etc/pihole/pihole-FTL.conf
    echo 'BLOCK_ICLOUD_PR=true' >> /etc/pihole/pihole-FTL.conf
  
    #add some pihole block lists to the gravity db and update gravity.  
  - |
    # Blocklist URLs to be added
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt', 1, 'cloud-init');"
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts', 1, 'cloud-init');"
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://adaway.org/hosts.txt', 1, 'cloud-init');"
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://v.firebog.net/hosts/AdguardDNS.txt', 1, 'cloud-init');"
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://v.firebog.net/hosts/Easyprivacy.txt', 1, 'cloud-init');"
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://v.firebog.net/hosts/Prigent-Ads.txt', 1, 'cloud-init');"
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt', 1, 'cloud-init');"
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt', 1, 'cloud-init');"
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser', 1, 'cloud-init');"
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://raw.githubusercontent.com/chadmayfield/my-pihole-blocklists/master/lists/pi_blocklist_porn_top1m.list', 1, 'cloud-init');"
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://v.firebog.net/hosts/Prigent-Adult.txt', 1, 'cloud-init');"

    # Update Pi-hole gravity to apply the new blocklists
    pihole -g

    sudo apt remove --purge sqlite3 -y
    sudo apt autoremove -y

    # echo all custom local DNS into custom.list
  - |
    echo "10.0.0.2 nas" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.4 fluff" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.5 pihole" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.6 backup-nas" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.7 floof" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 lola" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.9 biggie" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 nginx-proxy-manager.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 ha.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 nas.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 pihole.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 scrypted.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 z2m.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 heimdall.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 portainer.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 plex.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 grafana.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 jenkins.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 uptime-kuma.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 backup-nas.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 prowlarr.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 qbittorrent.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 sonarr.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 vw.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 emby.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 sabnzbd.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 radarr.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 zwave.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.10 gomey" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.233 new-proxy" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.14 banana" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 media.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 pve.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.15 media" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.8 tubesync.mchouseface.com" | sudo tee -a /etc/pihole/custom.list
    echo "10.0.0.4 vw.dev.mchouseface.com" | sudo tee -a /etc/pihole/custom.list

  - |
    # Restart services to apply configurations
    systemctl restart unbound
    pihole restartdns

  - |
    # Set Pi-hole to start on boot
    systemctl enable pihole-FTL.service
    systemctl enable unbound

  - systemctl start qemu-guest-agent
  - systemctm enable keepalived
  - systemctm enable fail2ban
  - systemctl enable ssh
  - systemctl restart ssh
  - reboot

final_message: "Pi-hole and Unbound installation and configuration complete!"