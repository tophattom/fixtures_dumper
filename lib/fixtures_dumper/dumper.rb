require 'active_record'

module FixturesDumper
  class Dumper

    TABLES_SKIPPED_BY_DEFAULT = %w(schema_migrations delayed_jobs)

    attr_reader :table_to_dump, :tables_skipped_by_user

    def initialize(options = {})
      @tables_skipped_by_user = options[:skip_tables] ? options[:skip_tables].split(',') : []
      @table_to_dump = options[:table_to_dump]
    end

    def dump
      return if table_to_dump && table_does_not_exist?

      puts "Dumping fixtures for following tables:\n" << actual_tables_to_dump.join(', ')

      actual_tables_to_dump.each do |table_name|
        fixture_file = fixture_file_for(table_name)
        data = data_to_dump_for(table_name)
        dump_to(fixture_file, data)
        puts "#{data.count} records dumped for #{table_name} table."
      end
    end

    private

    def table_does_not_exist?
      if connection.tables.exclude?(table_to_dump)
        puts "Table #{table_to_dump} does not exist in the database."
        return true
      end
    end

    def actual_tables_to_dump
      (tables_to_dump - total_skipped_tables).compact
    end

    def total_skipped_tables
      TABLES_SKIPPED_BY_DEFAULT + tables_skipped_by_user
    end

    def tables_to_dump
      table_to_dump ? Array.wrap(table_to_dump) : connection.tables
    end

    def data_from_table(table_name)
      model_name = table_name.singularize.camelize
      begin
        model = model_name.constantize
        model.unscoped
      rescue NameError => ex
        # Try to find the model from a namespace
        Object.constants.each do |const|
          begin
            model = "#{Kernel.const_get(const)}::#{model_name}".constantize
            return model.unscoped
          rescue Exeception
          end
        end

        # NameError will be raised if the constant for the table_name
        # is not found. This will happen with those tables for which
        # model is not defined. In this case, the table can be ignored
        # for dumping as most probably it is table generated by some
        # gem.
        puts ex.message
        []
      end
    end

    def fixture_file_for(table_name)
      "#{fixtures_path}/#{table_name}.yml"
    end

    def data_to_dump_for(table_name)
      data_to_dump = []
      data_from_table(table_name).each do |record|
        data_to_dump << { "#{table_name.singularize}_#{record.id}" => record.attributes }
      end
      data_to_dump
    end

    def dump_to(file, data)
      File.open(file, "w") do |f|
        data.each do |hash|
          f.write(sanitize_yaml(hash.to_yaml))
          f.write("\n")
        end
      end
    end

    def sanitize_yaml(yaml)
      yaml.gsub(/^---\s+/, '')
    end

    def fixtures_path
      File.join Rails.root, 'test', 'fixtures'
    end

    def connection
      @_connection ||= ActiveRecord::Base.connection
    end
  end
end
