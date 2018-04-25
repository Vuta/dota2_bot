class ChatService
  attr_reader :response_message, :response_template, :follow_up_message, :quick_replies

  def execute(text)
    case text
    when "Get Started"
      @response_message = "Yo, what can I do for you nigga?"
      @quick_replies = ["News", "Patch Update", "Rankings"]
    when "About"
      @response_message = "I can send you some latest news of Dota 2 (more features will be added later). Developed by Uvhna."
    ###
    when "News"
      elements = []
      Article.first(5).each do |article|
        elements << {
          "title": article.title,
          "image_url": "https://www.gosugamers.net#{article.image}",
          "buttons": [
            {
              "type": "web_url",
              "url": "https://www.gosugamers.net#{article.web_url}",
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
    end
  end
end
