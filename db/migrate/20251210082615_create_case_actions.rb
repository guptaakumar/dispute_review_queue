class CreateCaseActions < ActiveRecord::Migration[8.0]
  def change
    create_table :case_actions do |t|
      t.references :dispute, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.string :action
      t.text :note
      t.jsonb :details
      t.timestamps
    end
  end
end
