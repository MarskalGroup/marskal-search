class MarskalSearch

  def column_details
    l_columns = []
    rec = active_record_relation.first  #TODO: clean this up to be more efficient maybe save last select statement
    rec.attributes.each do |l_attr_array|
      puts l_attr_array[0]
      l_attr = l_attr_array[0]
      l_col = active_record_relation.columns_hash[l_attr]
      l_columns << {
          name:       l_attr,
          heading:    l_attr.split('_').map{|w|w.humanize}.join(' '), #TODO look for overrides from api call
          ruby_type:  (l_col.nil?) ? :string : l_col.type,   #to_do, only include for MAX info
          sql_type:   (l_col.nil?) ? 'varchar' : l_col.type,
          type:       (l_col.nil?) ? :string : l_col.type,
          length:     (l_col.nil?) ? nil : l_col.limit||(l_col.precision.to_i + l_col.scale.to_i + 1),
          precision:  (l_col.nil?) ? nil : l_col.precision,
          scale:      (l_col.nil?) ? nil : l_col.scale
      }
      unless l_col.nil?
        if l_col.type == :datetime   #TODO:check for time fields as well
          l_columns.last[:length] = 25
          l_columns.last.except!(:precision, :scale)
        elsif l_col.type == :date
          l_columns.last[:length] = 10
        else
          l_sql_length_definition = l_col.sql_type.match(/\(.*?\)/)  #ex: decimal(15,2)..this will return 15,2  or varchar(45) will return 45
          unless l_sql_length_definition.nil?                                                                       #ruby mishandles the size of some field types
            l_sql_length = l_sql_length_definition[0].gsub(/[\(\)]/,'').split(',')                                  #so to be cautious we will take the maximum value
            l_columns.last[:precision] = [l_sql_length[0].to_i,l_columns.last[:precision].to_i].max                                   #as determined by either ruby or the sql engine (such as mysql/mariadb)
            l_columns.last[:scale] = [l_sql_length[1].to_i,l_columns.last[:scale].to_i].max if l_sql_length.length > 1  #this line is in the case where there is a precision
            l_columns.last[:length] = l_columns.last[:precision].to_i  + l_columns.last[:scale].to_i + (l_columns.last[:scale].to_i > 0 ? 1 : 0) #add precision amnd scale together to get a proper length
          end
        end
      end
    end
    l_columns

  end

end