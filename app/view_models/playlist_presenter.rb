class PlaylistPresenter
	attr_accessor :playlist

	def initialize(playlist)
		@playlist = playlist
	end

	def partial
		case 
		when @playlist.bandcamp?
			"/playlists/bandcamp"
		when @playlist.soundcloud?
			"/playlists/soundcloud"
		end
	end
end