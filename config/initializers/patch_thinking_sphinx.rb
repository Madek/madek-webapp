
module Kernel
  alias_method :my_cock, :require

  def require(f)
    puts "required #{f} in #{caller.last.inspect}"
    return my_cock(f)
  end
end

# Originally in gem "thinking_sphinx"
# lib/thinking_sphinx/test.rb
class ThinkingSphinx::Test
  
    def self.start_without_config_file_generation
              puts "alala lala long start without"

      #config.build  # This completely destroys any more advanced
                    # Sphinx configuration file, such as ours that
                    # uses xmlpipe. So let's not do that!
      config.controller.index
      config.controller.start
    end

    def self.start_without_config_file_but_with_autostop
              puts "alala lala long autostop"

      autostop
      start_without_config_file_generation
    end
   
end
