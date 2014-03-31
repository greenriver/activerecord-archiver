class ActiveRecordArchiver
  def self.has_attribute? model, attribute
    model.columns_hash.with_indifferent_access.has_key? attribute
  end
  
  def self.relation model, attribute
    model.reflections.with_indifferent_access[attribute]
  end
  
  def self.relation_model model, attribute
    relation(model, attribute).class_name.constantize
  end
  
  def self.belongs_to? model, attribute
    !!relation(model, attribute).try(:belongs_to?)
  end
  
  def self.column model, attribute
    model.columns_hash.with_indifferent_access[attribute]
  end
  
  def self.column_required model, attribute
    column(model, attribute).null == false
  end
  
  def self.relation_index record, attribute
    relevant_records = @models_hash[relation_model(record.class, attribute)].first
    relevant_records.present? && relevant_records.index(record.send(attribute))
  end
  
  def self.relation_id model, key, value
    relation_model_name = relation(model, key).class_name
    @data[relation_model_name][value][:id]
  end
  
  def self.relation_foreign_key model, key
    relation(model, key).foreign_key
  end
  
  def self.insertable_hash model, hash
    ret = {}
    hash.each_pair do |key, value|
      if column(model, key)
        ret[column(model, key)] = value
      elsif belongs_to?(model, key)
        foreign_key = relation_foreign_key(model, key)
        if !hash.include?(foreign_key) and column_required(model, foreign_key)
          # if the foreign key is required connect it to the first available record temporarily
          ret[column(model, foreign_key)] = relation_model(model, key).first.id
        end
      else
        raise "#{attribute} is not an attribute or belongs_to relation of #{model}"
      end
    end
    ret
  end
  
  def self.relations_update_hash(model, record)
    ret = {}
    record.each_pair do |key, value|
      if belongs_to?(model, key)
        ret[relation_foreign_key(model, key)] = relation_id(model, key, value)
      end
    end
    ret.presence
  end
  
  def self.assert_instance_of instance, klass
    unless instance.class <= klass
      raise "Object #{instance} is not an instance of the #{klass} model"
    end
  end
  
  def self.assert_model model
    unless model < ActiveRecord::Base
      raise "#{model} is not an activerecord model"
    end
  end
end