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

ActiveRecord::Schema.define(:version => 20150530215026) do

  create_table "discussion_notifications", :force => true do |t|
    t.integer  "discussion_id", :null => false
    t.integer  "member_id",     :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "discussion_notifications", ["discussion_id"], :name => "discussion_notifications_discussion_id_fk"
  add_index "discussion_notifications", ["member_id"], :name => "discussion_notifications_member_id_fk"

  create_table "discussions", :force => true do |t|
    t.string   "subject",                           :null => false
    t.text     "body",                              :null => false
    t.text     "body_html",                         :null => false
    t.string   "slug",                              :null => false
    t.integer  "member_id",                         :null => false
    t.boolean  "members_only",   :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "attachment_url"
    t.integer  "response_count", :default => 0
    t.datetime "last_post_at"
    t.string   "category"
  end

  add_index "discussions", ["category"], :name => "index_discussions_on_category"
  add_index "discussions", ["last_post_at"], :name => "index_discussions_on_last_post_at"
  add_index "discussions", ["member_id"], :name => "discussions_member_id_fk"

  create_table "features", :force => true do |t|
    t.string   "title",       :null => false
    t.text     "description", :null => false
    t.string   "image",       :null => false
    t.string   "link",        :null => false
    t.integer  "member_id",   :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "features", ["member_id"], :name => "features_member_id_fk"

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
    t.string   "full_name"
    t.string   "city"
    t.string   "country"
    t.text     "bio"
    t.text     "bio_html"
  end

  add_index "members", ["slug"], :name => "index_members_on_slug"
  add_index "members", ["soundcloud_id"], :name => "index_members_on_soundcloud_id"

  create_table "playlists", :force => true do |t|
    t.string   "title"
    t.text     "link"
    t.integer  "bandcamp_album_id"
    t.string   "soundcloud_uri"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
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

  create_table "sessions", :force => true do |t|
    t.string   "title",                   :null => false
    t.text     "description",             :null => false
    t.string   "image",                   :null => false
    t.datetime "end_date",                :null => false
    t.string   "facebook_event_id"
    t.string   "slug",                    :null => false
    t.integer  "member_id",               :null => false
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.string   "attachment_url"
    t.string   "soundcloud_playlist_url"
    t.integer  "bandcamp_album_id"
  end

  add_index "sessions", ["member_id"], :name => "sessions_member_id_fk"

  create_table "submissions", :force => true do |t|
    t.integer  "session_id",     :null => false
    t.string   "title",          :null => false
    t.integer  "member_id",      :null => false
    t.string   "attachment_url", :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "submissions", ["member_id"], :name => "submissions_member_id_fk"

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

  create_table "tutorials", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "body_html"
    t.string   "slug"
    t.integer  "member_id"
    t.string   "youtube_id"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "featured",                  :default => false
    t.text     "body_components"
    t.boolean  "published",                 :default => false
    t.string   "attachment_url"
    t.boolean  "include_table_of_contents", :default => false
  end

  add_foreign_key "discussion_notifications", "discussions", :name => "discussion_notifications_discussion_id_fk"
  add_foreign_key "discussion_notifications", "members", :name => "discussion_notifications_member_id_fk"

  add_foreign_key "discussions", "members", :name => "discussions_member_id_fk"

  add_foreign_key "features", "members", :name => "features_member_id_fk"

  add_foreign_key "responses", "discussions", :name => "responses_discussion_id_fk"
  add_foreign_key "responses", "members", :name => "responses_member_id_fk"

  add_foreign_key "sessions", "members", :name => "sessions_member_id_fk"

  add_foreign_key "submissions", "members", :name => "submissions_member_id_fk"

  add_foreign_key "tracks", "members", :name => "tracks_member_id_fk"

end
