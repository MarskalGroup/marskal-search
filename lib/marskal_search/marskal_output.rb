class MarskalSearch

  #display the resulting sql (does not execute the query)
  def to_sql
    active_record_relation.to_sql
  end

  #count completed unfiltered, no where_string, no search_text
  #IMPORTANT_NOTE: The default scope will NEVER be excluded for counting purposes. It is essentially a fixed part of the query
  #this is useful, when the entire set is actually just a subset of the overall data set
  #for example:  a database may have 1000's of contacts, but any particular user will only be allowed access to a subset of that data
  #in this case the default_scope would be something like "user_id = 100"
  def count_all
    active_record_relation(exclude_order: true, exclude_search_text: true, exclude_where_string: true, exclude_offset_and_limit: true, prepare_select_for_count: true).count
  end

  #count partially filtered, apply where_string, do not apply search_text
  def count_without_search_text
    active_record_relation(exclude_order: true, exclude_search_text: true, exclude_offset_and_limit: true, prepare_select_for_count: true).count
  end

  #count the result sets with all filters applied
  def count
    active_record_relation(exclude_order: true, exclude_offset_and_limit: true, prepare_select_for_count: true).count
  end

  #do an active record 'pluck'
  def pluck
    #OLD CODE @select_columns.empty? ? active_record_relation.pluck : active_record_relation.pluck(select_string)
    active_record_relation.pluck(@select_depot[:ready_for_sql])
  end

  #do an active record 'pluck'
  def pluck_with_names
    #OLDl_records = select_string.blank? ? active_record_relation.pluck : active_record_relation.pluck(select_string)
    l_records = active_record_relation.pluck(@select_depot[:ready_for_sql])
    l_data = []
    l_records.each do |l_record|
      l_hash = {}
      @select_depot[:column_details].each_with_index do |l_column, index|
        l_name = l_column[:alias].blank? ? l_column[:name] : l_column[:alias]
        l_hash[l_name]  = l_record.is_a?(Array) ? l_record[index] : l_record #if only one field, an Array is not returned, just the string
      end
      l_data << l_hash
    end
    l_data
  end


  #this will apply all @output_settings and output the desired results
  #p_overrides will allow format: and all VALID_OUTPUT_SETTINGS to be overriden temporrarily
  def results(p_overrides = {})
    l_hold_current_settings = @output_settings.clone    #store current values of @output_settings
    if p_overrides.has_key?(:format)                    #if they passed a predefined format, then
        set_format(p_overrides[:format])                #apply that first
        p_overrides.delete(:format)                     #and remove from the hash
    end

    set_output_settings(p_overrides)                    #now lets override @output_settings with the settings provided by the caller

    l_results = {}                                      #intialize the results hash
    l_results.merge!(count_and_page_vars)                                                                     #now get page vars, send length of data
    l_results.merge!( column_details: @select_depot[:column_details]) if @output_settings[:column_details]    #get column details if requested
    l_results.merge!( column_headings: column_headings)               if @output_settings[:column_headings]   #get column headings if requested
    l_results.merge!( column_names: column_names)                     if @output_settings[:column_names]      #get column names if requested
    l_results.merge!( pass_back: @pass_back)                          unless @pass_back.nil?                  #attach user provided pass_back variables if requested
    l_results.merge!(get_data) if @output_settings[:data]                                                     #get data if requested

    @output_settings = l_hold_current_settings #now return to the existing defaults
    return l_results
  end

  private
    #get the actual data from the sql database for this instance based on all the select, where and order by options
    def get_data
      l_results = { data: []     }                  #default to no rows
      l_relation = active_record_relation           #build the active record relation (select, where, order, etc)

      if @output_settings[:data_format] == :array   #if array was requested, get only values with no column_names
        l_results[:data] = pluck
      elsif @output_settings[:data_format] == :hash #if has was requested, get only values WITH  column_names
        l_results[:data] = pluck_with_names
      else                                          #else, default to tails :active_record output
        l_results[:data] = l_relation.all.to_a
      end
      l_results                                     #return the results
    end

    #get various page related vars as determined by @output_settings
    def count_and_page_vars()
      l_results = {}
      if @output_settings[:count]
        l_results[:count] = (@output_settings[:count] || @output_settings[:page_vars]) ? count : nil      #count based on existing where clause
      end

      if @output_settings[:count_unfiltered]
        l_results[:count_unfiltered] = @output_settings[:count_unfiltered] ? (has_where? ? count_all() : l_results[:count]||count ) : nil  #count without first filtering, but if no where clause, then use same value as count
      end

      if @output_settings[:page_vars]                                   #are we to output the vars?
        l_results[:total_pages] = calc_pages(l_results[:count])         #if so, the calculate total pages
        l_results[:limit] = @limit                                      #get the requested limit
        l_results[:offset] = @offset                                    #get the requested offset
        l_results[:page] = calc_current_page(l_results[:total_pages])   #calulate the current page
      end

      l_results
    end

  #TODO: remove is not used anymore
    # def attach_pass_back(p_results)
    #   p_results.merge!({ pass_back: @pass_back }) unless @pass_back.nil?
    #   p_results
    # end


  private :get_data, :count_and_page_vars

end