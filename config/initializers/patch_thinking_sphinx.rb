# Originally in gem "thinking_sphinx"
# lib/thinking_sphinx/test.rb
class ThinkingSphinx::Test
  
    def self.start_without_config_file_generation
      #config.build  # This completely destroys any more advanced
                    # Sphinx configuration file, such as ours that
                    # uses xmlpipe. So let's not do that!
      config.controller.index
      config.controller.start
    end

    def self.start_without_config_file_but_with_autostop
      autostop
      start_without_config_file_generation
    end
   
end







