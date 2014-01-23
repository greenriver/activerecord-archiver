require_relative './setup'

def assert_record_matches record, hash
  hash.each_pair do |key, value|
    if record.send(key) != value
      raise " expected #{record.class}##{key} to be #{value}\n got: #{record.send(key)}"
    end
  end
end

ActiveRecord::Schema.define do
  create_table :men do |t|
    t.column :name, :string
    t.column :woman_id, :integer
  end
  create_table :women do |t|
    t.column :name, :string
    t.column :man_id, :integer
  end
end

begin
  
  # model definitions
  class Man < ActiveRecord::Base
    # has attributes :name, and :woman_id
    belongs_to :woman
  end
  class Woman < ActiveRecord::Base
    # has attributes :name, and :man_id
    belongs_to :man
  end
  
  # import node cycle
  json = '{"Man":[{"name":"Lysander","woman":0},{"name":"Demetrius","woman":0}],"Woman":[{"name":"Hermia","man":0},{"name":"Helena","man":1}]}'
  ActiveRecordArchiver.import json
  
  # test
  begin
    assert_record_matches(Man.find_by_name('Lysander'), :woman => Woman.find_by_name('Hermia'))
    assert_record_matches(Man.find_by_name('Demetrius'), :woman => Woman.find_by_name('Hermia'))
    assert_record_matches(Woman.find_by_name('Hermia'), :man => Man.find_by_name('Lysander'))
    assert_record_matches(Woman.find_by_name('Helena'), :man => Man.find_by_name('Demetrius'))
    puts "test passed"
  rescue Exception => e
    puts "test failed"
    puts e.message
  end

ensure
  ActiveRecord::Schema.define do
    drop_table :men
    drop_table :women
  end
end