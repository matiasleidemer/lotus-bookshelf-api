RSpec.describe '/books', type: :api do
  it 'is successful' do
    get '/books'

    expect(response.status).to eq(200)
  end
end
