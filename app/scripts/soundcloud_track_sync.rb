# Usage: rails runner -e [environment] "SoundcloudTrackSync.run"
#
class SoundcloudTrackSync
  def self.run
    Member.find_each do |member|
      member.sync_soundcloud_tracks
    end
  end
end