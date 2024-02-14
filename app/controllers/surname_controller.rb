require 'faraday'
class SurnameController < ApplicationController
    before_action :ensure_has_name

    def get_nationality
        start_time=Time.now
        name = params["name"]
        response = call_api(name)
        parsed_response = JSON.parse(response.body)
        if response.success? && parsed_response["count"] > 0
          render json: create_json(parsed_response["country"][0], start_time)
        elsif parsed_response["count"] == 0
          render json: "Unknown surname"
        else
          render json: "Error: #{response.reason_phrase}"
        end
    end

    private

    def call_api(name)
      connection = Faraday.new('https://api.nationalize.io')
      response = connection.get do |request|
        request.params = { format: 'json', addressdetails: 1, name: }
      end
    end

    def create_json (response, start_time)
      response = {guessed_country: response["country_id"],
                  requested_name: params["name"],
                  time_processed: Time.now - start_time
                  }
    end

    def ensure_has_name
      return true if !params["name"].blank?
      render json: "Name can't be blank"
    end

end