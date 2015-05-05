# Usage: rails runner -e [environment] "SoundcloudTrackSyncService.new.run"
#
class SoundcloudTrackSyncService
  def run
    Member.find_each do |member|
      member.sync_soundcloud_tracks
    end
  end
end