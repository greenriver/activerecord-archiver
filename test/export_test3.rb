require_relative './setup'

ActiveRecord::Schema.define do
  create_table :men do |t|
    t.column :name, :string
    t.column :home, :string
    t.column :woman_id, :integer
  end
  create_table :women do |t|
    t.column :name, :string
    t.column :home, :string
    t.column :man_id, :integer
  end
end

begin
  
  # model definitions
  class Man < ActiveRecord::Base
    # has attributes :name, :home, and :woman_id
    belongs_to :woman
  end
  class Woman < ActiveRecord::Base
    # has attributes :name, :home, and :man_id
    belongs_to :man
  end
  
  # create a cycle of nodes
  people = [ Man.create(:name => 'Lysander'),
             Man.create(:name => 'Demetrius'),
             Woman.create(:name => 'Hermia'),
             Woman.create(:name => 'Helena') ]
  people[0].update_attribute :woman_id, people[2].id
  people[1].update_attribute :woman_id, people[2].id
  people[2].update_attribute :man_id, people[0].id
  people[3].update_attribute :man_id, people[1].id
  
  # export
  json = ActiveRecordArchiver.export(Man => [Man.all, [:name,
                                                       [:home, 'Athens'],
                                                       [:woman, 1]]],
                                     Woman => [Woman.all, [:name,
                                                           [:home, 'Athens'],
                                                           [:man, 1]]])
  
  expected = '{"Man":[{"name":"Lysander","home":"Athens","woman":0,"woman_id":1},{"name":"Demetrius","home":"Athens","woman":0,"woman_id":1}],"Woman":[{"name":"Hermia","home":"Athens","man":0,"man_id":1},{"name":"Helena","home":"Athens","man":1,"man_id":1}]}'
  if json == expected
    puts "test passed"
  else
    puts "test failed"
    puts " expected: #{expected}"
    puts " got: #{json}"
  end
ensure
  ActiveRecord::Schema.define do
    drop_table :men
    drop_table :women
  end
end
