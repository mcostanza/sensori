# Usage: rails runner -e [environment] "SoundcloudTrackSyncService.new.run"
#
class SoundcloudTrackSyncService
  def run
  	errors = []
    
    Member.find_each do |member|
    	begin
      	member.sync_soundcloud_tracks
      rescue SoundCloud::ResponseError => ex
      	errors << ["#{ex.class} - #{ex.message} - #{member.inspect}"]
      end
    end

    raise errors.join("\n") if errors.any?
  end
end