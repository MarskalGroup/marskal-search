Rails.application.routes.draw do

  post 'marskal_jqgrid' => 'marskal_search#jqgrid'
  get 'marskal_jqgrid' => 'marskal_search#jqgrid'

end