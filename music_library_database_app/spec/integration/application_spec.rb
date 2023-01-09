require "spec_helper"
require "rack/test"
require_relative '../../app'

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context 'GET /albums' do 
    it 'should return the list of albums' do
      response = get('/albums')
      expected_response = 'Surfer Rosa, Waterloo, Super Trouper, Bossanova, Lover, Folklore, I Put a Spell on You, Baltimore, Here Comes the Sun, Fodder on My Wings, Ring Ring'

      expect(response.status).to eq(200)
      expect(response.body).to eq(expected_response)
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
      expected_response = 'Pixies, ABBA, Taylor Swift, Nina Simone, Kiasmos'

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
end
