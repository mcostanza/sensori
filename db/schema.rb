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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130619032842) do

  create_table "discussions", :force => true do |t|
    t.string   "subject",                         :null => false
    t.text     "body",                            :null => false
    t.text     "body_html",                       :null => false
    t.string   "slug",                            :null => false
    t.integer  "member_id",                       :null => false
    t.boolean  "members_only", :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "discussions", ["member_id"], :name => "discussions_member_id_fk"

  create_table "members", :force => true do |t|
    t.integer  "soundcloud_id"
    t.string   "name",                                       :null => false
    t.string   "slug",                                       :null => false
    t.string   "image_url"
    t.boolean  "admin",                   :default => false
    t.string   "email"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "soundcloud_access_token"
  end

  add_index "members", ["soundcloud_id"], :name => "index_members_on_soundcloud_id"

  create_table "prelaunch_signups", :force => true do |t|
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "responses", :force => true do |t|
    t.integer  "discussion_id", :null => false
    t.text     "body",          :null => false
    t.text     "body_html",     :null => false
    t.integer  "member_id",     :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "responses", ["discussion_id"], :name => "responses_discussion_id_fk"
  add_index "responses", ["member_id"], :name => "responses_member_id_fk"

  create_table "tracks", :force => true do |t|
    t.integer  "soundcloud_id", :null => false
    t.integer  "member_id",     :null => false
    t.string   "title",         :null => false
    t.string   "permalink_url", :null => false
    t.string   "stream_url",    :null => false
    t.datetime "posted_at",     :null => false
    t.string   "artwork_url",   :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "tracks", ["member_id"], :name => "tracks_member_id_fk"
  add_index "tracks", ["posted_at"], :name => "index_tracks_on_posted_at"
  add_index "tracks", ["soundcloud_id"], :name => "index_tracks_on_soundcloud_id"

  add_foreign_key "discussions", "members", :name => "discussions_member_id_fk"

  add_foreign_key "responses", "discussions", :name => "responses_discussion_id_fk"
  add_foreign_key "responses", "members", :name => "responses_member_id_fk"

  add_foreign_key "tracks", "members", :name => "tracks_member_id_fk"

end
