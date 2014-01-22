require_relative './setup'

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
  
  # create a cycle of nodes
  nodes = [ Node.create(:name => 'a'),
            Node.create(:name => 'b'),
            Node.create(:name => 'c') ]
  nodes[0].update_attribute :next_id, nodes[1].id
  nodes[1].update_attribute :next_id, nodes[2].id
  nodes[2].update_attribute :next_id, nodes[0].id
  
  # export
  json = ActiveRecordArchiver.export Node => [nodes, [:name, :next]]
  
  expected = '{"Node":[{"name":"a","next":1},{"name":"b","next":2},{"name":"c","next":0}]}'
  if json == expected
    puts "test passed"
  else
    puts "test failed"
    puts " expected: #{expected}"
    puts " got: #{json}"
  end

ensure
  ActiveRecord::Schema.define do
    drop_table :nodes
  end
end