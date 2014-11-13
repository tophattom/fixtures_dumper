require 'active_record'

namespace :db do
  namespace :fixtures do

    desc "Dump data from database to fixtures"
    task :dump => :environment do

      SYSTEM_EXCLUDED_TABLES = %w(schema_migrations delayed_jobs)
      USER_EXCLUDED_TABLES = ENV['EXCLUDED_TABLES']
      ALL_EXCLUDED_TABLES = [ SYSTEM_EXCLUDED_TABLES, USER_EXCLUDED_TABLES].flatten.compact

      fixtures_path = ActiveRecord::Tasks::DatabaseTasks.fixtures_path

      connection = ActiveRecord::Base.connection

      if ENV['TABLE'] && connection.tables.exclude?(ENV['TABLE'])
        puts "Table #{ENV['TABLE']} does not exist in the database."
        exit
      end

      if ENV['TABLE'] && connection.tables.include?(ENV['TABLE'])
        tables = Array.wrap ENV['TABLE']
      else
        tables = connection.tables
      end

      actual_tables = tables - ALL_EXCLUDED_TABLES

      puts "Dumping fixtures for following tables:\n" << actual_tables.join(", ")

      actual_tables.each do |table|
        begin
          model = table.singularize.camelize.constantize
          data = model.unscoped

          result = []

          if data.count > 0
            data.each do |record|
              result << { "#{table.singularize}_#{record.id}" => record.attributes }
            end

            fixture_file = fixtures_path + "/#{table}.yml"

            puts "Dumping #{data.count} records in #{table}.yml"

            File.open(fixture_file, "w") do |f|
              result.each do |hash|
                f.write(hash.to_yaml.gsub(/^---\s+/,''))
              end
            end

          else
            puts "Table #{table} has 0 records."
          end
        rescue NameError => ex
          puts ex.message
          next
        end
      end
    end

    private

    def connection
      ActiveRecord::Base.connection
    end

  end
end
