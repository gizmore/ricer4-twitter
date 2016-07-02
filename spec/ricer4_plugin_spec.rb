require 'spec_helper'

describe Ricer4::Plugins::Twitter do
  
  # LOAD
  bot = Ricer4::Bot.new("ricer4.spec.conf.yml")
  bot.db_connect
  ActiveRecord::Magic::Update.install
  ActiveRecord::Magic::Update.run
  bot.load_plugins
  ActiveRecord::Magic::Update.run
  
  USERS = Ricer4::User
  FOLLOWS = Ricer4::Plugins::Twitter::Model::Follow

  it("can reinstall and flush") do
    USERS.destroy_all
    FOLLOWS.destroy_all
  end

  it("can abbonement tags, user and mentions") do
  end
  
end
