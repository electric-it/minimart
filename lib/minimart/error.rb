module Minimart
  module Error
    class UnresolvedDependency < Exception; end
    class InvalidInventoryError < Exception; end
    class UniverseNotFoundError < Exception; end
    class DependencyNotMet < Exception; end
    class CookbookNotFound < Exception; end
    class BrokenDependency < Exception; end
  end
end
