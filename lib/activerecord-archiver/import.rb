=begin

method ActiveRecordArchiver::import

Arguments:
  A string of JSON generated by ActiveRecordArchiver::export

Returns:
  true on success, raises an Exception and rolls back the db on failure

Effects:
  Attempts to create and save a new record for each item in the input JSON structure and
  connects the specified belongs_to relations

=end

class ActiveRecordArchiver
  def self.import json
    
    @data = JSON.parse json
    
    ActiveRecord::Base.transaction do
      
      # insert records
      @data.each_pair do |model_name, records|
        model = model_name.constantize
        
        assert_model model
        
        records.each do |record|
          record[:id] = model.all.insert(insertable_hash(model, record))
        end
      end
      
      # add relations
      @data.each_pair do |model_name, records|
        model = model_name.constantize
        
        records.each do |record|
          if (update_hash = relations_update_hash(model, record))
            model.where(:id => record[:id]).update_all(update_hash)
          end
        end
      end
      
    end
    
    true
  end
end