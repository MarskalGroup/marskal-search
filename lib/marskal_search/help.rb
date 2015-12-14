class MarskalSearch

  def self.help(p_key = nil)
    MarskalSearch::Help.commands(p_key)
  end

  def help(p_key = nil)
    MarskalSearch::Help.commands(p_key)
  end

  class Help
    @@help_content = nil


    def self.load_content
      puts "Loading HelpContent File--->"
      gem_root = Gem.loaded_specs['marskal-search'].full_gem_path
      f = "#{gem_root}/config/locales/marskal_search.help.en.yml"
      t = ERB.new(File.read(f))
      @@help_content = YAML.load(t.result(binding).to_s).deep_symbolize_keys()
    end

    def self.commands(p_key = nil)
      return "General Instructions Coming Soon" if p_key.nil?
      load_content() if @@help_content.nil?

      p_key = p_key.to_sym

      l_output = build_help_string(p_key)
      puts l_output

      return
    end

    private
    def self.key_help(p_key)
      l_text = ''
      VALID_KEYS[p_key][:valid].each do |l_key|
        l_text += "[#{l_key}]"
      end
      l_text
    end

    def self.format_for_terminal(p_block_text, p_tabs = "\t\t")
      l_text = p_block_text.gsub("\n", ' ').split.join(' ')
      p_tabs = p_tabs.gsub("\t", '  ')

      l_formatted_str = ''
      until l_text.blank? do
        l_last_space = l_text[0..(79-p_tabs.length)].rindex(' ')
        l_last_space =l_text.length if l_last_space.nil?
        l_new_str = l_text.slice!(0, l_last_space+1).strip!
        l_formatted_str += "#{p_tabs}#{l_new_str}\n"
      end
      l_formatted_str
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

