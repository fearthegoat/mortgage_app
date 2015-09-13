class CreatesCalculation < ActiveRecord::Migration
  def change
    create_table :calculations do |t|
      t.integer :total_calculations
      t.float :loan_amount, default: 0.0
      t.float :lowest_payment, default: 0.0
      t.float :highest_payment, default: 0.0

      t.timestamps null: false
    end
  end
end
