require_relative '../wrappers/midsummers_wrapper'

class ImportTest2 < MidsummersWrapper
  def setup_test
    @json = '{"Man":[{"name":"Lysander","woman":0},{"name":"Demetrius","woman":0}],"Woman":[{"name":"Hermia","man":0},{"name":"Helena","man":1}]}'
  end
  
  def run_test
    ActiveRecordArchiver.import @json
    
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
  end
end

ImportTest2.new.run
