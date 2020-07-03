class CreateIgData < ActiveRecord::Migration[6.0]
  def change
    create_table :ig_data do |t|
      t.string :code
      t.jsonb :data

      t.timestamps
    end

    add_index :ig_data, :code
  end
end
