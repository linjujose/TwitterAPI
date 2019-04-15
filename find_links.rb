#!/usr/bin/env ruby
require 'httparty'

#API keys
#Create a twitter dev account and get API key and secret key

class Twitter
    include HTTParty
    #debug_output $stdout
end

tweets_hash = {}
count = 0
hashtag = ARGV[0]

# OAuth2
#https://developer.twitter.com/en/docs/basics/authentication/api-reference/token
@app_credentials = Base64.encode64("#{@api_key}:#{@secret_key}").gsub("\n", '')
url = "https://api.twitter.com/oauth2/token"
body = "grant_type=client_credentials"
headers = {
    "Host" => "api.twitter.com",
    "User-Agent" => "My Twitter App v1.0.23",
    "Authorization" => "Basic #{@app_credentials}",
    "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8"
  }
@resp = Twitter.post(url,
    :body => body,
    :headers => headers )
@access_token = JSON.parse(@resp.body)['access_token']

auth_header = {
    "Authorization" => "Bearer #{@access_token}",
    "maxResults" => "100"
    }
#Twitter Search Endpoint with parameters
url = "https://api.twitter.com/1.1/search/tweets.json?q=%23#{hashtag}&count=100"

@resp = HTTParty.get(url, headers: auth_header)
tweets = JSON.parse(@resp.body)['statuses']

tweets.each do |key|
    tweet_data = key["entities"]
    valid_url = tweet_data["urls"][0]
    #Check an HTTP link exits
    if (valid_url)
        actual_url = valid_url["expanded_url"]
        #FILTER out tweet urls
        if !(actual_url.split("https://twitter.com/")[1])
            #Enforce UNIQUE
            if !(tweets_hash[actual_url])
                count += 1
                tweets_hash[actual_url] = count
            end
        end
    end
end

tweets_hash.each do |key, val|
    puts val.inspect + ". " + key
end

__END__
# If the HTTP links expectd are the tweets themselves.

tweets.each do |key|
    urls = key["text"].split("https://t.co/")
    tweet_link = urls[1]

    if(tweet_link)    
        tweet_hash = tweet_link.split(" ")[0]
        #Store only unique links
        if !(tweets_hash[tweet_hash])
            count += 1
            tweets_hash[tweet_hash] = count
        end
    end
end

tweets_hash.each do |key, val|
    puts val.inspect + ". " + "https://t.co/" + key
end