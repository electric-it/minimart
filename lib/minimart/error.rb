module Minimart
  # The collection of Minimart specific errors.
  module Error
    class BaseError < StandardError; end

    # Raised when a dependency cannot be met.
    class UnresolvedDependency < BaseError; end

    # Raised when there is an error parsing the inventory file.
    class InvalidInventoryError < BaseError; end

    # Raised when a source does not respond to '/universe' correctly.
    class UniverseNotFoundError < BaseError; end

    # Raised when none of the available sources have a given cookbook.
    class CookbookNotFound < BaseError; end

    # Raised when there is a conflict between different versions of the same cookbook.
    class BrokenDependency < BaseError; end

    # Raised when Minimart encounters a cookbook with a location type that it can't handle
    class UnknownLocationType < BaseError; end

    # Gracefully handle any errors raised by Minimart, and exit with a failure
    # status code.
    # @param [Minimart::Error::BaseError] ex
    def self.handle_exception(ex)
      Configuration.output.puts_red(ex.message)
      exit false
    end
  end
end
