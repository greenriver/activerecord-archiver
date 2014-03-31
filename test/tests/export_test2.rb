require_relative '../wrappers/midsummers_wrapper'

class ExportTest2 < MidsummersWrapper
  def setup_test
    @people = [ Man.create(:name => 'Lysander'),
                Man.create(:name => 'Demetrius'),
                Woman.create(:name => 'Hermia'),
                Woman.create(:name => 'Helena') ]
    @people[0].update_attribute :woman_id, @people[2].id
    @people[1].update_attribute :woman_id, @people[2].id
    @people[2].update_attribute :man_id, @people[0].id
    @people[3].update_attribute :man_id, @people[1].id
  end
  
  def json
    @json ||= ActiveRecordArchiver.export(Man.all, Woman.all)
    @json ||= ActiveRecordArchiver.export(Man => [Man.all, [:name, :woman]],
                                          Woman => [Woman.all, [:name, :man]])
  end
  
  def expected
    '{"Man":[{"name":"Lysander","woman":0},{"name":"Demetrius","woman":0}],"Woman":[{"name":"Hermia","man":0},{"name":"Helena","man":1}]}'
  end
  
  def run_test
    if json == expected
      puts "test passed"
    else
      puts "test failed"
      puts " expected: #{expected}"
      puts " got: #{json}"
    end
  end
end

ExportTest2.new.run
