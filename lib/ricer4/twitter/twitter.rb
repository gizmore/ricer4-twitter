module Ricer4::Plugins::Twitter
  class Twitter < Ricer4::Plugin
    
    require "twitter"
    
    attr_reader :client
    
    has_setting name: :api_key, type: :secret, min:8, max:64, scope: :bot, permission: :responsible, default: bot.config.twitter_api_key
    has_setting name: :api_secret, type: :secret, min:8, max:64, scope: :bot, permission: :responsible, default: bot.config.twitter_api_secret
    has_setting name: :access_token, type: :secret, min:8, max:64, scope: :bot, permission: :responsible, default: bot.config.twitter_access_token
    has_setting name: :access_secret, type: :secret, min:8, max:64, scope: :bot, permission: :responsible, default: bot.config.twitter_access_secret
    
    def plugin_init
      check_connection
      arm_subscribe('ricer/ready') do
        service_threaded do
          loop do
            sleep(30)
            check_connection
            poll_tweeds
          end
        end
      end
    end
    
    def check_connection
      @client ||= ::Twitter::REST::Client.new do |config|
        config.consumer_key = get_setting(:api_key)
        config.consumer_secret = get_setting(:api_secret)
        config.access_token = get_setting(:access_token)
        config.access_token_secret = get_setting(:access_secret)
      end
    end
    
    def poll_tweeds
      bot.log.debug("Twitter::poll_tweeds")
      Ricer4::Plugins::Twitter::Model::Follow.all.active.find_each do |follow|
        begin
          if follow.abbonements.length > 0
            poll_tweed(follow)
            sleep(5.seconds)
          end
        rescue Object::Twitter::Error::Unauthorized => error
          bot.log.error("Twitter Error: #{error}")
          sleep(15.minutes)
          retry 
        rescue Object::Twitter::Error::TooManyRequests => error
          bot.log.error("Twitter Flooding: #{error}. I should retry_after #{error.rate_limit.retry_after}")
          delay = error.rate_limit.reset_in > 0 ? error.rate_limit.reset_in : 900;
          sleep(delay + 10)
          retry
        rescue Object::Twitter::Error::ServiceUnavailable
          sleep(10.minutes)
          retry
        rescue StandardError => e
          bot.log.exception(e)
        end
      end
    end
    
    def poll_tweed(follow)
      bot.log.info("Twitter.poll_tweed(#{follow.name})...")
      client.search(follow.search_term, :since_id => follow.last_tweet_id).reverse_each do |tweet|
        follow.abbonements.find_each do |abbo_target|
          abbo_target.target.localize!.send_message(hashtag_message(follow, tweet))
        end
        if tweet.id > follow.last_tweet_id
          follow.update_from_tweet(tweet)
        end
      end
    end
    
    def hashtag_message(follow, tweet)
      case follow.tweet_type
      when Model::Follow::TWEETAG; key = :msg_new_tweetag
      when Model::Follow::TWEETAT; key = :msg_new_tweetat
      when Model::Follow::TWEETER; key = :msg_new_tweeter
      end
      t(key,
        :hashtag => follow.name,
        :tweet => tweet.text,
        :author => tweet.user.screen_name,
        :date => I18n.l(tweet.created_at),
      )
    end

  end
end
