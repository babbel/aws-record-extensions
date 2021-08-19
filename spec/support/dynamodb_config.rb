require 'yaml'

module DynamodbConfig
  class << self
    def client_options
      # keys must be symbols, aws-record does not accept strings
      {
        endpoint: config["endpoint"],
        region: config["region"]
      }
    end

    private

    def config
      @config ||= YAML.load(File.read(File.join(__dir__, 'dynamodb.yml')))
    end
  end
end
