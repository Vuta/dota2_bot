class ChatService
  attr_reader :guest_id, :response_message, :response_template, :follow_up_message, :quick_replies

  def initialize(guest_id)
    @guest_id = guest_id
  end

  def execute(text)
    case text
    when "Get Started"
      @response_message = "Yo, what can I do for you nigga?"
      @quick_replies = ["News", "Patch Update", "Rankings"]
    ###
    when "About"
      @response_message = "I can send you some latest news of Dota 2 (more features will be added later). Developed by Uvhna."
    ###
    when "News"
      elements = []
      Article.order(created_at: :desc, id: :asc).first(5).each do |article|
        elements << {
          "title": article.title,
          "image_url": "#{ENV["GOSUGAMERS_HOST"]}#{article.image}",
          "buttons": [
            {
              "type": "web_url",
              "url": "#{ENV["GOSUGAMERS_HOST"]}#{article.web_url}",
              "title": "Website"
            }
          ]
        }
      end

      @response_template = {
        "attachment": {
          "type": "template",
          "payload": {
            "template_type": "generic",
            "elements": elements
          }
        }
      }.to_json
    ###
    when "Subscribe"
      guest = Guest.find_by(id: guest_id)
      if guest.subscribe
        @response_message = "You've already subscribed. You can unsubscribe anytime by typing 'Unsubscribe' but I hope you won't ;)"
      else
        guest.update(subscribe: true)
        @response_message = "Thanks. I will send you latest news and patch update asap."
      end
    ###
    when "Help"

    ###
    else
      @response_message = "It doesn't look like anything to me. Type 'Help' to see what I can do 😏."
    end
  end
end
