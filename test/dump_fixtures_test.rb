require 'test_helper'

class DumpFixturesTest < ActiveSupport::TestCase
  def setup
    Rake::Task.define_task(:environment)
  end

  def test_success
    assert_nothing_raised do
      Rake::Task['db:fixtures:dump'].invoke
    end
  end
end
