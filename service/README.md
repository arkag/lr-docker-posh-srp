# Initial configuration

Create the `/var/logs/docker` directory.

# Service Configuration

Copy the `docker-events.service` file to `/etc/systemd/system/` and run: 

```bash
# Reload the systemctl files
systemctl daemon-reload
# Enable and start the systemctl service
systemctl enable --now docker-events.service
```

# Logrotate Configuration

Copy the `docker-events` logrotate configuration file to `/etc/logrotate.d/`. Modify the file as needed given how full your events file gets on a daily basis.

# Cron configuration

Put the following line into the service user's cron job. This will run logrotate daily on the docker-events log file.

`0 0 * * * /usr/sbin/logrotate /etc/logrotate.d/docker-events >/dev/null 2>&1`