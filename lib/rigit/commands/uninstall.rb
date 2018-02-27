module Rigit::Commands
  # The {Uninstall} module provides the {#uninstall} command for the 
  # {CommandLine} module.
  module Uninstall
    # The command line +uninstall+ command.
    def uninstall
      UninstallHandler.new(args).execute
    end

    # Internal class to handle rig removal for the {CommandLine} class.
    class UninstallHandler
      include Colsole

      attr_reader :args, :rig_name

      def initialize(args)
        @args = args
        @rig_name = args['RIG']
      end

      def execute
        verify_dirs
        uninstall
      end

      private

      def uninstall
        say "This will remove !txtgrn!#{rig_name}!txtrst! and delete\n#{target_path}"
        continue = tty_prompt.yes? "Continue?", default: false
        uninstall! if continue
      end

      def uninstall!
        say "Uninstalling !txtgrn!#{rig_name}"
        success = FileUtils.rm_rf target_path

        if success
          say "Rig uninstalled !txtgrn!successfully"
        else
          # :nocov:
          say "!txtred!Uninstall failed"
          # :nocov:
        end
      end

      def rig
        @rig ||= Rigit::Rig.new rig_name
      end

      def target_path
        @target_path ||= rig.path
      end

      def tty_prompt
        @tty_prompt ||= TTY::Prompt.new
      end

      def verify_dirs
        if !rig.exist?
          say "Rig !txtgrn!#{rig_name}!txtrst! is not installed"
          raise Rigit::Exit
        end
      end
    end
  end
end
