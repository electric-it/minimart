module Minimart
  module Error
    class UnresolvedDependency < StandardError; end
    class InvalidInventoryError < StandardError; end
    class UniverseNotFoundError < StandardError; end
    class DependencyNotMet < StandardError; end
    class CookbookNotFound < StandardError; end
    class BrokenDependency < StandardError; end

    def self.handle_exception(ex)
      Configuration.output.puts_red(ex.message)
      exit false
    end
  end
end
