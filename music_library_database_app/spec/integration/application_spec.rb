require "spec_helper"
require "rack/test"
require_relative '../../app'

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }
  
  def reset_tables
    albums_seed_sql = File.read('spec/seeds/albums_seeds.sql')
    artists_seed_sql = File.read('spec/seeds/artists_seeds.sql')
    connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
    connection.exec(albums_seed_sql)
    connection.exec(artists_seed_sql)
  end

  describe Application do
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
          expect(response.body).to include("<a href=\"/album/:id\">Go to the album page</a>")
        end
        expect(response.status).to eq(200)
      end
    end

    context 'POST /albums' do
      it ' should create a new album' do 
        response = post(
          '/albums',
          title: 'OK Computer',
          release_year: '1997',
          artist_id: '1')

        expect(response.status).to eq(200)
        expect(response.body).to eq('')

        response = get('/albums')

        expect(response.body).to include('OK Computer')
      end
    end

    context "GET /artists" do
      it 'returns 200 OK' do
        response = get('/artists')
        expected_response = 'Pixies, ABBA, Taylor Swift, Nina Simone'

        expect(response.status).to eq(200)
        expect(response.body).to eq(expected_response)
      end
    end

    context "POST /artists" do
      it 'returns 200 OK' do
      
        response = post('/artists',
        name: 'Wild Nothing',
        genre: 'Indie')

        expect(response.status).to eq(200)
        expect(response.body).to eq('')

        response = get('/artists')
        expect(response.body).to include('Wild Nothing')
      end
    end

    context "GET /albums/:id" do
      it 'returns 200 OK and relevant album information' do
        response = get("/albums/2")

        expect(response.status).to eq(200)
        expect(response.body).to include("<h1> Surfer Rosa </h1>", "Artist: Pixies")
      end
    end
  end
end