listen "127.0.0.1:8080"
worker_processes 1
user "rails"
working_directory "/var/www/sensori"
pid "/home/unicorn/pids/unicorn.pid"
stderr_path "/home/unicorn/log/unicorn.log"
stdout_path "/home/unicorn/log/unicorn.log"