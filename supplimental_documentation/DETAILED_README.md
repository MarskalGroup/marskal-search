### MarskalSearch Option List and Examples
---
#### Usage
* This document contains a list of options for  `class MarskalSearch` of the marskal-search gem.

##### Class & Parameters #####
```ruby
#
# Usage MarskalSearch.new (p_class, p_search_text, options)
#
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
#   IMPORTANT NOTE:   :offset and :limit have no effect on the count and count_filtered methods, these methods will consider the entire data set
```

#####   Examples:   #####

```ruby
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
    m.results(format: :jqgrid)    #execute query and return the results into a jqgrid friendly format  
    m.results(format: :datatables) #execute query and return the results into a juery datables friendly format  
    m.results(format: :marskal-api) #execute query and return the results into a marksal-api friendly output
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
```


---
Back to [README.md](../README.md)