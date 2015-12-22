class MarskalSearch

  NO_DEFAULT = -1

  #setter function the :search_text option
  def set_search_text(p_value)
    @q = @search_text = p_value.to_s  #assign shortcut at sane time
    return self
  end

  #setter function the :wrap_column option
  def set_wrap_column(p_value)
    @wrap_column =  options_validator(:wrap_column, p_value)
    return self
  end

  def process_select(options)
    if options.has_key?(:sv) && (options[:select_string]||options[:s]).nil?
      set_select_view(options[:sv])
    else
      set_select_string(options[:select_string]||options[:s])
    end
    self

  end

  def set_limit(p_val, p_override_max = false)
    p_val ||= MAX_LIMIT_WITHOUT_OVERRIDE
    if p_val.to_i < 1 || (p_val > MAX_LIMIT_WITHOUT_OVERRIDE && !p_override_max)
      raise ERRORS[:invalid_limit]
    end
    @limit = p_val
    set_page(@requested_page) unless @requested_page.nil?  #if we had a page variable, then lets recalculate based on limit change
    self
  end

  def set_offset(p_val)                     #set offset for sql query 1st record found would an offset of 0
    @offset = p_val.to_i < 0 ? 0 : p_val    #make sure value is at least 0
    @requested_page = nil                   #we will assume that the offset was set directly and not via a page calulation
    self
  end

  def set_page(p_page)                      #user will request to calculate @offset based on  page and a limit values
    p_page = 1 if p_page < 0                #minimum pages is 1
    set_offset((p_page * @limit) - @limit)  #calculate where the record offset would be bases on page and limits
    @requested_page = p_page                 #now lets store this for relcaulation as needed
    self
  end

  #options[:select_string] or options[:s]
  def set_select_string(p_select_clause)
    if @select_depot.nil?
      @select_depot = {
          original_param: p_select_clause,
          last_parse: nil,
          column_details: nil,
          count: nil,
          count_distinct: nil,
      }
    else
      if p_select_clause == FORCE_REPARSE_OF_LAST_SELECT    #are we forcing a reparse using the
        p_select_clause = @select_depot[:last_parse]
      elsif p_select_clause == @select_depot[:last_parse]  #nothing change we dont need to process again
        return self
      end
    end
    @select_depot[:last_parse] = p_select_clause  #now lets set before we parse

    #if empty set, lets get all the columns for now
    p_select_clause =  @model.column_names if (p_select_clause.is_a?(Array) && p_select_clause.empty?) || p_select_clause.to_s.blank?

    column_details(p_select_clause) # now we have eithe a column of fields or an sql string, lets get some details
    @select_depot[:count] = "*"
    # @select_depot[:count_distinct] = wrap_columns(@select_columns).sql_null_to_blank.to_string_no_brackets_or_quotes
    self
  end


  def set_select_view(p_pararm)
    set_select_string(select_view_to_columns(p_pararm))
  end

  #options[:sv]
  def select_view_to_columns(p_view_info)
    p_view_type = p_view_info[0..1] unless p_view_info.nil?           #get view type
    options_validator(:select_view, p_view_type)       #
    @sv = @select_view = p_view_info
    case p_view_type.to_sym
      when :xs
        l_columns = columns_from_indexes(true)
      when :sm
        l_columns = columns_from_indexes
      when :md
        l_columns = @model.content_columns.map{|c|c.name}.reject{|c|TIMESTAMP_FIELDS.include?(c)}
        l_columns.reject!{|c| (@model.columns_hash.has_key?(c) && @model.columns_hash[c].type == :text) }
      when :lg
        l_columns = @model.content_columns.map{|c|c.name}.reject{|c|TIMESTAMP_FIELDS.include?(c)}
      else
        l_columns = @model.column_names
    end
    l_view_settings = Utils.parse_plus_minus_param(p_view_info.sub('.add(', '+(').sub('.sub(', '-('), ERRORS[:invalid_select_view_format])
    l_columns |= l_view_settings[:plus].to_s.smart_comma_parse_to_array   unless l_view_settings[:plus].blank?
    l_columns -= l_view_settings[:minus].to_s.smart_comma_parse_to_array  unless l_view_settings[:minus].blank?
    l_columns
  end

  def set_distinct(p_value)
    @use_distinct = p_value
    self
  end


  #set one of the available predefined format listed in PREDEFINED_FORMATS
  #this will change @output_settings accordingly
  # p_format whould be one of the formats listed in PREDEFINED_FORMATS
  # ex: set_format(:marskal_api)
  def set_format(p_format)
    options_validator(:format, p_format)    #validate the format: setting

    @output_settings = {}                   #init variable
    l_defaults = [DEFAULT, MARSKAL_API]     #store default names in array
    VALID_OUTPUT_SETTINGS.each {|k,v| @output_settings[k]=v[:default]}  #lets reset to default first before we apply specific formats

    unless l_defaults.include?(p_format.to_sym)                       #dont do anything if we are simply resetting the defaults
      @output_settings.merge!(PREDEFINED_FORMATS[p_format.to_sym])    #otherwise merge the new options with the old one
    end

    self      #return marskal object (self) so this can be daisy-chained with other calls
  end

  #set one or more of the various output settings as defined by VALID_OUTPUT_SETTINGS
  # p_settings ==> one or more settings with values allowed by VALID_OUTPUT_SETTINGS
  # ex: set_output_settings(column_details : false, column_headings: true, column_names: true)
  def set_output_settings(p_settings)
    p_settings.assert_valid_keys(VALID_OUTPUT_SETTINGS.keys)      #make sure we have a valid setting
    p_settings.each do |k,l_value|                                #loop thru all the provided settings
      if l_value == DEFAULT                                       #if the value is set to default
        l_value = VALID_OUTPUT_SETTINGS[k][DEFAULT]               #then lets grab the default value
      else                                                        #else
        unless VALID_OUTPUT_SETTINGS[k][:valid].include?(l_value) #validate and generate error if needed
          raise "#{ERRORS[:invalid_output_setting]} for setting #{k}. Valid Options are #{VALID_OUTPUT_SETTINGS[k][:valid]}"
        end
      end
      @output_settings[k]= l_value    #everything good if we got here, so lets apply the setting
    end
    self  #return marskal object (self) so this can be daisy-chained with other calls
  end


  private
  #TODO: set private :method for each private method

   #used VALID_KEYS along with the field (key) to reset the value as allowed
  def options_validator(p_key, p_value)
    raise "#{p_key} not in VALID_KEYS" unless VALID_KEYS.has_key?(p_key)  #rails error if not defined in VALID_KEYS
    if p_value == :default                                                #if default, then use the defined default
      l_default_index = VALID_KEYS[p_key.to_sym][:default]                #get the pointer to the valid key default
      p_value = l_default_index == NO_DEFAULT ? nil : VALID_KEYS[p_key.to_sym][:valid][l_default_index] #set default or nil if no default is provided
    else
      symbol_to_hash(p_value||:nil_not_allowed).assert_valid_keys(VALID_KEYS[p_key.to_sym][:valid]) #now check if the key is valid
    end
    return p_value  #return the appropriate value
  end

  def symbol_to_hash(p_symbol)
    return p_symbol if p_symbol.is_a?(Hash)
    l_hash = {}
    l_hash[p_symbol.to_sym] = nil
    l_hash
  end
  private :options_validator, :symbol_to_hash


end
