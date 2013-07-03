class MemberTrackSyncWorker
  include Sidekiq::Worker

  def perform(member_id)
    Member.find(member_id).sync_soundcloud_tracks
  end

end