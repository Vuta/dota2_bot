require 'facebook/messenger'

class Message < ApplicationRecord
  belongs_to :guest

  after_create :fire_outgoing_message

  def fire_outgoing_message
    return if kind != "outgoing"
    reply
  end

  def reply
    uid = guest.uid
    fire(uid, prepare_message_content(content, quick_replies, template))
  end

  def prepare_message_content(content, quick_replies = nil, template = nil)
    if template
      message_content = JSON.parse(template)
    else
      message_content = { text: content }

      if quick_replies.present?
        message_content[:quick_replies] = quick_replies.map { |qr| {title: qr, content_type: "text", payload: "empty"} }
      end

      message_content
    end
  end

  def fire(uid, message_content)
    Bot.deliver({
      recipient: {
        id: uid
      },
      message: message_content
    }, access_token: ENV["ACCESS_TOKEN"])
  end
end
