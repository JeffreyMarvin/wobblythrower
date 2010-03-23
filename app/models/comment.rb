class Comment < ActiveRecord::Base
  validates_presence_of :comment_text, :document_id, :node_id
end
