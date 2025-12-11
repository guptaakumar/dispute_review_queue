class CreateDisputes < ActiveRecord::Migration[8.0]
  def change
    create_table :disputes do |t|
      t.references :charge, null: false
      t.string :external_id, null: false
      t.string :status
      t.datetime :opened_at
      t.datetime :closed_at
      t.integer :amount_cents
      t.string :currency
      t.jsonb :external_payload
      t.index :external_id, unique: true # Enforce uniqueness [cite: 66]
      t.timestamps
    end
  end
end
