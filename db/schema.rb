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

ActiveRecord::Schema.define(version: 20141205205433) do

  create_table "build_info", force: true do |t|
    t.string   "build_machine"
    t.string   "build_user"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followings", force: true do |t|
    t.integer  "follower_id"
    t.integer  "leader_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", force: true do |t|
    t.string   "email"
    t.string   "fullname"
    t.string   "message"
    t.string   "token"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", force: true do |t|
    t.string   "title"
    t.text     "body",       limit: 255
    t.integer  "rating"
    t.integer  "user_id"
    t.integer  "video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "fullname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.boolean  "admin"
  end

  create_table "video_categories", force: true do |t|
    t.integer  "video_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "video_queue_entries", force: true do |t|
    t.integer  "video_id"
    t.integer  "user_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "cover_small_url"
    t.string   "cover_large_url"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "large_cover"
    t.string   "small_cover"
    t.string   "video_url"
    t.string   "movie_file"
  end

end
