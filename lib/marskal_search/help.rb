class MarskalSearch

#NOTE LEft off handling "\n" characters

  def help(p_key = nil)
    MarskalSearch::Help.commands(p_key)
  end

  class Help
    @@help_content = nil


    def self.load_content
      l_erb_file = ERB.new(File.read("#{Gem.loaded_specs['marskal-search'].full_gem_path}/config/locales/marskal_search.help.en.yml"))
      @@help_content = YAML.load(l_erb_file.result(binding)).deep_symbolize_keys()
    end

    def self.commands(p_key = nil)
      return "General Instructions Coming Soon" if p_key.nil?
      load_content() if @@help_content.nil? || true

      p_key = p_key.to_sym

      l_output = build_help_string(p_key)
      puts l_output

      return
    end

    def self.default_synopsis(p_key)
      l_text = ''
      VALID_KEYS[p_key][:valid].each do |l_key|
        l_text += "[ :#{l_key} ] "
      end
      l_text
    end


    private

    def self.format_for_terminal(p_block_text, p_tabs = "\t\t")
      l_text = p_block_text.to_s.split(/\s!\n!\t/).join(' ')
      l_text.gsub!("\\n", "\n")

      p_tabs = p_tabs.gsub("\t", '  ')
      l_max_length = 79 -p_tabs.length

      l_formatted_str = ''
      until l_text.blank? do
        l_char_to_add = "\n"  #default to add a new line char
        l_line = l_text.gsub("\t", '  ')[0..l_max_length]  #adjust for tabs, which we will later replace for spaces

        #these lines discover the space in the line, last newline in the line or the need of the string. Ir will use
        #what ever the minimum value is as long as it is not nil
        l_last_space = l_line.rindex(' ')
        l_first_newline = l_line.index("\n")
        unless l_first_newline.nil? #use new line if we found 1
          l_last_space  = l_first_newline
          l_char_to_add = ''  #we already have our new line, so we don't need 2
        else
          l_last_space = l_line.length if l_last_space.nil? || l_text.length <= l_max_length #chedk if we are on last line
        end



        l_new_str = l_text.slice!(0, l_last_space+1)
        l_formatted_str += "#{p_tabs}#{l_new_str}#{l_char_to_add}"
      end
      zz = l_formatted_str.gsub("\\t", '  ')
      zz
    end

    def self.build_help_string(p_key_symbol)
      p_content = @@help_content[p_key_symbol]
      p_key = p_content[:name]
      <<-OUTSTR

NAME:

    #{p_key} - #{p_content[:tip]}

SYNOPSIS:

    #{p_key} - #{p_content[:synopsis]}

    Getting Value:
      <marskal_object>.#{p_content[:getter]}

    Setting Value:
      <marskal_object>.set_#{p_content[:setter]}

DESCRIPTION:

#{format_for_terminal(p_content[:description])}

EXAMPLES:

#{format_for_terminal(p_content[:example])}


--------------------- END Help #{p_key} ---------------------

      OUTSTR

    end
#
# HELP = { }
#
# HELP[:wrap_column] = {}
# HELP[:wrap_column][:synopsis] = <<-EOS
#     EOS
#
# HELP[:wrap_column][:description] = <<-EOS
#     It is a long established fact that a reader will be distracted by the readable content of a page when looking at its
#     layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to
#     using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web
#     page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web
#     sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on
#     purpose (injected humour and the like).
#     EOS
#
  end #help

end #marskalsearch

