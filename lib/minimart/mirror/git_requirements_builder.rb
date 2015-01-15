require 'minimart/inventory_requirement/git_requirement'

module Minimart
  module Mirror
    class GitRequirementsBuilder

      attr_reader :name
      attr_reader :location
      attr_reader :branches
      attr_reader :tags
      attr_reader :refs

      def initialize(name, reqs)
        @name     = name
        git_reqs  = reqs.fetch('git', {})

        @location = git_reqs['location']
        @branches = raw_location_type_requirement(git_reqs, 'branches')
        @tags     = raw_location_type_requirement(git_reqs, 'tags')
        @refs     = raw_location_type_requirement(git_reqs, 'refs')
      end

      def build
        from_branches + from_tags + from_refs
      end

      private

      def from_branches
        branches.map { |b| build_requirement(:branch, b) }
      end

      def from_tags
        tags.map { |t| build_requirement(:tag, t) }
      end

      def from_refs
        refs.map { |r| build_requirement(:ref, r) }
      end

      def build_requirement(type, value)
        InventoryRequirement::GitRequirement.new(name, {type => value}.merge(location: location))
      end

      def raw_location_type_requirement(requirements, location_type)
        result = requirements.fetch(location_type, [])
        result = [result] if result.is_a? String
        result
      end
    end
  end
end
