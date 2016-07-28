class CreateSprites < ActiveRecord::Migration[5.0]
  def change
    create_table :sprites do |t|
      t.text :content
      t.references :word, foreign_key: true

      t.timestamps
    end
  end
end
