require 'fileutils'

require 'sc_docs/server'

module ScDocs
  class Generator

    attr_reader :input_dir

    attr_reader :output_dir

    attr_reader :template

    attr_reader :verbose

    def initialize(options={})
      @input_dir  = File.expand_path(options[:input_dir])
      @output_dir = File.expand_path(options[:output_dir])
      @verbose    = options[:verbose]
    end

    def command
      @command ||= begin
        run_js_path = File.expand_path("../../../vendor/jsdoc/app/run.js", __FILE__)
        command = "#{run_js_path} -apsv -r=20 -t=\"#{template}\" \"#{input_dir}\" -d=\"#{output_dir}\" -f=class.js -l=Docs.Class"
      end
    end

    def generate
      prep
      run_command
    end

    def preview
      prep
      run_command
      run_server
    end

    private

      def prep
        FileUtils.rm_rf output_dir
        FileUtils.mkdir_p File.dirname(output_dir)
      end

      def run_command
        puts "#{command}\n\n" if verbose
        verbose ? system(command) : `#{command}`

        copy_files

        puts "Finished Building\n\n"
      end

      def copy_files
        # Copy other files to output
        path = File.join(template, "output")
        if File.directory?(path)
          puts "Copying additional files" if verbose
          Dir["#{path}/*"].each{|p| FileUtils.cp_r(p, output_dir) }
        end
      end
      
      def run_server
        Server.new(output_dir).start
      end

  end

  class HtmlGenerator < Generator

    def initialize(options={})
      super
      @template = File.expand_path(options[:template])
    end

  end

  class ScGenerator < Generator

    attr_reader :app_dir
    
    attr_reader :project_name

    def initialize(options={})
      super
      @template = File.expand_path("../templates/sc_fixture", __FILE__)
      @app_dir    = File.expand_path(options[:output_dir])
      @output_dir = File.join(@app_dir, "apps", "docs", "fixtures")
      @project_name = options[:project_name] || "docs_viewer"
    end

    def generate
      prep
      run_command
      deploy
    end

    private

      def prep
        target_dir = File.dirname(app_dir)
        FileUtils.rm_rf app_dir
        FileUtils.mkdir_p target_dir
        FileUtils.cp_r File.expand_path("../docs", __FILE__), target_dir
      end

      def run_server
        # TODO: Run SC Inline
        Dir.chdir app_dir
        system("sc-server --port=9292")
      end

      def deploy
        require 'tempfile' # For Dir.tmpdir

        tmp_path = File.join(Dir.tmpdir, "docs#{rand(100000)}")

        FileUtils.mv app_dir, tmp_path
        
        Dir.chdir tmp_path

        build_cmd = "sc-build -r --languages=en --build-targets=docs --build=#{project_name}"
        
        puts "Deploying...\n\n"

        puts "#{build_cmd}\n\n" if verbose
        verbose ? system(build_cmd) : `#{build_cmd}`

        FileUtils.rm_rf app_dir
        FileUtils.mkdir_p app_dir

        docs_dir = File.join(app_dir, "sc_docs")
        FileUtils.cp_r File.join(tmp_path, "tmp", "build", "sc_docs"), docs_dir
        FileUtils.cp File.join(docs_dir, "docs", "en", project_name, "index.html"), docs_dir

        puts "Deployed"

      ensure
        FileUtils.rm_rf tmp_path
      end
  
  end
end