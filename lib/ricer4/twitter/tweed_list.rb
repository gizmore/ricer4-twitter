module Ricer4::Plugins::Twitter
  class TweedList < Ricer4::Plugin
    
    is_list_trigger "twitter.feeds", :for => Ricer4::Plugins::Twitter::Model::Follow

  end
end
