=begin

method ActiveRecordArchiver::export

Arguments:
  A hash with ActiveRecord Model classes as keys and Array pairs for values.
  The first element of each value is an iterable of ActiveRecord Record instances and
  the second element of each value is an iterable of attribute keys and belongs_to relations.
  Whenever a belongs relation is specified ActiveRecordArchiver will check whether the related
  record is also included in this export and raise an Exception if it is not.
  If it is included then it will be specified in the output as an index into the relevant array.

Returns:
  A string of serialized JSON that contains the specified data including relations

Example:
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
  
  # json is '{"Node":[{"name":"a","next":1},{"name":"b","next":2},{"name":"c","next":0}]}'

=end

class ActiveRecordArchiver
  def self.export models_hash
    
    result = {}
    
    # serialize
    models_hash.each_pair do |model, pair|
      records, attributes = pair
      
      result[model.to_s] = []
      records.each do |record|
        
        assert_instance_of record, model
        
        attrs = record.attributes.with_indifferent_access
        relations = model.reflections.with_indifferent_access
        rec = {}
        attributes.each do |attribute|
          
          if attrs[attribute]
            # store attribute
            rec[attribute] = attrs[attribute]
          elsif relations[attribute].try(:belongs_to?)
            # store relation
            relevant_records = models_hash[relations[attribute].class_name.constantize].first
            index = relevant_records.present? && relevant_records.index(record.send(attribute))
            if index
              rec[attribute] = index
            else
              raise "#{record} belongs_to #{attribute} which is not included in the export"
            end
          else
            raise "#{attribute} is not an attribute or belongs_to relation of #{model}"
          end
        end
        result[model.to_s] << rec
      end
    end
    
    # encode
    JSON.dump result
  end
  
  private
  
  def self.assert_instance_of instance, klass
    if instance.class != klass
      raise "Object #{instance} is not an instance of the #{klass} model"
    end
  end
end