module Ricer4::Plugins::Twitter
  class TweedAbbos < Ricer4::Plugin
    
    is_abbo_list_trigger :for => Ricer4::Plugins::Twitter::Model::Follow

  end
end
