# Required base libraries
require 'artcom/capistrano-y60'
require 'railsless-deploy'

# Bootstrap Capistrano instance
configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  # --------------------------------------------
  # Task hooks
  # --------------------------------------------
  after "deploy:setup", "asl:setup_directory_structure"
  after "deploy:setup", "asl:update_ldconfig"
  after "deploy:setup", "asl:update_environment"

  # --------------------------------------------
  # watchdog specific tasks
  # --------------------------------------------
  namespace :asl do

    desc "setup directory structure"
    task :setup_directory_structure, :roles => :app do
      run "mkdir -p #{asl_install_dir}/asl"
    end

    desc "Add asl/lib to ldconfig"
    task :update_ldconfig, :roles => :app do
      run "echo '#{asl_install_dir}/asl/lib' | #{sudo} tee /etc/ld.so.conf.d/asl.conf", :pty => true
      run "#{sudo} /sbin/ldconfig", :pty => true
    end

    desc "Setup environment variable asl 'ASL_DIR'"
    task :update_environment, :roles => :app do
      next if find_servers_for_task(current_task).empty?
      run "echo 'export ASL_DIR=#{asl_install_dir}/asl/bin' | #{sudo} tee /etc/profile.d/asl.sh", :pty => true
    end

    # --------------------------------------------
    # deployment
    # --------------------------------------------

    desc "Copy asl"
    task :copy_lib, :roles => :app do
      top.upload("asl.tar.gz", "#{asl_install_dir}", :via=> :scp)
      run "tar -C '#{asl_install_dir}' -xzvf '#{asl_install_dir}/asl.tar.gz'"
    end
  end
end

