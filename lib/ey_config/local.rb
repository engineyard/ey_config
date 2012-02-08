require 'fileutils'

module EY
  class Config
    class Local
      class << self
        def config_path
          'config/ey_services_config_local.yml'
        end

        def generate(*args)
          contents = existing_contents
          contents = {} unless contents.is_a?(Hash)
          tmp = contents
          
          args[0 ... -1].each do |arg|
            tmp[arg] ||= {}
            tmp = tmp[arg]
          end
          tmp[args.last] = 'SAMPLE'

          FileUtils.mkdir_p('config')
          File.open(config_path, 'w') do |f|
            f.print YAML.dump(contents)
          end
        end

        def existing_contents
          YAML.load_file(config_path)
        rescue Errno::ENOENT
          {}
        end
      end
    end
  end
end
