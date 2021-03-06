task :persistent_menu => :environment do
  script = <<-EOF
  curl -X POST -H "Content-Type: application/json" -d '{
    "get_started": {
      "payload": "Get Started"
    },
    "persistent_menu": [
      {
        "locale": "default",
        "composer_input_disabled": false,
        "call_to_actions": [
          {
            "title": "Actions",
            "type": "nested",
            "call_to_actions": [
              {
                "title": "News",
                "type": "postback",
                "payload": "News"
              },
              {
                "title": "Rankings",
                "type": "postback",
                "payload": "Rankings"
              },
              {
                "title": "Subscribe",
                "type": "postback",
                "payload": "Subscribe"
              }
            ]
          },
          {
            "type": "postback",
            "title": "About",
            "payload": "About"
          },
          {
            "type": "postback",
            "title": "Help",
            "payload": "Help"
          }
        ]
      }
    ]
  }' "https://graph.facebook.com/v2.6/me/messenger_profile?access_token=#{ENV["ACCESS_TOKEN"]}"
  EOF
  system(script)
end
