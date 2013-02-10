remote_file "Tcllib distribution, v. #{node['tcl']['tcllib_version']}" do
  path   "#{Chef::Config[:file_cache_path]}/tcllib-#{node['tcl']['tcllib_version']}.tar.gz"
  source "http://downloads.sourceforge.net/project/tcllib/tcllib/#{node['tcl']['tcllib_version']}/tcllib-#{node['tcl']['tcllib_version']}.tar.gz"

  not_if { ::File.exists? "#{Chef::Config[:file_cache_path]}/tcllib-#{node['tcl']['tcllib_version']}.tar.gz" }
end

execute "Unpack tcllib distribution" do
  cwd     Chef::Config[:file_cache_path]
  command "tar xzf #{Chef::Config[:file_cache_path]}/tcllib-#{node['tcl']['tcllib_version']}.tar.gz"
  
  not_if  { ::File.directory? "#{Chef::Config[:file_cache_path]}/tcllib-#{node['tcl']['version']}" }
end

bash "Compile tcllib" do
  cwd "#{Chef::Config[:file_cache_path]}/tcllib-#{node['tcl']['tcllib_version']}"

  code <<-EOH
    set -x
    exec >  /var/tmp/chef-tcllib-compile.log
    exec 2> /var/tmp/chef-tcllib-compile.log
    ./configure --prefix=#{node['tcl']['install_prefix']}/tcl
    make
    make install
  EOH

  not_if { ::File.directory? "#{node['tcl']['install_prefix']}/tcl/lib/tcllib#{node['tcl']['tcllib_version']}" }
end
