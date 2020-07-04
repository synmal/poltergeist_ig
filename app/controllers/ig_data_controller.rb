class IgDataController < ApplicationController
  before_action :set_poltergeist

  def create
    ig_datas = IgDatum.update_or_create(ig_params[:codes])

    render json: {data: ig_datas}
  end

  def show
    ig_data = IgDatum.find_by(code: params[:code]) || IgDatum.new(code: params[:code])
    if ig_data.new_record?
      ig_data.save!
    else
      IgDatum.update_or_create([ig_data.code])
    end
    render json: {data: ig_data.relevant_data}
  end

  private
  def set_poltergeist
    @session = Capybara.current_session
  end

  def ig_params
    params.permit(codes: [])
  end
end
