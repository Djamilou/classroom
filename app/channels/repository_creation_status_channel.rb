# frozen_string_literal: true

class RepositoryCreationStatusChannel < ApplicationCable::Channel
  def self.channel(user_id:)
    "#{RepositoryCreationStatusChannel.channel_name}_#{user_id}"
  end

  def subscribed
    stream_from RepositoryCreationStatusChannel.channel(user_id: current_user.id)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
