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
    task :copy_package, :roles => :app do
      run "mkdir -p #{asl_install_dir}/asl"
      delete_artifact = false
      version = fetch(:asl_version, "1.0.9")
      target_platform = fetch(:asl_target_platform, "Linux-x86_64")
      package = fetch(:asl_package, "ASL-#{version}-#{target_platform}.tar.gz")
      if not File.file?(package)
        run_locally "scp artifacts@artifacts:pro60/releases/#{package} #{package}"
        delete_artifact = true
      end
      top.upload(package, "#{asl_install_dir}", :via=> :scp)
      if delete_artifact
        run_locally "rm -rf #{package}"
      end
      run "tar -C '#{asl_install_dir}/asl' --exclude include --strip-components 1 -xzvf '#{asl_install_dir}/#{package}'"
      run "rm #{asl_install_dir}/#{package}"
      sudo "chown -R #{runner}:#{runner} #{deploy_to}"            
    end
  end
end

