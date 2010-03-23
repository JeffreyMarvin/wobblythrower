class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.text :comment_text
      t.integer :document_id
      t.text :node_id

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
