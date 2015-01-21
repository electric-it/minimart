require 'redcarpet'

module Minimart
  module Web
    # MarkdownParser takes a String of Markdown input, and outputs HTML
    class MarkdownParser

      # Parse a file as Markdown. If the file does not contain Markdown, it's
      # contents will be returned.
      # @param [String] file The file to parse
      # @return [String] The parsed Markdown content.
      def self.parse(file)
        if %[.md .markdown].include?(File.extname(file))
          return new(File.open(file).read).parse
        else
          return File.open(file).read
        end
      end

      # @return [String] raw Markdown to parse
      attr_reader :raw_markdown

      # @param [String] raw_markdown Raw Markdown to parse
      def initialize(raw_markdown)
        @raw_markdown = raw_markdown
      end

      # Parse the Markdown contents!
      # @return [String] The parsed Markdown content.
      def parse
        renderer.render(raw_markdown)
      end

      private

      def renderer
        Redcarpet::Markdown.new(Redcarpet::Render::HTML,
          no_intra_emphasis: true,
          fenced_code_blocks: true,
          autolink: true,
          tables: true,
          link_attributes: {target: '_blank'})
      end

    end
  end
end
