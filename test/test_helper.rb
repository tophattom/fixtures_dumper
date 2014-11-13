require 'logger'
require 'yaml'
require 'rails'
require 'active_record'
require 'rake'
require 'rails/test_help'

plugin_test_dir = File.dirname(__FILE__)

ActiveRecord::Base.logger = Logger.new(plugin_test_dir + '/debug.log')

ActiveRecord::Base.configurations = YAML::load(IO.read(plugin_test_dir + '/db/database.yml'))

ActiveRecord::Base.establish_connection('sqlite3mem'.to_sym)

ActiveRecord::Migration.verbose = false

load(File.join(plugin_test_dir, '../lib', 'tasks', 'dump_fixtures.rake'))
