require_relative './test_wrapper'

# Models
class Man < ActiveRecord::Base
  # has attributes :name, and :woman_id
  belongs_to :woman
end
class Woman < ActiveRecord::Base
  # has attributes :name, and :man_id
  belongs_to :man
end

# Test wrapper
class MidsummersWrapper < TestWrapper
  def tables
    {
      :men => {
        :name => :string,
        :home => :string,
        :woman_id => :integer
      },
      :women => {
        :name => :string,
        :home => :string,
        :man_id => :integer
      }
    }
  end
end