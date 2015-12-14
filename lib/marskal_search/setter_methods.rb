class MarskalSearch

  NO_DEFAULT = -1

  def self.mytest
    gem_root = Gem.loaded_specs['marskal-search'].full_gem_path
    f = "#{gem_root}/config/locales/marskal_search.help.en.yml"
    t = ERB.new(File.read(f))
    c = YAML.load(t.result(binding).to_s)
    c
  end

  # #setter function the :wrap_column option
  # def set_select_columns(p_value)
  #
  #   @wrap_column =  options_validator(:wrap_column, p_value)
  #   return self
  # end

  #setter function the :wrap_column option
  def set_wrap_column(p_value)
    @wrap_column =  options_validator(:wrap_column, p_value)
    return self
  end

 private
   #used VALID_KEYS along with the filed (key) to reset the value as allowed
  def options_validator(p_key, p_value)
    raise "#{p_key} not in VALID_KEYS" unless VALID_KEYS.has_key?(p_key)  #rails error if not defined in VALID_KEYS
    if p_value == :default                                                #if default, then use the defined default
      l_default_index = VALID_KEYS[p_key.to_sym][:default]                #get the pointer to the valid key default
      p_value = l_default_index == NO_DEFAULT ? nil : VALID_KEYS[p_key.to_sym][:valid][l_default_index] #set default or nil if no default is provided
    else
      symbol_to_hash(p_value||:nil_not_allowed).assert_valid_keys(VALID_KEYS[p_key.to_sym][:valid]) #no check if the key is valid
    end
    return p_value  #return the appropriate value
  end

end
