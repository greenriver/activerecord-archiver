require_relative '../setup'
require 'pry'

class TestWrapper
  def assert_record_matches record, hash
    hash.each_pair do |key, value|
      if record.send(key) != value
        raise " expected #{record.class}##{key} to be #{value}\n got: #{record.send(key)}"
      end
    end
  end
  
  def setup_tables
    test_tables = tables
    ActiveRecord::Schema.define do
      test_tables.each_pair do |name, table|
        create_table name do |t|
          table.each_pair do |col, type|
            t.column col, type
          end
        end
      end
    end
  end
  
  def drop_tables
    test_tables = tables
    ActiveRecord::Schema.define do
      test_tables.keys.each do |name|
        drop_table name
      end
    end
  end
  
  def run
    setup_tables
    begin
      setup_test
      run_test
    ensure
      drop_tables
    end
  end
end