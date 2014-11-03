$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

require 'active_record'
require 'active_record/bit_field'
require 'support/dummy'

RSpec.configure do |config|
  config.before(:each) do
    Dummy.delete_all
    DummyInvert.delete_all
  end
end
