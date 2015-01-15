require 'redcarpet'

module Minimart
  module Web
    # MarkdownParser takes a String of Markdown input, and outputs HTML
    class MarkdownParser

      def self.parse(file)
        if %[.md .markdown].include?(File.extname(file))
          return new(File.open(file).read).parse
        else
          return File.open(file).read
        end
      end

      attr_reader :raw_markdown

      def initialize(raw_markdown)
        @raw_markdown = raw_markdown
      end

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
