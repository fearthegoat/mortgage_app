class CreatesRateTable < ActiveRecord::Migration
  def change
    create_table :rates do |t|
      t.integer :term
      t.float :initial_rate
      t.float :max_rate_adjustment_period, default: 0
      t.float :max_rate_adjustment_term, default: 0
      t.integer :years_before_first_adjustment, default: 0
      t.integer :years_between_adjustments, default: 0
      t.boolean :adjustable_rate?, default: false
      t.timestamps null: false
    end
  end
end
