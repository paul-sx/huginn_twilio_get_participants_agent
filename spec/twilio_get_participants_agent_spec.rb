require 'rails_helper'
require 'huginn_agent/spec_helper'

describe Agents::TwilioGetParticipantsAgent do
  before(:each) do
    @valid_options = Agents::TwilioGetParticipantsAgent.new.default_options
    @checker = Agents::TwilioGetParticipantsAgent.new(:name => "TwilioGetParticipantsAgent", :options => @valid_options)
    @checker.user = users(:bob)
    @checker.save!
  end

  pending "add specs here"
end
