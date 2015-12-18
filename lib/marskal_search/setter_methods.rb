class MarskalSearch

  NO_DEFAULT = -1

  # #setter function the :wrap_column option
  # def set_select_columns(p_value)
  #
  #   @wrap_column =  options_validator(:wrap_column, p_value)
  #   return self
  # end

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

  def set_distinct(p_value)
    @use_distinct = p_value
    self
  end

 private
  #TODO: set private :method for each private method

   #used VALID_KEYS along with the filed (key) to reset the value as allowed
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

  #this function will set the @model instance varaible for this instance.
  #it first check for a valid option[:model_name]
  #if missing or invalid then it next checks options[:create_model] for values
  #options[:create_model] can be a string or an array
  #ex:
  # options[:create_model] = 'my_table_name'
  # options[:create_model] = ['my_table_name']                    #when no connection is provided, it will use the default of the application
  # options[:create_model] = ['my_table_name', 'my_connection']   #Notes: for now we requre the connection be defined, this is usally done via database.yml file
#   def find_or_build_model(options)
#
#     l_new_class=nil   #init our new class
#     begin
#       if options.has_key?(:model)                                                                         #see if the passed us a model name
#         l_new_class = options[:model].is_a?(String) ? (eval options[:model].classify) : options[:model]   #if string convert to a class
#       end
#     rescue
#       nil #some error occurred, continue to next step
#     end
#
#     if l_new_class.nil? && options.has_key?(:create_model)                      #if class was not created && they gave us connection info
#       l_table_options = options[:create_model]                                  #lets parse the options so we can create a new model
#       if !(l_table_options.is_a?(String)  || l_table_options.is_a?(Array)) ||   #first validate if the option is in correct format
#           (l_table_options.is_a?(Array) &&
#               (l_table_options.length > 2 || l_table_options.empty?) || !l_table_options[0].is_a?(String))
#         raise ERRORS[:invalid_format_create_model]                               #raise error if a problem was found
#       end
#       l_connection = ''                               #set default to nothing. This means the default will be the app default
#       if l_table_options.is_a?(String)                #extract table_name and connection based on data types
#         l_table = l_table_options
#       else
#         l_table = l_table_options[0]
#         l_connection = l_table_options[1] if l_table_options.length > 1
#       end
#       l_new_class = create_dynamic_model(l_table, l_connection)    #lets get our new class
#     end
#
#     raise "#{options[:model]} #{ERRORS[:need_model]}" if l_new_class.nil? #error out if we dont have a model yet, we are out of things to try
#
#     l_new_class #return the class
#
#   end
#
#   #TODO: find better way to create a dynamic model, this may cause crashing with two people hitting the table at the same time
#   def create_dynamic_model(p_table, p_connection)                   #create a model in memory if not exists
#     l_model = "#{p_connection.singularize}_#{p_table}".classify     #make a legit class name
#     l_connection = p_connection.to_s.blank? ? '' : "establish_connection :#{p_connection}"
#     begin
#       eval <<DYNAMIC                                                #if the model does not exist, then lets create it on the fly
#       class #{l_model} < ActiveRecord::Base
#         #{l_connection}
#         self.table_name = '#{p_table}'
#       end
# DYNAMIC
#
#       l_new_model = eval l_model     #ok lets store are model in a variable
#       raise '' unless l_new_model.table_exists?
#     rescue
#       raise "#{ERRORS[:unable_to_create_model]}: #{p_table} in connection #{p_connection}"  #display error if the requested table does not exists
#     end
#     return l_new_model                                                                   #return the requested model
#   end
#
#

end
