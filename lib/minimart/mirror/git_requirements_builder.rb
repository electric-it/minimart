require 'minimart/inventory_requirement/git_requirement'

module Minimart
  module Mirror
    # This class is used to parse any Git requirements specified in the inventory
    # and build Minimart::Inventory::GitRequirements from them.
    class GitRequirementsBuilder

      # @return [String] the name of the cookbook defined by this requirement.
      attr_reader :name

      # @return [String] the location to fetch this cookbook from.
      attr_reader :location

      # @return [Array<String>] a listing of branches to checkout when fetching this cookbook.
      attr_reader :branches

      # @return [Array<String>] a listing of tags to checkout when fetching this cookbook.
      attr_reader :tags

      # @return [Array<String>] a listing of refs to checkout when fetching this cookbook.
      attr_reader :refs

      # @param [String] name The name of the cookbook defined by this requirement.
      # @param [Hash] reqs
      #   * 'git' [Hash] The git specific requirements for this cookbook
      #     * 'branches' [Array<String>] A listing of branches to checkout when fetching this cookbook.
      #     * 'branch' [String] A single branch to checkout when fetching this cookbook.
      #     * 'tags' [Array<String>] A listing of tags to checkout when fetching this cookbook.
      #     * 'tag' [String] A single tag to checkout when fetching this cookbook.
      #     * 'refs' [Array<String>] A listing of ref to checkout when fetching this cookbook.
      #     * 'ref' [String] A single ref to checkout when fetching this cookbook.
      def initialize(name, reqs)
        @name     = name
        git_reqs  = reqs.fetch('git', {})

        @location = git_reqs['location']
        @branches = raw_location_type_requirement(%w[branches branch], git_reqs)
        @tags     = raw_location_type_requirement(%w[tags tag], git_reqs)
        @refs     = raw_location_type_requirement(%w[refs ref], git_reqs)

        validate_requirements(git_reqs)
      end

      # Build the git requirements.
      # @return [Array<Minimart::InventoryRequirement::GitRequirement>]
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
