# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_03_202345) do

  create_table "positions", force: :cascade do |t|
    t.string "symbol", null: false
    t.decimal "price", default: "0.0", null: false
    t.float "quantity", default: 0.0, null: false
    t.string "currency", default: "USD", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["symbol"], name: "index_positions_on_symbol", unique: true
  end

  create_table "trades", force: :cascade do |t|
    t.string "symbol", null: false
    t.string "exchange"
    t.string "currency", default: "USD", null: false
    t.decimal "price", default: "0.0", null: false
    t.float "quantity", default: 0.0, null: false
    t.decimal "commission", default: "0.0"
    t.datetime "trade_date", null: false
    t.string "notes", limit: 2000
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
