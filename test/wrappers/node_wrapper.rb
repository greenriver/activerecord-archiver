require_relative './test_wrapper'

# Models
class Node < ActiveRecord::Base
  # has attributes :name, and :next_id
  belongs_to :next, :class_name => 'Node'
end

# Test wrapper
class NodeWrapper < TestWrapper
  def tables
    {
      :nodes => {
        :name => :string,
        :next_id => :integer
      }
    }
  end
end