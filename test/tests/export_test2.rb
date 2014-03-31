require_relative '../wrappers/midsummers_wrapper'

class ExportTest2 < MidsummersWrapper
  def setup_test
    @lysander = Man.create(:name => 'Lysander')
    @demetrius = Man.create(:name => 'Demetrius')
    @hermia = Woman.create(:name => 'Hermia')
    @helena = Woman.create(:name => 'Helena')
    @lysander.update_attribute :woman_id, @hermia.id
    @demetrius.update_attribute :woman_id, @hermia.id
    @hermia.update_attribute :man_id, @lysander.id
    @helena.update_attribute :man_id, @demetrius.id
  end
  
  def json
    @json ||= ActiveRecordArchiver.export(Man.all, Woman.all)
  end
  
  def expected
    '{"Man":[{"name":"Lysander","home":null,"woman":0},{"name":"Demetrius","home":null,"woman":0}],"Woman":[{"name":"Hermia","home":null,"man":0},{"name":"Helena","home":null,"man":1}]}'
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
