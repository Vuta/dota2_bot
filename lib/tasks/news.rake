namespace :crawl do
  task :news => :environment do
    agent = Mechanize.new
    puts "Crawling news..."
    news_page = agent.get("https://www.gosugamers.net/dota2/news/")
    puts "Done."
    news_html = Nokogiri::HTML(news_page.body)
    headline = news_html.css("#latest-articles .headline.clearfix")

    articles_data = []
    headline.each do |headline|
      article_title = headline.at_css(".details h3 a").text
      article_web_url = headline.at_css(".details h3 a")["href"]
      article_image = headline.at_css("a.image img")["src"]
      articles_data << [article_title, article_web_url, article_image]
    end

    article_columns = [:title, :web_url, :image]
    puts "Importing news..."
    Article.import article_columns, articles_data
    puts "Done."
  end
end
