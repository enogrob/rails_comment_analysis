class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.integer :external_id
      t.text :body
      t.string :state
      t.text :translated_body
      t.boolean :approved

      t.timestamps
    end
  end
end
