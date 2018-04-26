require "facebook/messenger"
include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

Bot.on :message do |incoming_message|
  incoming_message.typing_on

  text = incoming_message.text
  uid = incoming_message.sender["id"]
  guest = Guest.where(uid: uid).first || Guest.create(uid: uid)

  if text.present?
    Message.create(content: text, kind: "incoming", guest_id: guest.id)
    handle_message(text, guest.id)
  end
end

Bot.on :postback do |postback|
  postback.typing_on

  text = postback.payload
  uid = postback.sender['id']
  guest = Guest.where(uid: uid).first || Guest.create(uid: uid)
  Message.create(content: text, guest_id: guest.id, kind: "incoming")

  handle_message(text, guest.id)
end


def handle_message(text, guest_id)
  chat_service = ChatService.new(guest_id)
  chat_service.execute(text)

  Message.create(
    kind: "outgoing",
    content: chat_service.response_message,
    template: chat_service.response_template,
    follow_up_message: chat_service.follow_up_message,
    quick_replies: chat_service.quick_replies,
    guest_id: guest_id
  )
end
