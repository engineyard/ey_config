module EY
  class Config
    class << self
      PATHS_TO_CHECK = ['config/ey_config_deploy.yml', 'config/ey_config_local.yml']

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
          raise ArgumentError, "Expected to find EY::Config YAML file at: #{full_path}"
        end
        @config = YAML.load_file(full_path)
        unless valid_structure?(@config)
          raise ArgumentError, "Expected YAML file at: #{full_path} to contain a hash of hashes, got: #{@config.inspect}"
        end
      end
      def get(*args)
        init unless @config
        hash = @config
        args.each do |arg|
          hash = hash[arg.to_s] if hash
        end
        hash.dup
      end

      private

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
        config.respond_to?(:has_key?) and 
            config.values.first.respond_to?(:has_key?)
      end
    end
  end
end

