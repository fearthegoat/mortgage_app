# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151009034152) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calculations", force: :cascade do |t|
    t.integer  "total_calculations"
    t.float    "loan_amount",        default: 0.0
    t.float    "lowest_payment",     default: 0.0
    t.float    "highest_payment",    default: 0.0
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "rates", force: :cascade do |t|
    t.integer  "term"
    t.float    "initial_rate"
    t.float    "max_rate_adjustment_period",    default: 0.0
    t.float    "max_rate_adjustment_term",      default: 0.0
    t.integer  "years_before_first_adjustment", default: 0
    t.integer  "years_between_adjustments",     default: 0
    t.boolean  "adjustable_rate?",              default: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

end
