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
        @branches = raw_location_type_requirement(%w[branches branch], git_reqs)
        @tags     = raw_location_type_requirement(%w[tags tag], git_reqs)
        @refs     = raw_location_type_requirement(%w[refs ref], git_reqs)

        validate_requirements(git_reqs)
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

      def raw_location_type_requirement(location_types, requirements)
        location_types.inject([]) do |memo, type|
          if requirements[type]
            req = requirements[type]
            req = [req] if req.is_a?(String)
            memo.concat(req)
          end
          memo
        end
      end

      def validate_requirements(reqs)
        return if reqs.nil? || reqs.empty?

        validate_location
        validate_commitish
      end

      def validate_location
        return unless location.nil? || location.empty?
        raise Minimart::Error::InvalidInventoryError,
          "'#{name}' specifies Git requirements, but does not have a location."
      end

      def validate_commitish
        return unless branches.empty? && tags.empty? && refs.empty?
        raise Minimart::Error::InvalidInventoryError,
          "'#{name}' specified Git requirements, but does not provide a branch|tag|ref"
      end

    end
  end
end
