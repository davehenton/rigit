module Rigit
  class Rig
    attr_reader :name

    def self.home
      ENV['RIG_HOME'] ||= File.expand_path('.rigs', Dir.home)
    end

    def self.home=(path)
      ENV['RIG_HOME'] = path
    end

    def initialize(name)
      @name = name
    end

    def scaffold(arguments: {}, target_dir:'.')
      scaffold_dir "#{path}/base", arguments, target_dir

      arguments.each do |key, value| 
        additive_dir = "#{path}/#{key}=#{value}"
        if Dir.exist? additive_dir
          scaffold_dir additive_dir, arguments, target_dir
        end
      end
    end

    def path
      "#{Rig.home}/#{name}"
    end

    def exist?
      Dir.exist? path
    end

    def config_file
      "#{path}/config.yml"
    end

    def config
      @config ||= Config.load(config_file)
    end

    private

    def scaffold_dir(dir, arguments, target_dir)
      files = Dir["#{dir}/**/*"].reject { |file| File.directory? file }

      files.each do |file|
        target_file = (file % arguments).sub dir, target_dir
        content = File.read(file) % arguments
        File.deep_write target_file, content
      end
    end
  end
end
