require "marskal/search/version"
require 'marskal_search/marskal_active_record_extensions'  #contains some needed functions
require "marskal_search/marskal_search"

module Marskal
  class Engine < Rails::Engine
     initializer 'marskal-search.setup', group: :all do |app|
       app.config.assets.paths << ::Rails.root.join('app', 'assets', 'javascripts')
    end
  end
end