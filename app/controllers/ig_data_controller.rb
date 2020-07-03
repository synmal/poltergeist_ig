class IgDataController < ApplicationController
  before_action :set_poltergeist

  def create
    ig_datas = IgDatum.update_or_create(ig_params[:codes])

    render json: {data: ig_datas}
  end

  private
  def set_poltergeist
    @session = Capybara.current_session
  end

  def ig_params
    params.permit(codes: [])
  end
end
