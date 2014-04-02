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
    relevant_records.present? && relevant_records.map(&:id).index(record.send(attribute).id)
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
      if (col = column(model, key))
        if col.type == :datetime and value.present?
          ret[col] = DateTime.parse(value).to_s(:db)
        else
          ret[col] = value
        end
      elsif belongs_to?(model, key)
        foreign_key = relation_foreign_key(model, key)
        if !hash.include?(foreign_key) and column_required(model, foreign_key)
          # if the foreign key is required connect it to the first available record temporarily
          ret[column(model, foreign_key)] = relation_model(model, key).first.try(:id) || 0
        end
      else
        raise "#{key} is not an attribute or belongs_to relation of #{model}"
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
    unless instance.is_a?(klass)
      raise "Object #{instance.inspect} is not an instance of the #{klass.inspect} model"
    end
  end
  
  def self.assert_model model
    unless model < ActiveRecord::Base
      raise "#{model} is not an activerecord model"
    end
  end
  
  def self.relation_from_key model, attribute
    model.reflections.values.detect{|ref| ref.foreign_key == attribute}
  end
  
  def self.parse_array_option options, key
    if options.is_a? Hash
      case options[key]
      when Array then options[key].map(&:to_s)
      when nil then []
      else [options[key].to_s] end
    else [] end
  end
  
  def self.id_warning model, col
    "Warning: #{model}##{col.name} included in export." +
      "  To exclude it use ActiveRecordArchiver.export(#{model.name.downcase.pluralize} => " +
      "{:exclude => [:#{col.name}]})"
  end
  
  def self.cols_for_model model, all_models, options={}
    model.columns.map do |col|
      if (col.primary or
          parse_array_option(options, :exclude).include? col.name)
        # omit primary keys and excluded columns
        nil
      elsif (relation = relation_from_key(model, col.name)) and relation.belongs_to?
        # include belongs_to relations to included models
        if all_models.include? relation.klass
          relation.name
        else nil end
      else
        # warn before adding an attribute ending in '_id'
        warn id_warning(model, col) if col.name =~ /_id$/
        col.name
      end
    end.compact
  end
end
