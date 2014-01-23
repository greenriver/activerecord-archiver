require_relative './setup'

def assert_record_matches record, hash
  hash.each_pair do |key, value|
    if record.send(key) != value
      raise " expected #{record.class}##{key} to be #{value}\n got: #{record.send(key)}"
    end
  end
end

ActiveRecord::Schema.define do
  create_table :nodes do |t|
    t.column :name, :string
    t.column :next_id, :integer
  end
end

begin
  
  # model definition
  class Node < ActiveRecord::Base
    # has attributes :name, and :next_id
    belongs_to :next, :class_name => 'Node'
  end
  
  # import node cycle
  json = '{"Node":[{"name":"a","next":1},{"name":"b","next":2},{"name":"c","next":0}]}'
  ActiveRecordArchiver.import json
  
  # test
  begin
    assert_record_matches(Node.find_by_name('a'), :next => Node.find_by_name('b'))
    assert_record_matches(Node.find_by_name('b'), :next => Node.find_by_name('c'))
    assert_record_matches(Node.find_by_name('c'), :next => Node.find_by_name('a'))
    puts "test passed"
  rescue Exception => e
    puts "test failed"
    puts e.message
  end

ensure
  ActiveRecord::Schema.define do
    drop_table :nodes
  end
end