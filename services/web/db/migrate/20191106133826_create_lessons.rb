class CreateLessons < ActiveRecord::Migration[6.0]
  def change
    create_table :lessons do |t|
      t.string :name, null: false
      t.references :school_class, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_index :lessons, :created_at, order: { created_at: :desc }
    add_index :lessons, %i[school_class_id name], unique: true
  end
end
