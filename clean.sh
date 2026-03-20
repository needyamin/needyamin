#!/bin/bash

set -e

echo "🚀 Starting CloudPanel full uninstall..."

# Stop services

echo "🛑 Stopping services..."
systemctl stop cloudpanel 2>/dev/null || true
systemctl stop nginx 2>/dev/null || true
systemctl stop mariadb 2>/dev/null || true

# Stop all PHP-FPM versions

for svc in $(systemctl list-units --type=service --all | grep php | grep fpm | awk '{print $1}'); do
systemctl stop $svc 2>/dev/null || true
done

# Remove packages

echo "🗑 Removing packages..."
apt-get remove --purge -y cloudpanel || true
apt-get remove --purge -y nginx* mariadb* php* || true
apt-get autoremove -y
apt-get autoclean

# Remove directories

echo "🧹 Deleting CloudPanel files..."
rm -rf /etc/cloudpanel
rm -rf /usr/share/cloudpanel
rm -rf /var/lib/cloudpanel
rm -rf /var/log/cloudpanel
rm -rf /opt/cloudpanel

# Remove web/database configs (DANGER: deletes all sites/dbs)

echo "⚠️ Removing web and database configs..."
rm -rf /etc/nginx
rm -rf /etc/php
rm -rf /etc/mysql
rm -rf /var/www

# Remove users/groups if exist

echo "👤 Removing users..."
deluser cloudpanel 2>/dev/null || true
delgroup cloudpanel 2>/dev/null || true

# Reset firewall (optional)

echo "🔥 Resetting firewall..."
ufw --force reset || true

echo "✅ CloudPanel fully removed!"
echo "🔁 Reboot recommended: sudo reboot"
