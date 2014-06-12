class RecordsController < ApplicationController

  def create
    @measurement = Measurement.find(params[:measurement_id])
    @record = Measurement.find(params[:measurement_id]).records.create(params[:record].permit(:depth, :latitude, :longitude))
    redirect_to measurement_path(@measurement)
  end

end
