namespace :crawl do
  task :rankings => :environment do
    agent = Mechanize.new
    puts "Crawling rankings..."
    rankings_page = agent.get("http://www.dota2.com/procircuit")
    puts "Done."
    rankings_html = Nokogiri::HTML(rankings_page.body)

    rankings_data = []
    rankings_html.css(".teamsElement").each do |team|
      rank = team.at_css("span.rankColumn").text
      team_name = team.at_css("span.teamColumn").text
      points = team.at_css("span.pointsColumn").text

      if team_name == "Team Secret"
        image_url = "https://images.duckduckgo.com/iu/?u=https%3A%2F%2Fi.ytimg.com%2Fvi%2FB6JHoSw6Hrs%2Fmaxresdefault.jpg&f=1"
      else
        image_url = team.at_css("span.teamLogoColumn img")["src"]
      end

      rankings_data << [rank, team_name, points, image_url]
    end

    ranking_columns = [:rank, :team, :point, :image_url]
    Ranking.destroy_all
    puts "Importing rankings..."
    Ranking.import ranking_columns, rankings_data
    puts "Done."
  end
end
