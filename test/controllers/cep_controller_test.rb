require "test_helper"

class Api::V1::CepControllerTest < ActionDispatch::IntegrationTest
  describe "Successful cep validation" do
    before do 
      post '/v1/validate_cep', params: {cep: {number: "81530110"}}

      @body = JSON.parse(response.body)
      @resp_token = response.headers['access-token']
      @resp_client_id = response.headers['client']
      @resp_expiry = response.headers['expiry']
      @resp_uid = response.headers['uid']
    end 

    it "should be successful" do
      assert_equal 200, response.status
    end

    it "should correspond to actual address" do
      assert_equal "Jardim das Américas", @body["neighborhood"]
    end
  end

  describe "Unsuccessful cep validation" do
    before do 
      post '/v1/validate_cep', params: {cep: {number: "81530111"}}

      @body = JSON.parse(response.body)
      @resp_token = response.headers['access-token']
      @resp_client_id = response.headers['client']
      @resp_expiry = response.headers['expiry']
      @resp_uid = response.headers['uid']
    end 

    it "should be successful" do
      assert_equal 400, response.status
    end

    it "should return an error" do
      assert_equal ["Invalid CEP."], @body["errors"]
    end
  end
end
