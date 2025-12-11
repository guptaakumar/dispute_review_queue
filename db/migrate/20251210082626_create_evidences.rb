class CreateEvidences < ActiveRecord::Migration[8.0]
  def change
    create_table :evidences do |t|
      t.references :dispute, null: false, foreign_key: true
      t.string :kind
      t.jsonb :metadata

      t.timestamps
    end
  end
end
