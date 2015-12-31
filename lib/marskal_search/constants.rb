class MarskalSearch

  DEFAULT = :default

  TIMESTAMP_FIELDS = %w(created_at updated_at)



  COLUMN_MODEL_STARTER = 'Marskal'
  COLUMN_WRAPPER_CHAR = "`"
  MAX_LIMIT_WITHOUT_OVERRIDE = 200
  MAX_LIMIT = 18446744073709551615                                    #mysql max to be used when an offset is given with no limit
  EXCLUDE_SEARCHABLE_COLUMN_LIST = ['id','created_at', 'updated_at']  #by default eliminate these as 'searchable' columns
  EXCLUDE_SEARCHABLE_COLUMN_ENDING_IN = '_id'                         # also fields like , user_id, contact_id
  EXCLUDE_SEARCHABLE_COLUMN_DATATYPES = [:boolean]                    # exclude boolean fields from the text searches
  DATATABLES = :datatables
  JQGRID = :jqgrid
  MARSKAL_API = :marskal_api
  EVERYTHING = :everything

  FORCE_REPARSE_OF_LAST_SELECT = "FORCE"

  WRAP_THESE_RESERVED_WORDS = [ 'primary', 'query', 'type' ]



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
                  :search_text, :q,
                  :wrap_column,
                  :model,
                  :create_model,
                  :select_string, :s,
                  :select_view, :sv,
                  :output_settings, :format,
                  :page,


                 :not_distinct,
                 :joins, :includes_for_select_and_search, :includes_for_search_only,
                 :default_where, :where_string, :search_only_these_data_types,
                 :individual_column_filters,
                 :search_only_these_fields, :do_not_search_these_fields,
                 :ignore_default_search_field_exclusions,  :case_sensitive,
                 :order_string,
                 :offset, :limit, :requested_page,
                 :pass_back
  eos

  # WRITABLE = <<-eos
  #                :set_wrap_column
  # eos




  #prefined formats to simply usage
  PREDEFINED_FORMATS = {
      everything:  {                  #show everything
                                      data:             true,
                                      count_unflitered: true,
                                      count:            true,
                                      page_vars:        true,
                                      column_details:   true,
                                      column_names:     true,
                                      column_headings:  true
      },
      only_data:  {                   #show only the data (in the current defined :data_format)
                                      data:             true,
                                      count_unflitered: false,
                                      count:            false,
                                      page_vars:        false,
                                      column_details:   false,
                                      column_names:     false,
                                      column_headings:  false
      },
      no_data:  {                     #show all except the data
                                      data:             false,
      },
      array_with_heads_and_vars:  {  #show data in an array, plus column heads and page vars
                                      data:             true,
                                      count_unflitered: false,
                                      count:            true,
                                      page_vars:        true,
                                      column_details:   false,
                                      column_names:     true,
                                      column_headings:  true,
                                      data_format:      :array
      }
  }
  VALID_FORMATS = PREDEFINED_FORMATS.keys + [DEFAULT, :marskal_api]

  #format is value for default to use position in list of keys
  # example
  #  wrap_column: { default: 0, valid: [:if_special, :never, :always ], schort_cut: short_cut_symbol } ==> the default is :if_special
  #
  #  wrap_column: { default: NO_DEFAULT, valid: [:if_special, :never, :always ], tip: 'some helpful info here' } ==> the default is :if_special
  #   sets value to nil
  #
  VALID_KEYS = {
      wrap_column:  { default: 0, valid: [:if_special, :never, :always ]},
      search_text:  { default: '', shortcut: :q }, # :q stands for query, this is what google uses as standard, so we adopted
      model:        { default: nil },
      create_model: { default: nil },
      select_string:  { default: '', shortcut: :s },
      select_view:  { default: 0, valid: [:xs, :sm, :md, :lg, :xl ], shortcut: :sv },
      format:         { default: 0, valid: VALID_FORMATS},
      output_settings: { default: {} } #defaults and valid keys are handled in a different way
  }
  ALL_VALID_KEYS = (MarskalSearch::VALID_KEYS.map {|k,v| k} + MarskalSearch::VALID_KEYS.map {|k,v| v[:shortcut]}).reject {|k| k.blank? }


  VALID_OUTPUT_SETTINGS = {
      data:             { default: true, valid: [true, false]},  #output only rows, this overrides all other settings
      data_format:      { default: :active_record, valid: [:active_record, :hash, :array] },  #format of data rows rows format
      page_vars:        { default: true, valid: [true, false]},    #offset, limit and page, total_pages
      count:            { default: true, valid: [true, false]},    #count of filtered data (rows)
      count_unfiltered: { default: false, valid: [true, false]},   #Potential time consumer, so default to false
      column_details:   { default: true, valid: [true, false]},    #detailed infor about data heads, etc
      column_names:     { default: false, valid: [true, false]},    #names of columns
      column_headings:  { default: false, valid: [true, false]},    #headings of columns
      datetime_format:  { default: "%Y-%m-%d %H:%i"},               #default_datetime_format
  }



  ERRORS = {
      invalid_limit: "Limit must be between: #{1} and #{MAX_LIMIT_WITHOUT_OVERRIDE}: Use: limit_override: or lo: to override the maximum value of  #{MAX_LIMIT_WITHOUT_OVERRIDE}",
      invalid_output_setting: 'Invalid output setting:: ',
      no_table: 'Table Does Not Exist:: ',
      unable_to_create_model: 'Unable to create a model for table:',
      need_model: "Model Not Found: Provide an existing model using option 'model:' or use option 'create_model:[table_name, connection_name]' to create the model dynamically",
      invalid_format_create_model: "create_model: must either be an array or string.  ex: create_model: 'my_table', create_model: ['my_table', 'db_connection'] db_connection will default to app default if not provided",
      invalid_select_view_format: "Invalid select view format: Usage sv=<[xs|sm|md|lg|xl]><.add|.sub><(fields in parenrthesis separated by commas)>. Examples: sv=xs.add(last_name) sv=xl.sub(client_id,employee_id) sv=sm.add(last_name, first_name).sub(salary+commission)"
  }



end