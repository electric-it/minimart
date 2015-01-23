require "bundler/gem_tasks"
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
rescue LoadError
  # no rspec available
end

namespace :web do
  ROOT        = Pathname.new(File.dirname(__FILE__))
  RAW_WEB_DIR = ROOT.join('web', '_assets')
  WEB_DIR     = ROOT.join('web', 'assets')

  desc 'Compile assets'
  task :compile => [:compile_js, :compile_css]

  task :compile_js do
    require 'sprockets'
    require 'uglifier'

    puts 'Compiling JS...'
    js_dir = WEB_DIR.join('javascripts')
    FileUtils.mkdir_p(js_dir)
    sprockets = Sprockets::Environment.new(ROOT)
    sprockets.js_compressor  = :uglify
    sprockets.append_path(RAW_WEB_DIR.join('javascripts'))
    sprockets['manifest.js'].write_to(js_dir.join('application.min.js'))
    puts 'Done Compiling JS...'
  end

  task :compile_css do
    require 'sprockets'
    require 'sass'

    puts 'Compiling CSS...'
    css_dir = WEB_DIR.join('stylesheets')
    FileUtils.mkdir_p(css_dir)
    sprockets = Sprockets::Environment.new(ROOT)
    sprockets.css_compressor  = :sass
    sprockets.append_path(RAW_WEB_DIR.join('stylesheets'))
    sprockets['manifest.css'].write_to(css_dir.join('application.min.css'))
    puts 'Done Compiling CSS...'
  end
end
