class IgDatum < ApplicationRecord
  before_create :set_data

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
  rescue
    {'post_status': 'private'}
  end

  def self.get_data(code)
    session = Capybara.current_session
    url = "https://instagram.com/p/#{code}?__a=1"

    session.driver.set_cookie('rur', 'PRN')
    session.driver.set_cookie('sessionid', ENV['SESSIONID'], domain: '.instagram.com', httponly: true, secure: true, path: '/' )
    session.visit url

    JSON.parse(session.first('pre').text)

  rescue
    {'post_status': 'private'}
  end

  private
  def set_data
    self.data = self.class.get_data(self.code)
  end
end
