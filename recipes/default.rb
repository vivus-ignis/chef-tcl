#
# Cookbook Name:: tcl
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

tcl_major_version = node['tcl']['version'].split('.')[0..1].join('.')

remote_file "Tcl distribution, v. #{node['tcl']['version']}" do
  path   "#{Chef::Config[:file_cache_path]}/tcl-#{node['tcl']['version']}.tar.gz"
  source "http://downloads.sourceforge.net/project/tcl/Tcl/#{node['tcl']['version']}/tcl#{node['tcl']['version']}-src.tar.gz"

  not_if { ::File.exists? "#{Chef::Config[:file_cache_path]}/tcl-#{node['tcl']['version']}.tar.gz" }
end

execute "Unpack tcl distribution" do
  cwd     Chef::Config[:file_cache_path]
  command "tar xzf #{Chef::Config[:file_cache_path]}/tcl-#{node['tcl']['version']}.tar.gz" 
  
  not_if  { ::File.directory? "#{Chef::Config[:file_cache_path]}/tcl#{node['tcl']['version']}" }
end

is_64bit = node['kernel']['machine'] == "x86_64" ? "--enable-64bit" : ""

bash "Compile tcl" do
  cwd "#{Chef::Config[:file_cache_path]}/tcl#{node['tcl']['version']}/unix"

  code <<-EOH
    set -x
    exec >  /var/tmp/chef-tcl-compile.log
    exec 2> /var/tmp/chef-tcl-compile.log
    ./configure --prefix=#{node['tcl']['install_prefix']}/tcl \
      --exec-prefix=#{node['tcl']['install_prefix']}/tcl \
      --enable-threads \
      --enable-shared \
      #{is_64bit} \
    && make \
    && make install \
    && make install-private-headers
  EOH

  not_if { ::File.exists? "#{node['tcl']['install_prefix']}/tcl/bin/tclsh#{tcl_major_version}" }
end

link "/usr/bin/tclsh" do
  to "#{node['tcl']['install_prefix']}/tcl/bin/tclsh#{tcl_major_version}"
end

include_recipe "tcl::lib"
