module Ricer4::Plugins::Twitter
  class TweedUnabbo < Ricer4::Plugin
    
    is_remove_abbo_trigger :for => Ricer4::Plugins::Twitter::Model::Follow

    def abbo_find(relation, term)
      relation.where(:name => term).first or relation.find(term)
    end

  end
end
