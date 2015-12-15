class MarskalSearch


  COLUMN_WRAPPER_CHAR = "`"
  MAX_LIMIT = 18446744073709551615                                    #mysql max to be used when an offset is given with no limit
  EXCLUDE_SEARCHABLE_COLUMN_LIST = ['id','created_at', 'updated_at']  #by default eliminate these as 'searchable' columns
  EXCLUDE_SEARCHABLE_COLUMN_ENDING_IN = '_id'                         # also fields like , user_id, contact_id
  EXCLUDE_SEARCHABLE_COLUMN_DATATYPES = [:boolean]                    # exclude boolean fields from the text searches
  DATATABLES = :datatables
  JQGRID = :jqgrid
  MARSKAL_API = :marskal_api

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
                 :select_columns,
                 :not_distinct,
                 :joins, :includes_for_select_and_search, :includes_for_search_only,
                 :default_where, :where_string, :search_only_these_data_types,
                 :individual_column_filters,
                 :search_only_these_fields, :do_not_search_these_fields,
                 :ignore_default_search_field_exclusions,  :case_sensitive,
                 :order_string,
                 :offset, :limit, :page,
                 :pass_back, :wrap_column
  eos

  WRITABLE = <<-eos
                 :set_wrap_column
  eos


  #format is value for default to use position in list of keys
  # example
  #  wrap_column: { default: 0, valid: [:if_special, :never, :always ], tip: 'some helpful info here' } ==> the default is :if_special
  #
  #  wrap_column: { default: NO_DEFAULT, valid: [:if_special, :never, :always ], tip: 'some helpful info here' } ==> the default is :if_special
  #   sets value to nil
  #
  VALID_KEYS = {
      wrap_column: { default: 0, valid: [:if_special, :never, :always ]}
  }



end