require 'rails'
require 'rake'
require 'rails/test_help'
require 'fixtures_dumper'

class DumpFixturesTest < ActiveSupport::TestCase

  def test_success
    assert_nothing_raised do
      Rake::Task['db:fixtures:dump'].invoke
    end
  end

end
