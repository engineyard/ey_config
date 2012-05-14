require File.expand_path('../ey_config/local', __FILE__)

module EY
  class Config
    class << self
      DEPLOYED_CONFIG_PATH = 'config/ey_services_config_deploy.yml'
      PATHS_TO_CHECK = [DEPLOYED_CONFIG_PATH, EY::Config::Local.config_path]

      def config_path=(val)
        @full_path = nil
        @config_paths = [val]
      end

      def config_paths
        @config_paths ||= PATHS_TO_CHECK
      end

      def full_path
        @full_path ||= find_config(config_paths)
      end

      def init
        unless File.exists?(full_path)
          err_msg = ""
          if detected_a_dev_environment?
            ey_config_local_usage
            err_msg = "Expected to find EY::Config YAML file at: #{EY::Config::Local.config_path}"
          else
            err_msg = "Expected to find EY::Config YAML file at: #{DEPLOYED_CONFIG_PATH}"
          end
          warn err_msg
          raise ArgumentError, err_msg
        end
        @config = YAML.load_file(full_path)
        unless valid_structure?(@config)
          ey_config_empty_warning(full_path, @config)
        end
      end

      def get(*args)
        @args = args
        init unless @config
        hash = @config.dup
        args.each do |arg|
          hash = hash[arg.to_s] if hash
        end
        if hash.nil?
          err_message = "No config found for #{args.inspect}. "
          if detected_a_dev_environment?
            err_message += "You can put development/fallback configs in: #{EY::Config::Local.config_path}"
          else
            err_message += "Activate the services that provides '#{args.first}' or remove the code that uses it."
          end
          warn err_message
          raise ArgumentError, err_message
        end
        hash.freeze
      end

      private

      def detected_a_dev_environment?
        env = ENV['RAILS_ENV'] || ENV['RACK_ENV']
        !env || env.to_s.match(/test|development/i)
      end

      def warn(arg)
        STDERR.puts arg
      end

      def ey_config_empty_warning(full_path, config)
        warn ''
        warn "*" * 80
        warn "    Expected YAML file at: #{full_path} to contain a hash of hashes, got: #{config.inspect}"
        warn "*" * 80
        warn ''
      end

      def ey_config_local_usage
        @args ||= []

        warn ''
        warn "*" * 80
        warn "    To generate a config file for local development, run the following:"
        warn "    $ ey_config_local #{@args.join(' ')}"
        warn "*" * 80
        warn ''
      end

      def find_config(config_paths)
        possible_paths = []
        config_paths.each do |config_path|
          possible_path = File.expand_path(config_path)
          possible_paths << possible_path
          if File.exists?(possible_path)
            return possible_path
          end
        end
        raise ArgumentError, "Expected to find EY::Config YAML file at one of: #{possible_paths.inspect}"
      end

      def valid_structure?(config)
        config == {} or
          (config.respond_to?(:has_key?) and
            config.values.first.respond_to?(:has_key?))
      end
    end
  end
end

