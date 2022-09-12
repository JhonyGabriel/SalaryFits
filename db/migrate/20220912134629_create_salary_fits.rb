class CreateSalaryFits < ActiveRecord::Migration[7.0]
  def change
    create_table :salary_fits do |t|
      t.string :name
      t.string :idade
      t.text :descricao

      t.timestamps
    end
  end
end
