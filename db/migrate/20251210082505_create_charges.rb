class CreateCharges < ActiveRecord::Migration[8.0]
  def change
    create_table :charges do |t|
      t.string :external_id
      t.integer :amount_cents
      t.string :currency
      t.timestamps
    end
    add_index :charges, :external_id, unique: true
  end
end
