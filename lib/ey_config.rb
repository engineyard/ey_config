module EY
  class Config
    PATH_DEFAULT = 'config/ey_config.yml'

    class << self
      def config_path=(val)
        @full_path = nil
        @config_path = val
      end

      def config_path
        @config_path ||= PATH_DEFAULT
      end

      def full_path
        @full_path ||= File.expand_path(config_path)
      end

      def init
        unless File.exists?(full_path)
          raise ArgumentError, "Expected to find EY::Config YAML file at: #{full_path}"
        end
        @config = YAML.load_file(config_path)
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

      def valid_structure?(config)
        config.respond_to?(:has_key?) and 
            config.values.first.respond_to?(:has_key?)
      end
    end
  end
end

