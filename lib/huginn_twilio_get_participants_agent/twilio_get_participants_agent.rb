module Agents
  class TwilioGetParticipantsAgent < Agent
    cannot_be_scheduled!
    no_bulk_receive!

    gem_dependency_check { defined?(Twilio) }

    description <<-MD
      The Twilio Get Participants Agent takes in an event with a conversation_sid or ConversationSid key and populates a Participants array with the participant phone numbers in the conversation.
    MD

    def default_options
      {
        'accound_sid' => 'ACxxxxxxxxxxxxxxxxxxxxxx',
        'auth_token' => 'xxxxxxxxxxxxxxxxxxxxxxxx',
        'expected_receive_period_in_days' => '10',
        'conversation_sid' => '{{ conversation_sid }}'
      }
    end

    def validate_options
      unless options['account_sid'].present? && options['auth_token'].present? && options['expected_receive_period_in_days'].present? && options['conversation_sid'].present?
        errors.add(:base, 'account_sid, auth_token, conversation_sid and expected_receive_period_in_days are all required.')
      end
    end

    def working?
      last_receive_at && last_receive_at > interpolated['expected_period_in_days'].to_i.days.ago && !recent_error_logs?
    end

#    def check
#    end

    def receive(incoming_events)
      interpolate_with_each(incoming_events) do |event|
        payload = event.payload 
        payload[:participants] = get_participants
        create_event(payload: payload)
      end
    end

    def client
      @client ||= Twilio::REST::Client.new interpolated['account_sid'], interpolated['auth_token']
    end

    def get_participants
      participants = []
      message = client
        .conversations
        .conversations(interpolated['conversation_sid'])
        .participants
        .list
      message.each do |p|
        participants <<= p.messaging_binding
      end

      numbers = []
      participants.each do |p|
        numbers <<= p['address'] if p['address'].present?
        numbers <<= p['proxy_address'] if p['proxy_address'].present?
        numbers <<= p['projected_address'] if p['projected_address'].present?
      end
      numbers.uniq
    end

  end
end
