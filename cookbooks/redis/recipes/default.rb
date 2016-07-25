#
# Cookbook Name:: redis
# Recipe:: default
#

ey_cloud_report "redis" do
  message "processing redis"
end

enable_package "dev-db/redis" do
  version node[:redis][:version]
  override_hardmask true
  unmask :true
end

package "dev-db/redis" do
  version node[:redis][:version]
  action :upgrade
end

directory "#{node[:redis][:basedir]}" do
  owner 'redis'
  group 'redis'
  mode 0755
  recursive true
  action :create
end

template "/etc/redis_util.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source "redis.conf.erb"
  variables({
    :pidfile => node[:redis][:pidfile],
    :basedir => node[:redis][:basedir],
    :basename => node[:redis][:basename],
    :logfile => node[:redis][:logfile],
    :loglevel => node[:redis][:loglevel],
    :port  => node[:redis][:bindport],
    :unixsocket => node[:redis][:unixsocket],
    :saveperiod => node[:redis][:saveperiod],
    :timeout => node[:redis][:timeout],
    :databases => node[:redis][:databases],
    :rdbcompression => node[:redis][:rdbcompression],
    :hz => node[:redis][:hz]
  })
end


template "/data/monit.d/redis_util.monitrc" do
  owner 'root'
  group 'root'
  mode 0644
  source "redis.monitrc.erb"
  variables({
    :profile => '1',
    :configfile => '/etc/redis_util.conf',
    :pidfile => node[:redis][:pidfile],
    :port => node[:redis][:bindport],
    :bin_path => "/usr/sbin/redis-server"
  })
end

execute "monit reload" do
  action :run
end
