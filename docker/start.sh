#!/bin/bash
WWW_ROOT=/usr/share/nginx/html
if [ -f iptables.firewall.rules ]; then
  echo "IP Tables config found."
  iptables-restore < iptables.firewall.rules
fi

# Check log folders exists for:
# nginx
if [ ! -d /var/log/nginx ]; then
  echo "nginx log folder missing. Creating..."
  mkdir /var/log/nginx
  chmod 750 /var/log/nginx
fi

# supervisord
if [ ! -d /var/log/supervisor ]; then
  echo "Supervisod log folder missing. Creating..."
  mkdir /var/log/supervisor
  chmod 750 /var/log/supervisor
fi

# Check config directory is mounted. If it's mounted, copy the files to the correct place.
if mount | grep /config > /dev/null; then
  echo "Config directory mounted."
  # TT RSS config
  if [ -f /config/ttrss/config.php ]; then
    echo "TTRSS config found."
    cp /config/ttrss/config.php $WWW_ROOT/config.php
    # Set permissions
		chown -R www-data:www-data $WWW_ROOT/
    chmod 770 $WWW_ROOT/config.php
  fi
fi

# Start supervisord process maanger
echo "Start Supervisord."
/usr/bin/supervisord
