class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.text :comment_text
      t.int :document_id
      t.int :node_id

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
