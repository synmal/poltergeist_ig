class IgDatum < ApplicationRecord
  def self.update_or_create(codes)
    codes.map do |code|
      existing_data = find_by(code: code)

      if existing_data
        existing_data.update!(data: get_data(code))
        existing_data.relevant_data
      else
        create!(code: code, data: get_data(code)).relevant_data
      end
    end
  end

  def relevant_data
    {
      url: "https://www.instagram.com/p/#{code}",
      caption: data.dig('graphql', 'shortcode_media', 'edge_media_to_caption', 'edges')[0].dig('node', 'text'),
      likes: data.dig('graphql', 'shortcode_media', 'edge_media_preview_like', 'count'),
      comments: data.dig('graphql', 'shortcode_media', 'edge_media_preview_comment', 'count'),
      created_time: data.dig('graphql', 'shortcode_media', 'taken_at_timestamp')
    }
  end

  def self.get_data(code)
    session = Capybara.current_session
    url = "http://www.instagram.com/p/#{code}?__a=1"

    session.visit url
    # byebug
    puts session.driver.cookies
    JSON.parse(session.first('pre').text)
  end
end
