require 'spec_helper'
require 'rspec/rails'
require 'shoulda/matchers'
require File.expand_path('../config/environment', __dir__)

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  
  config.use_transactional_fixtures = true
  
  config.before(:each) do
    Payment.delete_all
    Client.delete_all
    Product.delete_all
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end