# coding: utf-8

class MeasurementsController < ApplicationController

  def index
    @measurements = Measurement.all
  end


  def show
    @measurement = Measurement.find(params[:id])
  end


  def new
    @measurement = Measurement.new
    @management = Management.find(1)
  end


  def create
    @measurement = Measurement.new(params[:measurement].permit(:comment))
    @management = Management.find(1)
    if @management.state == true
    elsif @measurement.save
      redirect_to measurements_path, notice: '計測を開始しました！'
      @management.state = true
      @management.save
    else
      render action 'new'
    end
  end


  def destroy
    @measurement = Measurement.find(params[:id])
    @measurement.destroy
    redirect_to measurements_path
  end

end
