require "spec_helper"
require "rack/test"
require_relative '../../app'

describe Application do
  include Rack::Test::Methods
  let(:app) { Application.new }
  
  def reset_tables
    albums_seed_sql = File.read('spec/seeds/albums_seeds.sql')
    artists_seed_sql = File.read('spec/seeds/artists_seeds.sql')
    connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
    connection.exec(albums_seed_sql)
    connection.exec(artists_seed_sql)
  end
  
  after(:each) do 
    reset_tables
  end

  context 'GET /albums' do 
    it 'should return the list of albums each in its own div' do
      album_repo = AlbumRepository.new
      albums = album_repo.all
      response = get('/albums')
      albums.each do |record|
        expect(response.body).to include("Title: #{record.title}", "Release Year: #{record.release_year}")
      end
      expect(response.status).to eq(200)
    end
  end

  context 'POST /albums' do
    it 'should create a new album and return confirmation page' do 
      response = post(
        '/albums',
        title: 'OK Computer',
        release_year: '1997',
        artist_id: '1')

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>You saved: OK Computer</h1>')
    end
  end

  context 'POST /albums' do
    it 'should create a new album with a different title and return confirmation page' do 
      response = post(
        '/albums',
        title: 'Stadium Arcadium',
        release_year: '2005',
        artist_id: '1')

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>You saved: Stadium Arcadium</h1>')
    end
  end

  context "GET /artists" do
    it 'returns 200 OK' do
      response = get('/artists')
      artists_repo = ArtistRepository.new
      artists_repo.all.each do |artist|
        expect(response.body).to include("Name: #{artist.name}", "Genre: #{artist.genre}")
        expect(response.body).to include("<a href=\"/artists/#{artist.id}\">Go to the artist page</a>")
      end
      expect(response.status).to eq(200)
    end
  end

  context "POST /artists" do
    it 'returns a html page confirming artist added' do
      response = post('/artists',
      name: 'Wild Nothing',
      genre: 'Indie')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>You saved: Wild Nothing</h1>')
    end
  end

  context "GET /albums/:id" do
    it 'returns 200 OK and relevant album information' do
      response = get("/albums/2")

      expect(response.status).to eq(200)
      expect(response.body).to include("<h1> Surfer Rosa </h1>", "Artist: Pixies")
    end
  end

  context "GET /artists/:id" do
    it 'returns 200 OK and relevant artists information' do
      response = get("/artists/2")

      expect(response.status).to eq(200)
      expect(response.body).to include("Name: ABBA", "Genre: Pop")
    end
  end

  context "GET /albums/new" do
    it 'returns a html form to create a new album' do
      response = get('/albums/new')
      expect(response.status).to eq(200)
      expect(response.body).to include('<form method="POST" action="/albums"')
      expect(response.body).to include('<input type="text" name="title" />')
      expect(response.body).to include('<input type="text" name="release_year" />')
    end
  end

  context "GET /artists/new" do
    it 'returns a html form to create a new artist' do
      response = get('/artists/new')
      expect(response.status).to eq(200)
      expect(response.body).to include('<form method="POST" action="/artists"')
      expect(response.body).to include('<input type="text" name="name" />')
      expect(response.body).to include('<input type="text" name="genre" />')
    end
  end
end