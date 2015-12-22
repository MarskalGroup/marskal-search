class MarskalSearch

  class Utils

    #this display a list of models that were created by the MarskalSearch. If these collect in memory, it may be a good idea
    #to restart rails or the web server every now and then
    def self.view_marskal_created_models
      ActiveRecord::Base.subclasses.keep_if{|c| c.name.starts_with?(COLUMN_MODEL_STARTER) }.map{|c|c.name}
    end

    #i dont know if this cleans up memory, but its here for testing purposes
    #what it will do is remove the classs name itself from the ruby objects list
    def self.remove_marskal_created_models
      l_objects = view_marskal_created_models                       #get all marskal_created models
      l_objects_removed = 0                                         #count how many we actually remove
      l_objects.each do |konstant|                                  #loop thru all perceived subclasses
        if (ActiveSupport::Dependencies.const_get(konstant) rescue nil) #see if they are still objects
          l_objects_removed += 1                                  #if so, then count them
          ActiveSupport::Dependencies.remove_constant(konstant)   #and remove them
        end
      end
      "#{l_objects.length} subclasses expected, #{l_objects_removed} found and removed" #return the number expected/deleted
    end


    #this creates a new model
    # TODO : Enhance to allow new relationships to be built on the fly
    # TODO : make primary ke dynamic in future
    def self.build_a_new_model(p_model_name, p_table_name, p_connection = '')
      Class.new(ActiveRecord::Base).tap do |klass|              #build a new model
        Object.const_set(p_model_name, klass)                   #set the name of the model in the constants
        klass.primary_key = :id                                 #for now hard code the id field
        klass.table_name = p_table_name                         #set the table name
        klass.establish_connection(p_connection.to_sym) unless p_connection.to_s.blank? #set connection if available
        # add_methods
      end
    end

    #this function will set the @model instance varaible for this instance.
    #it first check for a valid option[:model_name]
    #if missing or invalid then it next checks options[:create_model] for values
    #options[:create_model] can be a string or an array
    #ex:
    # options[:create_model] = 'my_table_name'
    # options[:create_model] = ['my_table_name']                    #when no connection is provided, it will use the default of the application
    # options[:create_model] = ['my_table_name', 'my_connection']   #Notes: for now we requre the connection be defined, this is usally done via database.yml file
    def self.find_or_build_model(p_model_id, options)

      l_new_class=nil   #init our new class
      begin
        if options.has_key?(:model)                                                                         #see if the passed us a model name
          l_new_class = options[:model].is_a?(String) ? (eval options[:model].classify) : options[:model]   #if string convert to a class
        end
      rescue
        nil #some error occurred, continue to next step
      end

      if l_new_class.nil? && options.has_key?(:create_model)                      #if class was not created && they gave us connection info
        l_table_options = options[:create_model]                                  #lets parse the options so we can create a new model
        if !(l_table_options.is_a?(String)  || l_table_options.is_a?(Array)) ||   #first validate if the option is in correct format
            (l_table_options.is_a?(Array) &&
                (l_table_options.length > 2 || l_table_options.empty?) || !l_table_options[0].is_a?(String))
          raise ERRORS[:invalid_format_create_model]                               #raise error if a problem was found
        end
        l_connection = ''                               #set default to nothing. This means the default will be the app default
        if l_table_options.is_a?(String)                #extract table_name and connection based on data types
          l_table = l_table_options
        else
          l_table = l_table_options[0]
          l_connection = l_table_options[1] if l_table_options.length > 1
        end
        # l_new_class = create_dynamic_model(l_table, l_connection)    #lets get our new class
        l_new_class = build_a_new_model(construct_unique_model_name(l_table, l_connection, p_model_id), l_table, l_connection)    #lets get our new class
        raise "#{ERRORS[:no_table]}: table:[#{l_table}] db:[#{l_new_class.connection.current_database}]" unless l_new_class && l_new_class.table_exists?
      end

      raise "#{options[:model]} #{ERRORS[:need_model]}" if l_new_class.nil? #error out if we dont have a model yet, we are out of things to try

      l_new_class #return the class

    end

    def self.construct_unique_model_name(p_table, p_connection, p_model_id)
      "#{COLUMN_MODEL_STARTER.downcase}_#{p_connection.singularize}_#{p_table.singularize}#{p_model_id}".classify
    end

    #parses a parameter such as this
    #ex: xl+(name)-(id)  => returns a hash with elements { token: plus: minus: }
    #    xl+(last_name, first_name)-(salary+commission)  => returns { token: 'xl', plus: 'last_name, first_name', minus: 'salary+commission' }
    def self.parse_plus_minus_param(p_param, p_error_code = nil)

      l_valid_chars = %w(+ -)

      l_parsed =  { token: p_param.split(/[\+\-]/).first, plus: nil, minus: nil }

      l_regx = Regexp.new("(\\(.*?\\))")   #ignore + and - between open and close parenthesis ()
      l_temp = p_param.clone.sub(l_parsed[:token],'')  #remove this first element
      while !l_temp.blank?

        unless l_valid_chars.include?(l_temp[0])
          raise p_error_code unless p_error_code.nil?
          return nil
        end

        l_parse_array_index = l_temp.slice!(0) ==  '+' ? :plus : :minus
        if l_temp[0] != '('
          raise p_error_code unless p_error_code.nil?
          return nil
        end

        l_param_value = l_temp.match(l_regx)
        unless l_param_value.nil?
          l_param_value = l_param_value[0]
          l_temp.slice!(0..(l_param_value.length-1))
          l_parsed[l_parse_array_index] = l_param_value[1..(l_param_value.length-2)] #remove parenthesis
        end

      end

      l_parsed #return parse array

    end

    def self.format_alias_name(p_alias)
        p_alias.to_s.remove_begin_end_char(COLUMN_WRAPPER_CHAR).unquote.gsub(' ', '_').downcase
    end




  end #utils

end #marskalsearch

