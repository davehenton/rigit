module Rigit
  # Handles "rigging" (scaffolding) of new projects from template rigs.
  class Rig
    attr_reader :name

    # Returns the root path for all rigs. By default, it will be +~/.rigs+
    # unless the +RIG_HOME+ environment variable is set.
    def self.home
      ENV['RIG_HOME'] ||= File.expand_path('.rigs', Dir.home)
    end

    # Sets the +RIG_HOME+ environment variable, and the new root path for 
    # rigs.
    def self.home=(path)
      ENV['RIG_HOME'] = path
    end

    # Returns a new instance of Rig. The +name+ argument should be the name 
    # of an existing (installed) rig.
    def initialize(name)
      @name = name
    end

    # Builds the project from the template rig.
    def scaffold(arguments: {}, target_dir:'.', &block)
      scaffold_dir dir: "#{path}/base", arguments: arguments, 
        target_dir: target_dir, &block

      arguments.each do |key, value| 
        additive_dir = "#{path}/#{key}=#{value}"
        if Dir.exist? additive_dir
          scaffold_dir dir: additive_dir, arguments: arguments, 
            target_dir: target_dir, &block
        end
      end
    end

    # Returns the full path to the rig template.
    def path
      "#{Rig.home}/#{name}"
    end

    # Returns true if the rig path exists.
    def exist?
      Dir.exist? path
    end

    # Returns true if the rig has a +config.yml+ file. 
    def has_config?
      File.exist? config_file
    end

    # Returns the path to the +config.yml+ file of the rig.
    def config_file
      "#{path}/config.yml"
    end

    # Returns a +configatron+ instance.
    def config
      @config ||= Config.load(config_file)
    end

    # Returns metadata about the rig, including all of its config values.
    def info
      {
        name: name,
        path: path,
        config: (has_config? ? File.read(config_file) : '<empty>')
      }
    end

    private

    def scaffold_dir(dir:, arguments:, target_dir:)
      files = Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH) - %w[. ..]
      files.reject! { |file| File.directory? file }

      files.each do |file|
        target_file = (file % arguments).sub dir, target_dir

        next if block_given? and !yield target_file

        begin
          content = File.read(file) % arguments
        rescue ArgumentError => e
          raise TemplateError.new file, e.message
        end
        
        File.deep_write target_file, content
      end
    end
  end
end
