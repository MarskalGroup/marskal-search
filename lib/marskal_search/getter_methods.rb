class MarskalSearch

private
  def column_details(p_select_clause)
    @select_depot[:count_distinct] = ''
    @select_depot[:ready_for_sql] = ''
    @select_depot[:column_details] = []
    @select_columns = []
    if p_select_clause.is_a?(Array)
      l_smart_columns = p_select_clause.map{|c| c.split_select_column_alias}
    else
      l_smart_columns = p_select_clause.smart_comma_parse_to_array.map{|c| c.split_select_column_alias}
    end
    
    l_smart_columns.each do |l_attr_array|
      l_attr = l_attr_array[0].remove_begin_end_char(COLUMN_WRAPPER_CHAR)
      l_alias = l_attr_array[1].to_s.blank? ? nil : l_attr_array[1].remove_begin_end_char(COLUMN_WRAPPER_CHAR)
      l_col = @model.columns_hash[l_attr] rescue nil
      if l_col.nil?
        l_col = @model.columns_hash[l_alias] rescue nil
      end

      @select_depot[:ready_for_sql] += ', ' unless @select_depot[:ready_for_sql].blank?
      @select_depot[:ready_for_sql] += "#{l_attr}"
      @select_depot[:ready_for_sql] += " AS #{l_alias}" unless l_alias.to_s.blank?

      @select_depot[:count_distinct] += ', ' unless @select_depot[:count_distinct].blank?
      @select_depot[:count_distinct] += "IFNULL(#{l_attr}, '')"

      l_current_col = {
          name:       l_attr,
          ruby_type:  (l_col.nil?) ? :string : l_col.type,   #to_do, only include for MAX info
          sql_type:   (l_col.nil?) ? 'varchar' : l_col.type,
          type:       (l_col.nil?) ? :string : l_col.type,
      }
      l_current_col[:alias] = l_alias unless l_alias.blank?
      if l_col.nil?
        l_current_col[:heading]    = l_alias.to_s.blank? ? l_attr : l_alias
      else
        l_current_col[:length]     = l_col.limit||(l_col.precision.to_i + l_col.scale.to_i + 1)
        l_current_col[:precision]  = l_col.precision  unless l_col.precision.nil?
        l_current_col[:scale]      = l_col.scale unless l_col.scale.nil?
        l_current_col[:heading]    = l_col.name.split('_').map{|w|w.humanize}.join(' ') #TODO look for overrides from api call

        if l_col.type == :datetime   #TODO:check for time fields as well
          l_current_col[:length] = 25
          # l_current_col.except!(:precision, :scale)
        elsif l_col.type == :date
          l_current_col[:length] = 10
        else
          l_sql_length_definition = l_col.sql_type.match(/\(.*?\)/)  #ex: decimal(15,2)..this will return 15,2  or varchar(45) will return 45
          unless l_sql_length_definition.nil?                                                                       #ruby mishandles the size of some field types
            l_sql_length = l_sql_length_definition[0].gsub(/[\(\)]/,'').split(',')                                  #so to be cautious we will take the maximum value
            l_current_col[:precision] = [l_sql_length[0].to_i,l_current_col[:precision].to_i].max                                   #as determined by either ruby or the sql engine (such as mysql/mariadb)
            l_current_col[:scale] = [l_sql_length[1].to_i,l_current_col[:scale].to_i].max if l_sql_length.length > 1  #this line is in the case where there is a precision
            l_current_col[:length] = l_current_col[:precision].to_i  + l_current_col[:scale].to_i + (l_current_col[:scale].to_i > 0 ? 1 : 0) #add precision amnd scale together to get a proper length
          end
        end
      end
      @select_depot[:column_details] << l_current_col
      @select_columns << (l_current_col[:alias]||l_current_col[:name])
    end #end mart_columns
    return self
  end

  def columns_from_indexes(p_only_unique = false)
    l_columns = [@model.primary_key]
    @model.connection.indexes(@table_name).each do |l_index|
      if (p_only_unique && l_index.unique) || !p_only_unique
        l_columns |= l_index.columns.flatten
      end
    end
    l_columns
  end

  private :column_details, :columns_from_indexes


end