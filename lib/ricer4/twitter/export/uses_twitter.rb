module Ricer4::Include::UsesTwitter

  def twitter_plugin
    get_plugin('Twitter/Twitter')
  end
      
  def twitter_client
    twitter_plugin.client
  end

end
