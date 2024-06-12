#!/bin/bash 
 
# Function to handle errors for specific commands 
handle_error() { 
 echo "Error occurred: $1" 
} 
 
echo "Starting the uninstallation process..." 
 
# Remove the cron job 
echo "Removing the cron job..." 
sudo rm /etc/cron.d/wingbits || handle_error "Failed to remove cron job." 
echo "Cron job removed or already absent." 
 
# Stop the services 
echo "Stopping the services..." 
sudo systemctl stop readsb lighttpd tar1090 graphs1090 vector || 
handle_error "Failed to stop some services." 
echo "Services stopped or already stopped." 
 
# Disable the services 
echo "Disabling the services..." 
sudo systemctl disable --now readsb lighttpd tar1090 graphs1090 vector || 
handle_error "Failed to disable some services." 
echo "Services disabled or already disabled." 
 
# Uninstall tar1090 
echo "Uninstalling tar1090..." 
sudo /usr/local/share/tar1090/uninstall.sh || handle_error "Failed to 
uninstall tar1090." 
echo "tar1090 uninstalled or not present." 
 
# Uninstall graphs1090 
echo "Uninstalling graphs1090..." 
sudo /usr/share/graphs1090/uninstall.sh || handle_error "Failed to 
uninstall graphs1090." 
echo "graphs1090 uninstalled or not present." 
 
# Purge vector package 
echo "Purging vector package..." 
sudo apt-get purge vector -y || handle_error "Failed to purge vector 
package." 
echo "vector package purged or not present." 
# Remove wingbits cron jobs from crontab 
echo "Removing wingbits cron jobs from crontab..." 
sudo crontab -l | grep 'wingbits' | sudo crontab -r || handle_error "Failed 
to remove wingbits cron jobs from crontab." 
echo "wingbits cron jobs removed or not present." 
echo "Uninstallation process completed, with or without errors."