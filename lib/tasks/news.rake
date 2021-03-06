require "facebook/messenger"
include Facebook::Messenger

namespace :crawl do
  task :news => :environment do
    agent = Mechanize.new
    puts "Crawling news..."
    news_page = agent.get("#{ENV["GOSUGAMERS_HOST"]}/dota2/news/")
    puts "Done."
    news_html = Nokogiri::HTML(news_page.body)
    headline = news_html.css("#latest-articles .headline.clearfix")

    # select only non-exsisted articles
    articles_title = Article.pluck(:title)
    selected_headline = headline.select { |headline| headline unless articles_title.include?(headline.at_css(".details h3 a").text) }

    if selected_headline.present?
      articles_data = []
      selected_headline.each do |headline|
        article_title = headline.at_css(".details h3 a").text
        article_web_url = headline.at_css(".details h3 a")["href"]
        article_image = headline.at_css("a.image img")["src"]
        articles_data << [article_title, article_web_url, article_image]
      end

      article_columns = [:title, :web_url, :image]
      puts "Importing news..."
      Article.import article_columns, articles_data
      puts "Done."

      # send news for subscribed guests
      uids = Guest.where(subscribe: true).pluck(:uid)
      send_news_for_subscribed_guests(uids, articles_data)
    end
  end
end

def send_news_for_subscribed_guests(uids, articles_data)
  elements = []
  articles_data.first(10).each do |article|
    elements << {
      "title": article[0],
      "image_url": "#{ENV["GOSUGAMERS_HOST"]}#{article[2]}",
      "buttons": [
        {
          "type": "web_url",
          "url": "#{ENV["GOSUGAMERS_HOST"]}#{article[1]}",
          "title": "Website"
        }
      ]
    }
  end
  response_template = {
    "attachment": {
      "type": "template",
      "payload": {
        "template_type": "generic",
        "elements": elements
      }
    }
  }.to_json
  response_text = articles_data.length > 1 ? "Here are some latest dota 2 news" : "Here is latest dota 2 news"
  uids.each do |uid|
    begin
      Bot.deliver({
        recipient: {
          id: uid
        },
        message: {
          text: response_text
        }
      }, access_token: ENV["ACCESS_TOKEN"])
      Bot.deliver({
        recipient: {
          id: uid
        },
        message: JSON.parse(response_template)
      }, access_token: ENV["ACCESS_TOKEN"])
    rescue => e
      puts '[debuz] Cannot deliver message to facebook: ' + e.message
    end
  end
end
