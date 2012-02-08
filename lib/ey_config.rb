require File.expand_path('../ey_config/local', __FILE__)

module EY
  class Config
    class << self
      PATHS_TO_CHECK = ['config/ey_services_config_deploy.yml', EY::Config::Local.config_path]

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
          ey_config_local_usage
          raise ArgumentError, "Expected to find EY::Config YAML file at: #{full_path}"
        end
        @config = YAML.load_file(full_path)
        unless valid_structure?(@config)
          ey_config_local_usage
          raise ArgumentError, "Expected YAML file at: #{full_path} to contain a hash of hashes, got: #{@config.inspect}"
        end
      end
      def get(*args)
        @args = args
        init unless @config
        hash = @config
        args.each do |arg|
          hash = hash[arg.to_s] if hash
        end
        hash.dup
      end

      private

      def ey_config_local_usage
        @args ||= []

        STDERR.puts ''
        STDERR.puts "*" * 80
        STDERR.puts "    To generate a config file for local development, run the following:"
        STDERR.puts "    $ ey_config_local #{@args.join(' ')}"
        STDERR.puts "*" * 80
        STDERR.puts ''
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
        ey_config_local_usage
        raise ArgumentError, "Expected to find EY::Config YAML file at one of: #{possible_paths.inspect}"
      end

      def valid_structure?(config)
        config.respond_to?(:has_key?) and 
            config.values.first.respond_to?(:has_key?)
      end
    end
  end
end

