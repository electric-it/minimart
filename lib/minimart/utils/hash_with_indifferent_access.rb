module Minimart
  module Utils
    class HashWithIndifferentAccess < Hash
      include Hashie::Extensions::MergeInitializer
      include Hashie::Extensions::IndifferentAccess
    end
  end
end
