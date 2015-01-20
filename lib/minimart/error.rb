module Minimart
  module Error
    class BaseError < StandardError; end
    class UnresolvedDependency < BaseError; end
    class InvalidInventoryError < BaseError; end
    class UniverseNotFoundError < BaseError; end
    class DependencyNotMet < BaseError; end
    class CookbookNotFound < BaseError; end
    class BrokenDependency < BaseError; end

    def self.handle_exception(ex)
      Configuration.output.puts_red(ex.message)
      exit false
    end
  end
end
