require_relative '../wrappers/midsummers_wrapper'

class ExportTest3 < MidsummersWrapper
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
    @json ||= ActiveRecordArchiver.export(Man => [Man.all, [:name,
                                                            [:home, 'Athens'],
                                                            [:woman, 1]]],
                                          Woman => [Woman.all, [:name,
                                                                [:home, 'Athens'],
                                                                [:man, 1]]])
  end
  
  def expected
    '{"Man":[{"name":"Lysander","home":"Athens","woman":0,"woman_id":1},{"name":"Demetrius","home":"Athens","woman":0,"woman_id":1}],"Woman":[{"name":"Hermia","home":"Athens","man":0,"man_id":1},{"name":"Helena","home":"Athens","man":1,"man_id":1}]}'
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

ExportTest3.new.run
