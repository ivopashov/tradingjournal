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

ActiveRecord::Schema.define(version: 2022_01_05_164238) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "heat_maps", id: :string, force: :cascade do |t|
    t.string "tickers", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_heat_maps_on_user_id"
  end

  create_table "price_alerts", force: :cascade do |t|
    t.string "name", null: false
    t.string "ticker", null: false
    t.string "comparison_operator", null: false
    t.decimal "price", null: false
    t.boolean "triggered", default: false
    t.datetime "triggered_on"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ticker", "triggered"], name: "index_price_alerts_on_ticker_and_triggered"
    t.index ["user_id", "triggered"], name: "index_price_alerts_on_user_id_and_triggered"
    t.index ["user_id"], name: "index_price_alerts_on_user_id"
  end

  create_table "stock_snapshots", force: :cascade do |t|
    t.string "ticker", null: false
    t.datetime "timestamp", null: false
    t.decimal "close", default: "0.0"
    t.decimal "volume", default: "0.0"
    t.decimal "open", default: "0.0"
    t.decimal "high", default: "0.0"
    t.decimal "low", default: "0.0"
    t.decimal "sma20", default: "0.0"
    t.decimal "sma50", default: "0.0"
    t.decimal "sma200", default: "0.0"
    t.decimal "volume50", default: "0.0"
    t.float "rsi", default: 0.0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "date", null: false
    t.index ["ticker", "date"], name: "index_stock_snapshots_on_ticker_and_date"
    t.index ["ticker", "timestamp"], name: "index_stock_snapshots_on_ticker_and_timestamp", unique: true
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
    t.string "trade_id"
    t.string "platform"
    t.boolean "is_imported", default: false, null: false
    t.integer "user_id"
    t.index ["trade_id", "platform"], name: "index_trades_on_trade_id_and_platform", unique: true
    t.index ["user_id"], name: "index_trades_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
