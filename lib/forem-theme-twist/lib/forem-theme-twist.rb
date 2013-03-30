require 'forem'
module Forem
  module Theme
    module Base
      class Engine < Rails::Engine
        Forem.theme = :twist
      end
    end
  end
end
