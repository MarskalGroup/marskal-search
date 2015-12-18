class MarskalSearch



private
  def column_details(p_select_clause)
    @select_depot[:count_distinct] = ''
    @select_depot[:ready_for_sql] = ''
    @select_depot[:column_details] = []
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

      @select_depot[:column_details] << {
          name:       l_attr,
          ruby_type:  (l_col.nil?) ? :string : l_col.type,   #to_do, only include for MAX info
          sql_type:   (l_col.nil?) ? 'varchar' : l_col.type,
          type:       (l_col.nil?) ? :string : l_col.type,
      }
      @select_depot[:column_details].last[:alias] = l_alias unless l_alias.blank?
      if l_col.nil?
        @select_depot[:column_details].last[:heading]    = l_alias.to_s.blank? ? l_attr : l_alias
      else
        @select_depot[:column_details].last[:length]     = l_col.limit||(l_col.precision.to_i + l_col.scale.to_i + 1)
        @select_depot[:column_details].last[:precision]  = l_col.precision  unless l_col.precision.nil?
        @select_depot[:column_details].last[:scale]      = l_col.scale unless l_col.scale.nil?
        @select_depot[:column_details].last[:heading]    = l_col.name.split('_').map{|w|w.humanize}.join(' ') #TODO look for overrides from api call

        if l_col.type == :datetime   #TODO:check for time fields as well
          @select_depot[:column_details].last[:length] = 25
          # @select_depot[:column_details].last.except!(:precision, :scale)
        elsif l_col.type == :date
          @select_depot[:column_details].last[:length] = 10
        else
          l_sql_length_definition = l_col.sql_type.match(/\(.*?\)/)  #ex: decimal(15,2)..this will return 15,2  or varchar(45) will return 45
          unless l_sql_length_definition.nil?                                                                       #ruby mishandles the size of some field types
            l_sql_length = l_sql_length_definition[0].gsub(/[\(\)]/,'').split(',')                                  #so to be cautious we will take the maximum value
            @select_depot[:column_details].last[:precision] = [l_sql_length[0].to_i,@select_depot[:column_details].last[:precision].to_i].max                                   #as determined by either ruby or the sql engine (such as mysql/mariadb)
            @select_depot[:column_details].last[:scale] = [l_sql_length[1].to_i,@select_depot[:column_details].last[:scale].to_i].max if l_sql_length.length > 1  #this line is in the case where there is a precision
            @select_depot[:column_details].last[:length] = @select_depot[:column_details].last[:precision].to_i  + @select_depot[:column_details].last[:scale].to_i + (@select_depot[:column_details].last[:scale].to_i > 0 ? 1 : 0) #add precision amnd scale together to get a proper length
          end
        end
      end
    end
    return self
  end
  private :column_details


end