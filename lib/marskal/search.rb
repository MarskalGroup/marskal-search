require "marskal/search/version"
require 'marskal_search/marskal_active_record_extensions'  #contains some needed functions
require "marskal_search/marskal_search"

module Marskal
  class Engine < Rails::Engine; end
end