#!/usr/bin/env ruby
require 'fileutils'

def symlink(source, destination)
  STDOUT.puts "Symlinking #{source.inspect} to #{destination.inspect}"
  File.rm(destination) if File.exists?(destination)
  FileUtils.symlink(source, destination)
end

system_config_root = "/var/www/sensori/config/system"

# nginx virtual host
nginx_conf_source = File.join(system_config_root, "nginx_virtual_host.conf")
nginx_conf_destination = "/etc/nginx/sites-available/default"
symlink(nginx_conf_source, nginx_conf_destination)

# unicorn service
unicorn_source = File.join(system_config_root, "unicorn_init.sh")
unicorn_destination = "/etc/init.d/unicorn"
symlink(unicorn_source, unicorn_destination)

# sidekiq service (upstart)
sidekiq_source = File.join(system_config_root, "sidekiq.conf")
sidekiq_destination = "/etc/init/sidekiq.conf"
symlink(sidekiq_source, sidekiq_destination)

# crontab for root user
root_crontab_source = File.join(system_config_root, 'crontab.txt')
STDOUT.puts("Installing #{root_crontab_source} as the root user's crontab")
`crontab #{root_crontab_source}`
