class PlaylistsController < ApplicationController
  before_filter :ensure_admin

  # GET /playlists
  def index
    @playlists = Playlist.all
  end

  # GET /playlists/1
  def show
    @playlist = Playlist.find(params[:id])
  end

  # GET /playlists/new
  def new
    @playlist = Playlist.new
  end

  # GET /playlists/1/edit
  def edit
    @playlist = Playlist.find(params[:id])
  end

  # POST /playlists
  def create
    @playlist = Playlist.new(params[:playlist])

    if @playlist.save
      redirect_to @playlist, :notice => 'Playlist was successfully created.'
    else
      render :action => "new"
    end
  end

  # PUT /playlists/1
  def update
    @playlist = Playlist.find(params[:id])

    if @playlist.update_attributes(params[:playlist])
      redirect_to @playlist, :notice => 'Playlist was successfully updated.'
    else
      render :action => "edit"
    end
  end

  # DELETE /playlists/1
  def destroy
    @playlist = Playlist.find(params[:id])
    @playlist.destroy
    flash[:notice] = "Playlist was successfully deleted."
    redirect_to :playlists
  end
end
