class PlaylistWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(playlist_id)
  	playlist = Playlist.find(playlist_id)
  	
    if playlist.bandcamp?
      playlist.bandcamp_album_id = parse_bandcamp_album_id(playlist)
    elsif playlist.soundcloud?
      playlist.soundcloud_uri = resolve_soundcloud_uri(playlist)
    end

    playlist.save!
  end

  private

  def parse_bandcamp_album_id(playlist)
    bandcamp_page = HTTParty.get(playlist.link)
    parser = Nokogiri::HTML(bandcamp_page.body)
    meta_tag = parser.at("meta[property='twitter:player']")
    meta_tag.attr("content").match(/album=(\d+)/)[1]
  end

  def resolve_soundcloud_uri(playlist)
    Sensori::Soundcloud.app_client.get('/resolve', url: playlist.link).uri
  end
end
