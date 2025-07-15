class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :external_id
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
