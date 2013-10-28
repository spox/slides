require 'guard'
require 'guard/plugin'
require 'fileutils'

module Guard

  class JsConfig < Plugin

    def start
      write
    end

    def base
      Dir.pwd
    end

    def write_path
      path = File.join(base, 'output/slide_config.js')
      unless(File.directory?(File.dirname(path)))
        FileUtils.mkdir_p(File.dirname(path))
      end
      path
    end

    def write
      val = config.dup
      val.delete_if{|k,v| !%w(settings presenters).include?(k)}
      File.open(write_path, 'w') do |f|
        f.write "var SLIDE_CONFIG = #{JSON.dump(val)};"
      end
    end

    def config
      require 'json'
      unless(@_config)
        @_config = JSON.load(
          File.read(
            File.join(base, 'config/presentation.json')
          )
        )
      end
    end

    def run_on_modification(*args)
      write
    end

  end

  class SlideAssetCopier < Plugin

    def start(paths=nil)
      update_paths(
        Dir.glob(File.join(takeoff_directory, '**', '*')).map(&:to_s)
      )
    end

    def directory_name
      'tmp'
    end

    def base_takeoff
      Dir.pwd
    end

    def base_landing
      File.join(Dir.pwd, 'output')
    end

    def takeoff_directory
      File.join(base_takeoff, directory_name)
    end

    def landing_directory
      File.join(base_landing, directory_name)
    end

    def landing_file(path)
      File.join(
        landing_directory,
        path.sub(/^(#{Regexp.escape(takeoff_directory)}|#{Regexp.escape(directory_name)})\/?/, '')
      )
    end

    def update_paths(paths)
      paths.each do |path|
        next unless File.file?(path)
        land_at = landing_file(path)
        unless(File.exists?(land_at) && FileUtils.compare_file(path, land_at))
          unless(File.directory?(File.dirname(land_at)))
            FileUtils.mkdir_p(File.dirname(land_at))
          end
          FileUtils.cp(path, land_at)
        end
      end
      paths
    end

    def run_on_modification(paths)
      update_paths(paths)
      paths
    end

    def run_on_additions(paths)
      update_paths(paths)
      paths
    end

    def run_on_removals(paths)
      paths.each do |path|
        land_at = landing_file(path)
        FileUtils.rm(land_at) if File.exists?(land_at)
      end
      paths
    end
  end

  class ImageCopier < SlideAssetCopier
    def directory_name; 'images'; end
  end

  class JsCopier < SlideAssetCopier
    def directory_name; 'js'; end
  end

  class CssCopier < SlideAssetCopier
    def directory_name; 'theme/css'; end
  end

  class SassCompiler < Plugin

    def working_directory
      Dir.pwd
    end

    def compass
      unless(@compass)
        require 'sass'
        require 'sass/plugin'
        require 'compass'
        require 'compass/actions'
        Compass.configuration do |config|
          config.http_path = '/'
          config.css_dir = 'output/theme/css'
          config.sass_dir = 'theme/scss'
          config.images_dir = 'images'
          config.javascripts_dir = 'js'
          config.output_style = :compressed
        end
      end
      @compass = Compass::Compiler.new(
        working_directory,
        Compass.configuration.sass_dir,
        Compass.configuration.css_dir,
        :sass => Compass.sass_engine_options
      )
    end

    def compile(*args)
      do_variable_updates(*args)
      compass.run
    end

    def do_variable_updates(*args)
      paths = Array(args.first).compact.flatten
      if(paths.detect{|path| path.end_with?('config/presentation.json')})
        write_variables
      end
    end

    def base
      Dir.pwd
    end

    def write_path
      path = File.join(base, 'theme/scss/_variables.scss')
      unless(File.directory?(File.dirname(path)))
        FileUtils.mkdir_p(File.dirname(path))
      end
      path
    end

    def write
      val = config.dup
      val.delete_if{|k,v| !%w(settings presenters).include?(k)}
      File.open(write_path, 'w') do |f|
        f.write "var SLIDE_CONFIG = #{JSON.dump(val)};"
      end
    end

    def config
      require 'json'
      _config = JSON.load(
        File.read(
          File.join(base, 'config/presentation.json')
        )
      )
      _config['styling'].dup
    end

    def default_config
      require 'json'
      JSON.load(File.read(File.join(base, 'theme/scss/variable_defaults.json')))
    end

    def write_variables
      File.open(File.join(base, 'theme/scss/_variables.scss'), 'w') do |f|
        default_config.merge(config).each do |k,v|
          f.puts "$#{k}: #{v};"
        end
      end
    end

    def start(*args)
      compile
      write_variables
    end

    def run_on_modification(paths)
      compile
    end

    def run_on_additions(paths)
      compile
    end

    def run_on_removals(paths)
      compile
    end

  end

  class HamlCompiler < Plugin

    class CompileIn
      def method_missing(*args)
        nil
      end
    end

    def base
      Dir.pwd
    end

    def config
      require 'json'
      unless(@_config)
        @_config = JSON.load(
          File.read(
            File.join(base, 'config/presentation.json')
          )
        )['layouts']
      end
      @_config
    end

    def haml
      require 'haml'
      load_content
      Haml::Engine.new(
        File.read(File.join(base, 'templates', "#{@template || 'base'}.haml"))
      ).render(CompileIn.new, config.merge(:slides => @slides))
    end

    def load_content
      @slides = Dir.glob(
        File.join(base, 'content', '**', '*.haml')
      ).map do |path|
        Haml::Engine.new(
          File.read(path)
        ).render(binding)
      end
    end

    def compile
      File.open(File.join(base, 'output', 'index.html'), 'w') do |f|
        f.write haml
      end
    end

    def start(*args)
      compile
    end

    def run_on_modification(paths)
      compile
    end

    def run_on_additions(paths)
      compile
    end

    def run_on_removals(paths)
      compile
    end

  end
end
