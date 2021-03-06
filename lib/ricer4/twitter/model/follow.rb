module Ricer4::Plugins::Twitter
  module Model
    class Follow < ActiveRecord::Base
      
      self.table_name = 'tweed_follows'
      
      TWEETAG ||= 1
      TWEETAT ||= 2
      TWEETER ||= 3
      
      abbonementable_by([Ricer4::User, Ricer4::Channel])
  
      arm_install do |m|
        m.create_table table_name do |t|
          t.string    :name,          :null => false
          t.integer   :user_id,       :null => true
          t.integer   :friends,       :null => false, :unsigned => true, :default => 0
          t.integer   :followers,     :null => false, :unsigned => true, :default => 0
          t.integer   :tweets,        :null => false, :unsigned => true, :default => 0
          t.integer   :retweets,      :null => false, :unsigned => true, :default => 0
          t.integer   :last_tweet_id, :null => false, :unsigned => true, :default => 0,  :limit => 8
          t.string    :last_tweeter,  :null => true,  :default => nil
          t.string    :last_tweet,    :null => true,  :default => nil
          t.timestamp :last_tweeted,  :null => true,  :default => nil
          t.timestamp :deleted_at,    :null => true,  :default => nil
          t.timestamp :created_at,    :null => false
          t.timestamp :updated_at,    :null => false
        end
        m.add_index  table_name, :name,  :unique => true
      end

      arm_install('Ricer4::User' => 1) do |m|
        m.add_foreign_key table_name, :ricer_users, :column => :user_id, :on_delete => :nullify
      end
      
      before_save :strip_mb4

      def strip_mb4
        self.last_tweet = self.last_tweet.each_char.select{|c| c.bytes.count < 4 }.join('') rescue nil
      end
      
      scope :active, -> { where("#{table_name}.deleted_at IS NULL")}
      
      def user
        Ricer4::User.find(self.user_id)
      end
      
      def display_date
        I18n.l(self.created_at)
      end
      
      def is_hashtag?
        self.name[0] == '#'
      end
      
      def is_tweeted?
        self.name[0] == '@'
      end
      
      def is_tweeter?
        (!self.is_hashtag?) && (!self.is_tweeted?)
      end
      
      def tweet_type
        return TWEETAG if is_hashtag?
        return TWEETAT if is_tweeted?
        return TWEETER if is_tweeter?
        raise StandardError.new("Unknown tweet type")
      end
      
      def search_term
        case self.tweet_type
        when TWEETAG; "#{self.name} -rt"
        when TWEETAT; "to:#{self.name[1..-1]} -rt"
        when TWEETER; "from:#{self.name} -rt"
        end
      end
      
      def update_from_tweet(tweet)
        self.last_tweet_id = tweet.id
        self.last_tweeter = tweet.user.screen_name
        self.last_tweet = tweet.text
        self.last_tweeted = tweet.created_at
        self.save!
      end
      
      def display_show_item(number)
        I18n.t('ricer4.plugins.twitter.show_item', id:self.id, name:self.name, user:self.user.display_name, date:self.display_date)
      end
      
      def display_list_item(number)
        I18n.t('ricer4.plugins.twitter.list_item', id:self.id, name:self.name)
      end
  
    end
  end
end
