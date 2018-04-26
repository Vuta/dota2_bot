require "facebook/messenger"

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
      # guests = Guest.where(subscribe: true)
      # guests.pluck(:uid).each do |uid|
      #   Bot.deliver({
      #     recipient: {
      #       id: uid
      #     },
      #     message: {
      #       text: "Test"
      #     }
      #   }, access_token: ENV["ACCESS_TOKEN"])
      # end
    end
  end
end
