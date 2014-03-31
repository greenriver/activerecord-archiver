require_relative '../wrappers/node_wrapper'

class ImportTest1 < NodeWrapper
  def setup_test
    @json = '{"Node":[{"name":"a","next":1},{"name":"b","next":2},{"name":"c","next":0}]}'
  end
  
  def run_test
    ActiveRecordArchiver.import @json
    
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
  end
end

ImportTest1.new.run