# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
    also_reload 'views'
  end

  get '/albums/new' do
    return erb(:new_album)
  end
  
  get '/artists/new' do
    return erb(:new_artist)
  end

  get '/albums' do
    repo = AlbumRepository.new
    @albums = repo.all
    return erb(:albums)
  end

  get '/artists' do 
    repo = ArtistRepository.new
    @artists = repo.all
    return erb(:artists)
  end

  post '/albums' do 
    @new_album = Album.new
    album_repo = AlbumRepository.new

    @new_album.title = params[:title]
    @new_album.release_year = params[:release_year]
    @new_album.artist_id = params[:artist_id]
    album_repo.create(@new_album)
    return erb(:album_added)
  end

  post '/artists' do 
    repo = ArtistRepository.new
    @new_artist = Artist.new
    @new_artist.name = params[:name]
    @new_artist.genre = params[:genre]
    repo.create(@new_artist)
    return erb(:artist_added)
  end

  get '/albums/:id' do
    album_repo = AlbumRepository.new
    artist_repo = ArtistRepository.new
    
    @album = album_repo.find(params[:id])
    @artist = artist_repo.find(@album.artist_id)

    return erb(:album)
  end

  get '/artists/:id' do
    artist_repo = ArtistRepository.new
    @artist = artist_repo.find(params[:id])
    return erb(:artist)
  end
end