require 'rails_helper'

RSpec.describe "Categories page (homepage)", type: :request do
 describe "GET /" do
   it "includes buying options section heading" do
     get root_path
     
     expect(response).to have_http_status(:success)
     expect(response.body).to include("Buying options, by category")
   end

   it "displays all categories from Contentful" do
     get root_path

     expect(response).to have_http_status(:success)
     expect(response.body).to include("Vehicle hire and purchase")
   end

   it "displays category descriptions" do
     get root_path

     expect(response).to have_http_status(:success)
     expect(response.body).to include("Long-term catering contracts")
   end
 end
end
