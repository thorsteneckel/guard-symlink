require 'guard/compat/plugin'
require 'guard/symlink/version'
require 'guard/symlink/bugfix'
require 'guard/symlink/pry'

module Guard
  class Symlink < Guard::Plugin
    def initialize(options = {})
      opts    = options.dup
      @ignore = opts.delete(:ignore)
      super(opts)
    end

    # Called once when Guard starts. Please override initialize method to init stuff.
    #
    # @raise [:task_has_failed] when start has failed
    # @return [Object] the task result
    #
    def start
      watchdirs.each do |directory|
        files = package_files(directory)
        link(files)
      end
    end

    # Called on file(s) additions that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_additions has failed
    # @return [Object] the task result
    #
    def run_on_additions(paths)
      link(paths)
    end

    # Called on file(s) removals that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_removals has failed
    # @return [Object] the task result
    #
    def run_on_removals(paths)
      unlink(paths)
    end

    def unlink_all
      watchdirs.each do |directory|
        files = package_files(directory)
        unlink(files)
      end
    end

    def link(paths)
      paths.each do |entry|
        source_path       = ::File.expand_path(entry)
        relative_sub_path = relative_sub_path(source_path)

        next if @ignore.include?(relative_sub_path)

        target_path       = "#{::Dir.pwd}/#{relative_sub_path}"
        target_directory  = ::File.dirname(target_path)
        ensure_directory(target_directory)

        next if link_exists?(source_path, target_path)
        backup(target_path)

        create_symlink(source_path, target_path)
      end
    end

    def unlink(paths)
      target_folders = []
      paths.each do |entry|
        source_path       = ::File.expand_path(entry)
        relative_sub_path = relative_sub_path(source_path)
        target_path       = "#{::Dir.pwd}/#{relative_sub_path}"

        next unless link_exists?(source_path, target_path)
        next unless file_removed?(target_path)

        target_directory = ::File.dirname(target_path)
        next if target_folders.include?(target_directory)
        target_folders.push(target_directory)
      end

      remove_empty(target_folders)
    end

    private

    def remove_empty(directories)
      return if directories.empty?

      parent_directories = []
      directories.uniq.each do |directory|
        next unless ::File.directory?(directory)
        next unless directory_empty?(directory)
        ::Dir.rmdir(directory)
        ::Guard::Compat::UI.info "Removed empty directory #{directory}"

        parent_directory = ::File.dirname(directory)

        next if parent_directories.include?(parent_directory)
        parent_directories.push(parent_directory)
      end
      remove_empty(parent_directories)
    end

    def file_removed?(path)
      return true if backup_restored?(path)
      ::File.delete(path)
      # p caller
      ::Guard::Compat::UI.info "Removed link #{path}"
      true
    end

    def package_files(directory)
      ::Dir.glob(directory + '/**/*').reject { |fn| ::File.directory?(fn) }
    end

    def relative_sub_path(path_org)
      path = path_org.dup
      watchdirs.each do |directory|
        directory += '/'
        next unless path.start_with?(directory)
        path.slice!(directory)
        break
      end
      path
    end

    def directory_empty?(directory)
      (::Dir.entries(directory) - %w(. ..)).empty?
    end

    def ensure_directory(dir)
      return if ::File.directory?(dir)
      ::FileUtils.mkdir_p(dir)
    end

    def create_symlink(source, target)
      if link_exists?(source, target)
        ::File.delete(target)
        return false
      end
      ::File.symlink(source, target)
      ::Guard::Compat::UI.info "Created symlink #{source} -> #{target}"
    end

    def link_exists?(source, target)
      return false unless ::File.symlink?(target)
      ::File.readlink(target) == source
    end

    def backup(path)
      return unless ::File.file?(path)

      backup_file = backup_name(path)

      if ::File.exist?(backup_file)
        raise "Can't link #{path}, destination and #{backup_suffix} already exist!"
      end

      ::File.rename(path, backup_file)
      ::Guard::Compat::UI.info "Created backup #{path} -> #{backup_file}"
    end

    def backup_restored?(path)
      backup_file = backup_name(path)
      return false unless ::File.exist?(backup_file)
      ::File.delete(path)
      ::File.rename(backup_file, path)
      ::Guard::Compat::UI.info "Removed link by restoring backup #{backup_file} -> #{path}"
      true
    end

    def backup_name(path)
      "#{path}#{backup_suffix}"
    end

    def backup_suffix
      '.link_backup'
    end

    def watchdirs
      @watchdirs ||= ::Guard.state.session.watchdirs
    end
  end
end
