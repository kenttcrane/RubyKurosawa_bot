require 'twitter'

def my_client()
    client = Twitter::REST::Client.new do |config| #TwitterからAPI申請時に発行されるものを代入する
        config.consumer_key = "AAAAA"
        config.consumer_secret = "BBBBB"
        config.access_token = "CCCCC"
        config.access_token_secret = "DDDDD"
    end
    return client
end