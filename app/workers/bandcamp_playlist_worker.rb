class BandcampPlaylistWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(playlist_id)
  	playlist = Playlist.find(playlist_id)
  	
    bandcamp_page = HTTParty.get(playlist.link)
    parser = Nokogiri::HTML(bandcamp_page.body)
    meta_tag = parser.at("meta[property='twitter:player']")
    bandcamp_album_id = meta_tag.attr("content").match(/album=(\d+)/)[1]

    playlist.bandcamp_album_id = bandcamp_album_id
    playlist.save!
  end
end
