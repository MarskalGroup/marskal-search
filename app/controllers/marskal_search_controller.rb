#this controller will output the appropriate data in a jqgird firendly format
#Note there are some custom requirements to be included ion the jqgrid process
# marskal_params is part of the jqgrid structure to pass neededed for this function
# see routes.rb for the appropriate route to call to access this controller and its methods

# TODO: This needs to be well documented. Right now it is not.
# TODO: Need to add a datables option as well

class MarskalSearchController < ApplicationController
  def jqgrid

    #clean up the variables customized for MarskalSearch
    marskal_params =  ActiveSupport::JSON.decode( params[:marskal_params] )

    #futher transform marskal parameters and standard jqgrid provided parameters (e.g. rows, page, sidx) for use in MarskalSearch
    marskal_params[:select_columns] =  MarskalSearch.prepare_jqgrid_column_names(marskal_params)
    marskal_params[:limit] =          params['rows'].to_i
    marskal_params[:offset] =         (params['page'].to_i - 1) * marskal_params[:limit]
    # marskal_params[:order_string] =   params['sidx'].blank? ? marskal_params['default_order'] : "#{params['sidx']} #{params['sord']}"
    marskal_params[:order_string] =   sort_order_hack(params, marskal_params)

    marskal_params[:default_where] =  marskal_params['default_where'].to_s
    marskal_params[:where_string] =  ApplicationHelper.append_sql_where_if_true(marskal_params['where_string'].to_s, 'AND', marskal_params['starting_filter'].to_s )

    #this is for a single field search among all columns or table...this has not been implemented in jqgrid yet
    marskal_params[:search_text] =''  # params[:search_text] Just leave blank for now

    ms = MarskalSearch.new(marskal_params['model'].constantize,
                           marskal_params[:search_text],
                           select_columns:                 marskal_params[:select_columns],
                           joins:                          marskal_params[:joins],
                           includes_for_select_and_search: marskal_params[:includes_for_select_and_search],
                           includes_for_search_only:       marskal_params[:includes_for_search_only],
                           default_where:                  marskal_params[:default_where],
                           where_string:                   marskal_params[:where_string],
                           individual_column_filters:      MarskalSearch.prep_jqgrid_column_filter(params, space_to_equal_fields: ['symbol']),
                           search_only_these_fields:       marskal_params[:search_only_these_fields],
                           order_string:                   marskal_params[:order_string],
                           offset:                         marskal_params[:offset].to_i,
                           limit:                          marskal_params[:limit].to_i,
                           pass_back:                      { page: params['page']}
    )

    sql = ms.to_sql   #for debugging if you wanna see what the sql being generated is
    # puts sql.split(' WHERE ').last
    # puts JSON.pretty_generate(params)
    # puts sql.count
    render json: ms.results(format: :jqgrid)

  end

  def sort_order_hack(params, marskal_params)
    marskal_columns = MarskalSearch.prepare_jqgrid_column_names(marskal_params, 'index')
    l_sort_columns = "#{params['sidx']} #{params['sord']}".split(',')
    l_sort_column_index_order = params['sort_column_order']

    l_order_str = ''
    Array(l_sort_column_index_order).each do |l_column|
      l_index_name = marskal_columns[l_column.to_i]
      l_sort_columns.each do |sort|
        if sort.include?(l_index_name)
          l_order_str += ',' unless l_order_str.blank?
          l_order_str += " #{sort} "
          break
        end
      end
    end

    return l_order_str.blank? ?  marskal_params['default_order']: l_order_str

  end

end
