module Minimart
  # The Web namespace is used for building the cookbook index, and generating
  # any HTML.
  module Web
    require 'minimart/web/cookbooks'
    require 'minimart/web/html_generator'
    require 'minimart/web/template_helper'
    require 'minimart/web/universe_generator'
  end
end
