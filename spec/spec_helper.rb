require 'bundler/setup'
require 'aws-record-cleaner'
require 'byebug'
require 'active_model'
require 'aws-record-extensions'

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require_relative f }

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    LocalStorage.create_tables!
  end

  config.after(:suite) do
    LocalStorage.drop_tables!
  end

  AwsRecordCleaner::DbCleaner.initialize_model_tracking

  config.around do |example|
    AwsRecordCleaner::DbCleaner.cleaning do
      example.run
    end
  end
end
