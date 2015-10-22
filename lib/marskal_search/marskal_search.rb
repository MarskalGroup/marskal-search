#Call MarskalSearch
#Used to search for a string through tables and sub tables and return the results
#Can be used as an enhancement to ActiveRecord. Was originall developed to support the jquery plugins datatables and jqgrid, but can be used with out them
#Usage MarskalSearch.new (p_class, p_search_text, options)
# p_class:  ActiveRecord Model
#           examples: User  Contact Book
# p_search: String to search for
#            examples: "admin"  "williams" "poe"
#
# options:
#   **NOTE because of complicated queries, always include the table name with the field name for all parameters that allow fields.
#          for example pass 'contacts.last_name' instead of just 'last_name'
#          Also: this has only been tested for Mysql
#   :select_columns => A List of columns to be selected
#                     **ex:  "['contacts.last_name', 'contacts.first_name']"
#                     **joined table example: "['contacts.last_name', 'contacts.first_name', 'contact_phone_numbers.phone_number']"
#                     default: If blank, all fields will be selected from the primary table only unless otherwise changed by other options
#   :not_distinct => Duplicates Allowed? Note this does not just look at any one field..it looks at the entire selected fieldset
#                     Default: false    (no duplicates will be returned)
#   :joins        => Equivalent to the .joins option of an ActiveRecord relation. This parameters is simple passed on to that
#                     Example Single association ==> joins: :contact_phone_numbers
#                     Example Array association ==> joins: [:contact_phone_numbers, :contact_addresses, :contact_notes]
#                     IMPORTANT NOTE: These are LEFT JOINS, also These fields can be used in the select statement, the fields in these sub-tables  will be searched unless excluded by other options
#                    Default: if blank, the no joins will be added. However, if join(s) is provided, the default will be to search all sub-table fields unless otherwise specified by other options
#   :includes_for_select_and_search => Similar to :joins, except these are sql INNER JOINS
#                                      IMPORTANT NOTE: These fields can be used in the select statement, the fields in these sub-tables  will be searched unless excluded by other options
#                     Example Single association ==> includes_for_select_and_search: :contact_phone_numbers
#                     Example Array association ==> includes_for_select_and_search: [:contact_phone_numbers, :contact_addresses, :contact_notes]
#                    Default: if blank, no joins will be applied
#   :includes_for_search_only => Similar to :joins, except these are sql LEFT OUTER JOINS and are only used for searching. If search_text is blank, this option is ignored
#                                      IMPORTANT NOTE: These fields should NOT select statement, the fields in these sub-tables will be searched unless excluded by other options
#                     Example Single association ==> includes_for_search_only: :contact_phone_numbers
#                     Example Array association ==> includes_for_search_only: [:contact_phone_numbers, :contact_addresses, :contact_notes]
#                    Default: if blank, no joins will be applied
#   :default_where  => The where statement that will be applied in all cases. These are not excluded from counts.
#                       this is useful, when the entire set is actually just a subset of the overall data set
#                       for example:  a database may have 1000's of contacts, but any particular user will only be allowed access to a subset of that data
#                       in this case the default_scope would be something like "user_id = 100"
#   :where_string => This is simple an additional where clause to be added to the search
#                     Example: where_string: "contacts.contact_type = 'Investors'"
#                    Default: if blank, no additional conditions will be added
#   :individual_column_filters => Used to apply search to an individual or columns
#                     This was originally developed to support column filters for jquery datatables, but can be used separately.
#                     It expects an array of hashes with as of now 3 values
#                           { name:      name of db column
#                             operator:  sql operator such as LIKE, =, IS NOT NULL IN, etc.
#                             value:     what value are we searching for
#                            }
#                     IMPORTANT NOTE: if no operator is provided, it is assumed we are doing a LIKE '%value%' query
#                                     See method self.prep_datatables_column_filter if you are using jquery datatables
#                         Example: [{ name: 'contacts.last_name', operator: '=', value: "'williams'"}  => contacts.last_name = "williams" },
#                                   { name: 'contacts.first_name', operator: 'IN', value: "('Wilma', 'Sam')"},
#                                   { name: 'contacts.comments', value: "some note text"}
#                                  ]
#                         For Datatables example:
#                                   individual_column_filters: MarskalSearch.prep_datatables_column_filter(params)
#   :search_only_these_data_types => Search only the datatypes specified
#                     Example: datatypes [:string, :text]
#                    Default: if blank, all data types will be searched unless excluded by other options
#   :search_only_these_fields ==> used to limit the search to a particular field or fields. Very useful for a single column search, but can allow multiple as well
#                     Example Single Field: search_only_these_fields: "contacts.last_name"
#                     Example Multiple Fields: search_only_these_fields: ["contacts.last_name", "contacts.first_name_name", "contacts.company_name"]
#   :do_not_search_these_fields => Exclude these specific fields from the search
#                     Example Single Field: do_not_search_these_fields: "contacts.salary"
#                     Example Multiple Fields: do_not_search_these_fields: ["contacts.salary", "contacts.birthday"]
#   :ignore_default_search_field_exclusions => by default certain fields are excluded (such as id fields and rails timestamps) from the text search
#                                    IF this is passed as true, these default excluded fields will NOT be excluded and will be searched
#                                    Example:   ignore_default_search_field_exclusions: true
#                                    IMPORTANT NOTE: see the method default_field_excluded? for details on what fields get excluded from the search
#                                    Default: false (meaning the special fields WILL be excluded from search)
#   :case_sensitive ==> Determines whether the search is case sensitive
#                       IMPORTANT NOTE:  This was tested, using the default setting for mysql which ignores case, so in this case the option has no value, but I left it in for other configurations
#                                    Example:   case_sensitive: true
#                                    Default: true (case must match if your db is configured to allow case sensitivity )
#   :order_string => This is simply the order string for the sql statement
#                     Example: order_string: order by "contacts.last_name, contacts.first_name"
#                    Default: if blank, no order will be added
#   :offset ==>      For larger queries we may want to get a chunk at a time, offset is the starting point for that chunk..to be used in conjunction with limit useful for pagination
#                     offset: 10  (start at the 11th record)
#                     offset: 0  (start at the 1st record)
#                     default:  no offset is set, so search will start from beginning
#   :limit ==>       The maximum number of records to get..regardless of the amount of records that would be returned
#                     limit: 50  (retrive no more than 50 records)
#                     default:  no limit, all records are retrieved
#   IMPORTANT NOTE:   :offset and :limit have not effect on the count and count_filtered methods, these methods will consider the entire data set

class MarskalSearch
  MAX_LIMIT = 18446744073709551615                                    #mysql max to be used when an offset is given with no limit
  EXCLUDE_SEARCHABLE_COLUMN_LIST = ['id','created_at', 'updated_at']  #by default eliminate these as 'searchable' columns
  EXCLUDE_SEARCHABLE_COLUMN_ENDING_IN = '_id'                         # also fields like , user_id, contact_id
  EXCLUDE_SEARCHABLE_COLUMN_DATATYPES = [:boolean]                    # exclude boolean fields from the text searches
  DATATABLES = :datatables
  JQGRID = :jqgrid

  JQGRID_OPERATORS  =[{ op: "eq", newop: '=',         mask: '' },
                      { op: "ne", newop: '!=',        mask: '' },
                      { op: "lt", newop: '<',         mask: '' },
                      { op: "le", newop: '<=',        mask: '' },
                      { op: "gt", newop: '>',         mask: '' },
                      { op: "ge", newop: '>=',        mask: '' },
                      { op: "in", newop: 'IN',        mask: "([fld])" },
                      { op: "ni", newop: 'NOT IN',    mask: "([fld])" },
                      { op: "bw", newop: 'LIKE',      mask: "'[fld]%'" },
                      { op: "bn", newop: '"NOT LIKE', mask: "'[fld]%'" },
                      { op: "ew", newop: 'LIKE',      mask: "'%[fld]'" },
                      { op: "en", newop: 'NOT LIKE',  mask: "'%[fld]'" },
                      { op: "cn", newop: 'LIKE',      mask: "'%[fld]%'" },
                      { op: "nc", newop: 'NOT LIKE',  mask: "'%[fld]%'" },
                      { op: "nu", newop: 'IS NULL',     mask: nil },
                      { op: "nn", newop: 'IS NOT NULL',  mask: nil }
  ]

  MANUAL_SQL_SHORT_CODES = ['<', '>', '!=', '=', '>=', '<=', '::', '!::',  '%', '!%','~', '!~', '^', '!^']


  #these are the available options
  VARIABLES = <<-eos
               :select_columns, 
               :not_distinct,
               :joins, :includes_for_select_and_search, :includes_for_search_only,
               :default_where, :where_string, :search_only_these_data_types,
               :individual_column_filters,
               :search_only_these_fields, :do_not_search_these_fields,
               :ignore_default_search_field_exclusions,  :case_sensitive,
               :order_string,
               :offset, :limit, :pass_back
  eos

  eval "attr_accessor  #{VARIABLES}"
  attr_accessor  :search_text
  attr_reader  :klass


  #intialize class
  def initialize(p_class, p_search_text, options = {})
    eval "options.assert_valid_keys(#{VARIABLES})"          #only allow legit options

    #Select parameters
    self.select_columns = options[:select_columns]
    @not_distinct =  @not_distinct||false

    #joins and include parameters
    self.joins = options[:joins]
    self.includes_for_select_and_search = options[:includes_for_select_and_search]
    self.includes_for_search_only = options[:includes_for_search_only]

    #where parameters
    @default_where = options[:default_where]|| ''
    @where_string = options[:where_string]|| ''
    @search_text = p_search_text||''
    self.individual_column_filters = options[:individual_column_filters]
    self.search_only_these_fields = options[:search_only_these_fields]
    self.do_not_search_these_fields = options[:do_not_search_these_fields]
    self.search_only_these_data_types = options[:search_only_these_data_types]
    @case_sensitive = options[:case_sensitive] || true
    @ignore_default_search_field_exclusions = options[:ignore_default_search_field_exclusions] || false

    #order parameters
    @order_string = options[:order_string]|| ''

    #sql retrieval parameters
    @offset = options[:offset]
    @limit = options[:limit]

    #other parameters
    @pass_back  = options[:pass_back]||{}  #simply stores a hash that will be passed back as is..no changes

    @klass = p_class.is_a?(String) ? (eval p_class.classify) : p_class  #if string convert to a class

  end

  def valid_limit
    @limit <= 0 ? MAX_LIMIT : @limit
  end

  #make sure an array is returned
  def select_columns=(p_columns)
    @select_columns = Array(p_columns)
  end
  def select_string(p_prepare_for_count = false)
    l_select_string = ''
    unless @select_columns.blank?
      #ran into an issue with counting matching the actual result set...when you do a count, null values are not considered, so
      #to ensure we consider all fields, we apply an IFNULL(field, '') to get around this problem mau 10/2014
      if p_prepare_for_count
        l_select_string = @select_columns.sql_null_to_blank.to_string_no_brackets_or_quotes
      else
        l_select_string = @select_columns.to_string_no_brackets_or_quotes
      end
    end
    l_select_string  #return resulting string
  end

  #make sure an array is returned
  def search_only_these_fields=(p_fields)
    @search_only_these_fields= Array(p_fields).uniq
  end
  #make sure an array is returned
  def do_not_search_these_fields=(p_fields)
    @do_not_search_these_fields= Array(p_fields).uniq
  end

  #make sure an array is returned
  def joins=(p_joins)
    @joins = Array(p_joins).uniq
  end

  #make sure an array is returned
  def includes_for_select_and_search=(p_includes)
    @includes_for_select_and_search = Array(p_includes).uniq
  end

  #make sure an array is returned
  def includes_for_search_only=(p_includes)
    @includes_for_search_only = Array(p_includes).uniq
  end

  #make sure an array is returned
  def search_only_these_data_types=(p_search_only_these_data_types)
    @search_only_these_data_types = Array(p_search_only_these_data_types).uniq
  end
  #make sure an array is returned
  def individual_column_filters=(p_individual_column_filters)
    @individual_column_filters = Array(p_individual_column_filters).uniq
  end

  #get the searchable fields based on the current settings
  def searchable_fields
    @search_only_these_fields.empty? ? marskal_searchable_fields(@klass, combine_joins) : @search_only_these_fields
  end

  # take all the associations as passed via the options and build them into more usable joins for mysql, while maintaining them in rails format
  def combine_joins
    l_combine_joins = []  #start with empty array this eventually contain an array of hashes
    # hash will contain :klass =>     ActiveRecord class of the table to be joined
    #                   :join_sql =>  if needed The sql required to properly process the join, if not the the join association name (ex :contact_phone_numbers) will remain in tact
    #                   :alias =>     beacue the same table may be included in the inner join and outer joins, we provide for an alias to prevent ambiguous column errors

    #TODO: This will likely fall apart if two select_and_search includes come from same table, in that case we probably will have to resort to an alias as we did above, need to test sep/2014 MAU
    #first process the standard rails joins as is
    @joins.each_with_index do |l_association_symbol|
      l_association_symbol = (eval l_association_symbol) unless l_association_symbol.is_a?(Symbol)    #get the symbol for the sub-table class
      l_association = @klass.marskal_find_association(l_association_symbol)                          #get the association
      next if l_association.nil?                                                                      #if we cant find it, then we just move on
      l_combine_joins << { klass: l_association.derive_class_from_association,                        #otherwise we store it in our hash array
                           join_sql: l_association_symbol,
                           alias: nil
      }
    end

    #TODO: This will likely fall apart if two select_and_search includes come from same table, in that case we probably will have to resort to an alias as we did above, need to test sep/2014 MAU
    @includes_for_select_and_search.each_with_index do |l_association_symbol|
      l_association_symbol = (eval l_association_symbol) unless l_association_symbol.is_a?(Symbol)    #get the symbol for the sub-table class
      l_association = @klass.marskal_find_association(l_association_symbol)                           #get the association
      next if l_association.nil?                                                                      #if we cant find it, then we just move on
      l_join_hash = { klass: nil, join_sql: '', alias: nil }                                          #set defaults
      l_join_hash[:klass] = l_association.derive_class_from_association                               #get class
      l_join_hash[:join_sql] = "LEFT JOIN #{@klass .joins(l_association_symbol).to_sql.split('INNER JOIN').last}" #convert from INNER JOIN TO LEFT JOIN
      l_combine_joins << l_join_hash
    end


    #if there is text to search, then lets setup our outer join(s), otherwise no point to outer join and would cause perfomance degradation to include it
    unless @search_text.blank?
      @includes_for_search_only.each_with_index do |l_association_symbol, l_alias_ctr|
        l_association_symbol = (eval l_association_symbol) unless l_association_symbol.is_a?(Symbol)    #get the symbol for the sub-table class
        l_association = @klass.marskal_find_association(l_association_symbol)                           #get the association
        next if l_association.nil?                                                                      #if we cant find it, then we just move on

        l_join_hash = { klass: nil, join_sql: '', alias: nil }                                          #set defaults
        l_join_hash[:klass] = l_association.derive_class_from_association                               #get class
        l_join_hash[:alias] = "alias#{l_alias_ctr}"                                                     #assign an alias to avoid ambiguous column errors

        l_aliased_join_conditions =@klass.joins(l_association_symbol).to_sql.split('INNER JOIN').last.split(' ON ').last.gsub(l_join_hash[:klass].table_name, l_join_hash[:alias]) #replace table names with alis name
        l_join_hash[:join_sql] = "LEFT OUTER JOIN `#{l_join_hash[:klass].table_name}` `#{l_join_hash[:alias]}` ON #{l_aliased_join_conditions}"  #create an outer join

        l_combine_joins << l_join_hash
      end
    end

    l_combine_joins
  end

  #display only: completed where clause
  #options:   (The main and probably only reason for these options, is so the query can do a unfiltered count, probably for pagination and results output)
  # :exclude_where_string  ==> if true, the @where_string variable is not considered...default is false
  # :exclude_search_text  ==> if true, the @search_text variable is not considered...default is false
  def complete_where_clause(p_options = {})
    p_exclude_where = p_options[:exclude_where_string]||false
    p_exclude_search_text = p_options[:exclude_search_text]||false

    #are we excluding the where clause (probably for a count)
    if p_exclude_where
      l_where_clause = ''
    else
      l_where_clause = @where_string || '' #start with anything the caller passed if provided
      l_col_where = combine_individual_column_filters
      unless l_col_where.blank?
        l_where_clause += ' AND ' unless l_where_clause.blank?
        l_where_clause += l_col_where
      end
    end

    #if we have text to search then build where clause and we are not excluding it
    unless @search_text.blank? || p_exclude_search_text
      fields = searchable_fields
      text_condition = unless @case_sensitive
                         fields.collect { |f| "UCASE(#{f}) LIKE #{sanitize('%'+@search_text.upcase+'%')}" }.join " OR "
                       else
                         fields.collect { |f| "#{f} LIKE #{sanitize('%'+@search_text+'%')}" }.join " OR "
                       end

      unless  text_condition.blank?
        l_where_clause += ' AND ' unless l_where_clause.blank?
        l_where_clause += "( #{text_condition } ) " unless  text_condition.blank?

      end
    end
    return l_where_clause
  end

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
    @select_columns.empty? ? active_record_relation.pluck : active_record_relation.pluck(select_string)
  end

  #do an active record 'pluck'
  def pluck_with_names
    l_records = active_record_relation.pluck(select_string)
    l_data = []
    l_records.each do |l_record|
      l_hash = {}
      @select_columns.each_with_index do |l_column, index|
        l_hash[l_column.to_sym]  = l_record[index]
      end
      l_data << l_hash
    end
    l_data
  end

  #:format => default is an Array of ActiveRecord Objects
  #:format => :datatables  return in a compatible format with the jquery datatables plugin
  def results(p_options = {})
    l_relation = active_record_relation
    p_options.assert_valid_keys :format             #allow only legit options


    #now execute and return data in requested format
    if p_options[:format] == DATATABLES
      l_results = { recordsTotal:  count_all, recordsFiltered: count, data: pluck }.merge(@pass_back)
    elsif p_options[:format] == JQGRID
      l_results = { total:  calc_page(), records: count, rows: pluck_with_names }.merge(@pass_back)
    else
      l_results = l_relation.to_a
    end
    return l_results
  end

  #display only: completed where clause
  #options:   (The main and probably only reason for these options, is so the query can do a unfiltered count, probably for pagination and results output)
  # :exclude_where_string  ==> if true, the @where_string variable is not considered...default is false
  # :exclude_search_text  ==> if true, the @search_text variable is not considered...default is false
  # :exclude_order  ==> if true, the @order_string variable is not considered...default is false
  def active_record_relation(p_options = {})
    #p_options[:exclude_where_string]  ==> gets passed along to complete_where_clause
    #p_options[:exclude_search_text]   ==> gets passed along to complete_where_clause
    p_exclude_order = p_options[:exclude_order]||false
    p_exclude_offset_and_limit = p_options[:exclude_offset_and_limit]||false
    p_prepare_select_for_count = p_options[:prepare_select_for_count]||false

    l_relation =  @klass.where(@default_where||'')
    l_relation.merge! @klass.distinct unless @not_distinct #establish a starting point to the relation
    l_relation.merge!(@klass.select(select_string(p_prepare_select_for_count))) unless @select_columns.empty?   #apply select if available

    joins = combine_joins.map { |join| join[:join_sql]}                             #build all the joins
    l_relation.merge!(@klass.joins(joins)) unless joins.blank?                      #apply joins if available

    where_clause = complete_where_clause(p_options)                                 #build WHERE CLAUSE AND SEARCH TEXT
    l_relation.merge!(@klass.where(where_clause)) unless where_clause.blank?        #apply if available
    l_relation.merge!(@klass.order(@order_string)) unless @order_string.blank? || p_exclude_order #apply order if available

    unless p_exclude_offset_and_limit
      if @offset                                      #apply offset and/or limit as requested
        l_relation.merge!(@klass.offset(@offset).limit(valid_limit))
      elsif @limit
        l_relation.merge!(@klass.limit(valid_limit))
      end
    end

    return l_relation
  end

  private
  # Return the default set of fields to search on
  def marskal_searchable_fields(p_class, p_join_hash, p_table_alias = nil)
    fields = []
    p_join_hash ||= []
    p_class.columns.each do |col|   #get all the columns for this class (table)
      p_include_field = true        #assume we can use this in the search until it is explicitly excluded
      unless  @search_only_these_data_types.empty?
        p_include_field = false unless @search_only_these_data_types.include?(col.type)       #exclude if the data_types is to be excluded
      end
      unless @ignore_default_search_field_exclusions
        p_include_field = false if default_field_excluded?(col)
      end
      if p_include_field   #if we still plan to include this field, then lets run past our exclusion list
        p_include_field = false if @do_not_search_these_fields.include?("#{p_class.table_name}.#{col.name}")
      end
      fields << "#{p_table_alias||p_class.table_name}.#{col.name}" if p_include_field
    end

    l_aliased_tables = p_join_hash.reject { |j| j[:alias].nil? }.map {|j| j[:klass].table_name}
    p_join_hash.each do |p_join_info|
      next if p_join_info[:alias].nil? && l_aliased_tables.include?(p_join_info[:klass].table_name)  #dont process if we are going to process as an alias, thats just duplicating the fields
      klass = p_join_info[:klass]
      fields += marskal_searchable_fields(klass, [], p_join_info[:alias])
    end

    return fields
  end

  def default_field_excluded?(p_column)
    l_approved = false
    if !p_column.name.ends_with?(EXCLUDE_SEARCHABLE_COLUMN_ENDING_IN) && !(@do_not_search_these_fields + EXCLUDE_SEARCHABLE_COLUMN_LIST).include?(p_column.name) &&  !EXCLUDE_SEARCHABLE_COLUMN_DATATYPES.include?(p_column.type)
      l_approved = true
    end
    !l_approved
  end

  def sanitize(l_sql_string)
    @klass.sanitize(l_sql_string)
  end

  def testme
    # create User and Contact models with at least these fields
    #     User      => id, last_name, first_name
    #     Contact  => id, last_name, first_name, user_id
    #
    #     The connect them in the models
    #     In User.rb      => has_many :contacts
    #     In Contact.rb   => belongs_to_user
    #
    #     Populate some data and then you can experiment with these examples
    #

    #find where a user must have at least one contact, and 'mike' is found in either the users or the contacts table
    #return the names from both tables and the user_id
    #order by contacts last_name then first
    #get the first 10 records
    #Note 'new' cause the the creation not the execution, basically just prepares for other methods show further below
    m = MarskalSearch.new(User, 'mike',
                          joins: :contacts,
                          select_columns: "users.last_name, users.first_name, users.id, contacts.last_name, contacts.first_name",
                          where_string:  'active = true',
                          order_string:  'contacts.last_name, contacts.first_name',
                          offset: 0,
                          limit: 10
    )

    #output method examples
    m.count                       # how many records were found in search
    m.count_without_search_text   #apply the where_string if not blank, but exclude the search_text from count
    m.count_all                   #how may records total without any filters or where clauses
    m.to_sql                      #the sql statement as it will be passed to mysql or other sql client
    m.results                     #execute query and return the results into an array of ActiveRecord Objects
    m.pluck                       #execute query, but return the selected fields in a two dimensional array, just the values, not field names
    m.complete_where_clause       #just show me only the resulting qhere cluase based on current settings, (nothing is executed, display only)
    m.combine_joins               #show me the details of how the joins and includes options will be processed  (nothing is executed, display only)


    #find where a user MAY or MAY NOT have at least one contact, and 'mike' is found in either the users or the contacts table
    #return the names from both tables and the user_id
    #order by contacts last_name then first
    #get the first 10 records
    m1 = MarskalSearch.new(User, 'mike',
                           includes_for_select_and_search: :contacts,
                           select_columns: "users.last_name, users.first_name, users.id, contacts.last_name, contacts.first_name",
                           where_string:  'active = true',
                           order_string:  'contacts.last_name, contacts.first_name',
                           offset: 0,
                           limit: 10
    )


    #find where a user MAY or MAY NOT have at least one contact, and 'mike' is found in either the users or the contacts table
    #return the names from ONLY the users table and the user id
    #order by users last_name then first
    #get the first 10 records
    #NOTE this is basically like saying, give me all the users that have mike in the user record or the related detail records in contacts
    # even if the contacts table has 100 mikes connected with user, only a single record would be returned for teh user
    #nothing from the contact record is return..it is simply there for search needs
    m2 = MarskalSearch.new(User, 'mike',
                           includes_for_search_only: :contacts,
                           select_columns: "users.last_name, users.first_name, users.id",
                           where_string:  'active = true',
                           order_string:  'users.last_name, users.first_name',
                           offset: 0,
                           limit: 10
    )

    #these can be daisy chained as well
    MarskalSearch.new(User, 'mike', includes_for_search_only: :contacts).count
    MarskalSearch.new(User, 'mike', includes_for_search_only: :contacts).results


  end

  #the format expected is and array of hashes ex:
  # { name: 'contacts.last_name', operator: '=', value: "'williams'"}  => contacts.last_name = "williams"
  # { name: 'contacts.last_name', operator: 'IN', value: "('williams', 'jones')"}  => contacts.last_name IN ('williams', 'jones')
  # { name: 'contacts.last_name', operator: nil, value: "jone"}  => contacts.last_name LIKE ('%jones%') #DO NOT INCLUDE the SINGLE quotes for default processing, just the text itself
  #     NOTE: when operator is nil, then we default to a LIKE with % on both sides
  #
  # { name: 'contacts.last_name', operator: 'LIKE', value: "'jone%'"}  => contacts.last_name LIKE ('jones%')
  #     NOTE: when operator is explicity defined as LIKE, then we do not apply the %, that is up to the caller of the function
  #
  # { name: 'contacts.last_name', operator: 'IS NOT NULL', value: nil}  => contacts.last_name IS NOT NULL
  #
  # IMPORTANT NOTE: This does not use the @case_sensitive function, it is up to the caller to do that for now 10/2014
  # TODO: Add 'OR' capabilities and grouping capabilities
  #
  def combine_individual_column_filters
    l_where = ''
    @individual_column_filters.each do |l_col_hash|
      next if l_col_hash[:name].blank? or  (l_col_hash[:operator].blank? && l_col_hash[:value].blank?)  #if we dont have what we need just continue on

      l_where += ' AND ' unless l_where.blank?   #append existing query

      if l_col_hash[:operator].blank?                           #if no operator is given, then the default will be used
        l_condition = "LIKE '%#{l_col_hash[:value]}%' "          #we assume this is a LIKE %searchtext% query
      else
        l_condition = "#{l_col_hash[:operator]} #{l_col_hash[:value]}" #otherwise, just use what the user passed to us
      end

      l_where += "( #{l_col_hash[:name]} #{l_condition} )"             #build the statement
    end

    l_where.blank? ? '' : "( #{l_where} )"

  end

  #prepares jquery datatables column filters into a MarskalSearch compatible format
  #Ex: MarskalSearch.individual_column_filters = MarskalSearch.prep_datatables_column_filter(params)
  def self.prep_datatables_column_filter(p_params)
    #
    l_cols_with_values= []
    p_params[:columns].each do |l_colptr|
      l_cols_with_values << { name: l_colptr[1][:name], value: l_colptr[1][:search][:value] } unless l_colptr[1][:search][:value].blank?
    end

    ((p_params[:marskal_params][:extra_data]||{}).try(:[], :column_filters)||{}).each do |k,v|
      l_cols_with_values << { name: v[:name], operator: v[:operator], value: v[:value] } unless v.blank? || !v.is_a?(Hash)
    end

    l_cols_with_values
  end

  #prepares jquery jqgrid column filters into a MarskalSearch compatible format
  #Ex: MarskalSearch.individual_column_filters = MarskalSearch.prep_jqgrid_column_filter(params)
  def self.prep_jqgrid_column_filter(p_params, p_options = {})
    p_options.assert_valid_keys(:space_to_equal_fields)
    l_filters = p_params['filters'].nil?  ? [] : ActiveSupport::JSON.decode( p_params['filters'] )

    #"{"groupOp":"AND","rules":[{"field":"security_role","op":"eq","data":"100,500"}]}"    #sample of what is expected
    l_cols_with_values= []
    unless l_filters.empty?                                 #if we do have filters
      l_filters['rules'].each do |l_hash|                   #then we pull from rules params['rules'] sent by jqgrid
        l_cols_with_values << jqgrid_operators(l_hash, p_options)      #then we format for MarskalSearch
      end
    end

    l_cols_with_values #return array of conditions
  end


  #prepares a hash friendly to MarskalSearch column filter handling routines
  #expects a hash as sent by the jqgrid plugin for column filters
  def self.jqgrid_operators(p_hash, p_options = {})
    p_options.assert_valid_keys(:space_to_equal_fields)

    l_value  = ''
    l_new_op = 'LIKE'

    #check for manual short cuts or else just return values provided
    l_sql_op, l_filter_value, l_found = check_for_manual_short_code(p_hash['op'], p_hash['data'])

    if  l_found                   #we have a manual override
      l_value = l_filter_value    #then lets set the values
      l_new_op = l_sql_op         #to be used and skip the normal process
    else
      JQGRID_OPERATORS.each do |l_ops|            #loop through all the various operators
        if l_ops[:op] == l_sql_op                #if we found the operator in either jqgrid or sql format then we use the proper sql operator
          l_new_op = l_ops[:newop]                #then save the mysql equivalent
          if l_new_op.include?('IN')              #for 'IN' and 'NOT IN' we need to prepare the data properly
            l_value = l_filter_value.split(',').prepare_for_sql_in_clause
          elsif l_ops[:mask].nil?
            l_value = '' #else we simply replace the mas [fld] with our field value from jqgrid filter
          elsif Array(p_options[:space_to_equal_fields]).include?(p_hash['field']) && l_ops[:op] == "bw" && l_filter_value.slice(-1,1) == ' '
            l_new_op = '='
            l_value = "'#{l_filter_value.strip}'"
          else
            l_value = l_ops[:mask].blank? ? l_filter_value : l_ops[:mask].gsub('[fld]',l_filter_value)  #else we simply replace the mas [fld] with our field value from jqgrid filter
          end
          break   #we found our operator, so no need to look any further
        end
      end
    end
    { name: p_hash['field'], operator: l_new_op, value: l_value }  #return MarskalSearch filter hash
  end


  def self.check_for_manual_short_code(p_default_op, p_val)
    l_op = p_default_op
    l_val = p_val
    l_found = false
    if MANUAL_SQL_SHORT_CODES.include?(p_val.split.first)
      idx = p_val.index(' ')
      unless idx.nil? || idx >= p_val.length
        l_val = "'#{p_val[idx+1..p_val.length]}'"
        l_op = p_val.split.first.sub('!%', 'NOT LIKE').sub('%', 'LIKE').sub("!^", 'NOT IN').sub("^", 'IN').sub('!::', 'NOT BETWEEN').sub('::', 'BETWEEN').sub("!~", "NOT CONTAINS").sub("~", "CONTAINS")
        if l_op == 'BETWEEN'
          l_val.gsub!('&&', "' AND '")
        elsif l_op.include?("CONTAINS")
          l_op.sub!('CONTAINS', 'LIKE')
          l_val = "'%#{p_val[idx+1..p_val.length]}%'"
        elsif l_op.include?("IN")
          l_val = "( #{l_val.gsub(',', "','")} )".gsub(",''", '')   #buil;d in list and then clean out any empty strings
        end
      end
      l_found = true
    end
    puts "==> #{l_op}, #{l_val}, #{l_found}"
    return l_op, l_val, l_found
  end

  def self.prepare_jqgrid_column_names(p_marskal_params, p_hash_key = 'name')
    x = p_marskal_params['colModel']
    (p_marskal_params['colModel']||[]).collect { |l_col_hash|  "#{l_col_hash[p_hash_key]}" }.reject { |c|  not_db_column?(c) }
  end

  #return true if if not a db column, for now thats 'cb' (checkbox in jqgrid)
  # or any field that has the text 'nodb_' in the name (prefable should start with nodb_, e.g. nodb_display_field)
  def self.not_db_column?(p_col)
    p_col.downcase == 'cb' || p_col.downcase.include?("nodb_")
  end

  def calc_page()
    (self.count / self.limit).to_i + 1
  end

end