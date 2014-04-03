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
  def self.export *args
    
    @models_hash = models_hash_from_args(args)
    
    result = {}
    
    # serialize
    @models_hash.each_pair do |model, (records, attributes)|
      next unless records.compact.present?
      result[model.to_s] = []
      [*records].each do |record|
        
        assert_instance_of record, model
        
        rec = {}
        attributes.each do |attribute|
          attribute, placeholder = if attribute.is_a? Array
                                   then attribute
                                   else [attribute, nil] end
          
          if has_attribute? model, attribute
            # store attribute
            rec[attribute] = if placeholder.nil?
                             then record.send attribute
                             else placeholder end
          elsif belongs_to?(model, attribute)
            # store relation
            if (index = relation_index(record, attribute))
              rec[attribute] = index
              if placeholder
                rec[relation_foreign_key(model, attribute)] = placeholder
              end
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
  
  def self.models_hash_from_args args
    options = args.extract_options!
    args.each do |arg|
      options[arg] = :all
    end
    
    options.keys.each do |collection|
      if collection.is_a? ActiveRecord::Base
        options[[collection]] = options[collection]
        options.delete(collection)
      elsif !collection.compact.present?
        options.delete(collection)
      end
    end
    
    models = options.keys.map do |collection|
      collection.first.class.base_class
    end
    
    models_hash = {}
    
    options.each_pair do |collection, cols|
      models_hash[collection.first.class.base_class] =
        [collection,
         if cols.is_a? Array then cols
         elsif cols == :all or cols.is_a? Hash
           cols_for_model(collection.first.class, models, cols)
         else
           raise "unknown column specification: #{cols}"
         end]
    end
    
    models_hash
  end
end
