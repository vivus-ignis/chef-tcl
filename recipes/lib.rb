remote_file "#{Chef::Config[:file_cache_path]}/tcllib-#{node['tcl']['tcllib_version']}.tar.gz)" do
  source "http://downloads.sourceforge.net/project/tcllib/tcllib/#{node['tcl']['tcllib_version']}/tcllib-#{node['tcl']['tcllib_version']}.tar.gz"

  not_if { ::File.exists? "#{Chef::Config[:file_cache_path]}/tcllib-#{node['tcl']['tcllib_version']}.tar.gz" }
end

execute "tar xzf #{Chef::Config[:file_cache_path]}/tcllib-#{node['tcl']['tcllib_version']}.tar.gz" do
  
  not_if { ::File.directory? "#{Chef::Config[:file_cache_path]}/tcllib-#{node['tcl']['version']}" }
end

bash "Compile TCLLIB" do
  cwd "#{Chef::Config[:file_cache_path]}/tcllib-#{node['tcl']['tcllib_version']}"

  code<<-EOH
    set -x
    exec >  /var/tmp/chef-tcllib-compile.log
    exec 2> /var/tmp/chef-tcllib-compile.log
    ./configure --prefix=#{node['tcl']['install_prefix']}/tcl
    make
    make install
  EOH
end
