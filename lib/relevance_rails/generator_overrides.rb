module RelevanceRails
  module GeneratorOverrides
    def git(commands={})
      super
      if !$?.success?
        command_string = commands.is_a?(Symbol) ? "git #{commands}" :
          commands.map {|cmd, options| "git #{cmd} #{options}" }.join("; ")
        msg = "Generator failed with command(s): #{command_string}"
        abort "\n#{'*' * msg.size}\n#{msg}\n#{'*' * msg.size}"
      end
    end
  end
end
