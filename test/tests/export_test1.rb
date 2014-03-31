require_relative '../wrappers/node_wrapper'

class ExportTest1 < NodeWrapper
  def setup_test
    # create a cycle of nodes
    @nodes = [ Node.create(:name => 'a'),
               Node.create(:name => 'b'),
               Node.create(:name => 'c') ]
    @nodes[0].update_attribute :next_id, @nodes[1].id
    @nodes[1].update_attribute :next_id, @nodes[2].id
    @nodes[2].update_attribute :next_id, @nodes[0].id
  end
  
  def json
    @json ||= ActiveRecordArchiver.export Node => [@nodes, [:name, :next]]
  end
  
  def expected
    '{"Node":[{"name":"a","next":1},{"name":"b","next":2},{"name":"c","next":0}]}'
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

ExportTest1.new.run
