class ChatService
  attr_reader :guest_id, :response_message, :response_template, :follow_up_message, :quick_replies

  def initialize(guest_id)
    @guest_id = guest_id
  end

  def execute(text)
    case text
    when "Get Started", "hi", "Hi", "hello", "Hello"
      @response_message = "Yo, what can I do for you?"
      @quick_replies = ["News", "Rankings", "Subscribe", "About","Help"]
    ###
    when "About", "about"
      @response_message = "I can send you some latest news of Dota 2 (more features will be added later). Developed by Uvhna who is very smart, handsome, charming, and funny ;)"
    ###
    when "News", "news"
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

      @response_template = setup_template_for_response(elements, "generic").to_json
    ###
    when "Rankings"
      elements = []
      Ranking.first(4).each do |rank|
        elements << {
          "title": rank.team,
          "image_url": rank.image_url,
          "subtitle": "Rank: ##{rank.rank} - Point: #{rank.point}",
        }
      end
      @response_template = setup_template_for_response(elements, "list")
      @response_template[:attachment][:payload][:top_element_style] = "large"
      @response_template[:attachment][:payload][:buttons] = [
        {
          "title": "View All Rankings",
          "type": "postback",
          "payload": "view_all_rankings"
        }
      ]
      @response_template = @response_template.to_json
    ###
    when "view_all_rankings"
      elements = []
      Ranking.first(10).each do |rank|
        elements << {
          "title": rank.team,
          "image_url": rank.image_url,
          "subtitle": "Rank: ##{rank.rank} - Point: #{rank.point}",
        }
      end
      @response_template = setup_template_for_response(elements, "generic").to_json
    ###
    when "Subscribe", "subscribe"
      guest = Guest.find_by(id: guest_id)
      if guest.subscribe
        @response_message = "You've already subscribed. You can unsubscribe anytime by typing 'Unsubscribe' but I hope you won't ;)"
      else
        @response_message = "Thanks. I will send you latest news and patch update asap."
        guest.update(subscribe: true)
      end
    ###
    when "Unsubscribe", "unsubscribe"
      @response_message = "Done. You will miss a lot of fun stuff but whatever 😏"
      guest = Guest.find_by(id: guest_id)
      guest.update(subscribe: false)
    ###
    when "Help", "help"
      @response_message = "Type 'News' to read dota 2 news.\nType 'Subscribe' so I will send you latest news, patch update asap. You can unsubscribe anytime by typing 'Unsubscribe'.\nType 'Rankings' to view Dota Pro Circuit rankings.\nType 'About' to know more about me.\nThat's what I can do for now, more features coming soon 😘 (or later, my master is really lazy)."
      @quick_replies = ["News", "Subscribe", "Rankings", "About"]
    ###
    when "chos Vu", "chó Vũ", "chos Vũ", "chos vu", "chó vũ"
      @response_message = "Stfu, my master is not someone that you can talk shit about 😠"
    ###
    else
      @response_message = "It doesn't look like anything to me. Type 'Help' to see what I can do 😏"
    end
  end

  private

  def setup_template_for_response(elements, template_type)
    {
      "attachment": {
        "type": "template",
        "payload": {
          "template_type": template_type,
          "elements": elements,
        }
      }
    }
  end
end
