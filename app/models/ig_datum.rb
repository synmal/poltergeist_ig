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
    url = "https://instagram.com/p/#{code}?__a=1"

    # session.visit url
    session.driver.set_cookie('rur', 'PRN')
    session.driver.set_cookie('sessionid', '541015026%3AmVtswruw3BZvGI%3A27', domain: '.instagram.com', httponly: true, secure: true, path: '/' )
    session.driver.set_cookie('urlgen', "\"{\\\"2001:d08:d1:dd0c:a19b:b90f:2e2e:aefe\\\": 9534}:1jrVOp:cCLBmXHu6ycE8K_w7xiXN_GIT8s\"", httponly: true, path: '/', secure: true, domain: '.instagram.com')
    session.visit url

    puts session.driver.cookies
    JSON.parse(session.first('pre').text)
  end
end

=begin
{
  "rur"=>
    #<Capybara::Poltergeist::Cookie:0x00005640fa341098
      @attributes={
        "domain"=>".instagram.com",
        "httponly"=>true,
        "name"=>"rur",
        "path"=>"/",
        "secure"=>true,
        "value"=>"PRN"
      }>,
    "csrftoken"=>
      #<Capybara::Poltergeist::Cookie:0x00005640fa341020
        @attributes={
          "domain"=>".instagram.com",
          "expires"=>"Fri, 02 Jul 2021 23:22:52 GMT",
          "expiry"=>1625268172,
          "httponly"=>false,
          "name"=>"csrftoken",
          "path"=>"/",
          "secure"=>true,
          "value"=>"vt8vkJBykW7ueSXqqf43TWeZb40BAGeY"
        }>,
      "mid"=>#<Capybara::Poltergeist::Cookie:0x00005640fa340ee0
        @attributes={
          "domain"=>".instagram.com",
          "expires"=>"Mon, 01 Jul 2030 23:22:52 GMT",
          "expiry"=>1909178572,
          "httponly"=>false,
          "name"=>"mid",
          "path"=>"/",
          "secure"=>true,
          "value"=>"Xv-9zAAEAAFvRTSrWXDFU75Kcd5-"
        }>,
      "ig_did"=>
        #<Capybara::Poltergeist::Cookie:0x00005640fa340e40
          @attributes={
            "domain"=>".instagram.com",
            "expires"=>"Mon, 01 Jul 2030 23:22:52 GMT",
            "expiry"=>1909178572,
            "httponly"=>true,
            "name"=>"ig_did",
            "path"=>"/",
            "secure"=>true,
            "value"=>"DC3A0110-0E67-4CD0-B7D1-91DF57D2AD54"
          }>
}
=end
