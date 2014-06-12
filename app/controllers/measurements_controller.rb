# coding: utf-8

class MeasurementsController < ApplicationController

  def index
    @measurements = Measurement.all
  end


  def show
    @measurement = Measurement.find(params[:id])

    @hash = Gmaps4rails.build_markers(@measurement.records) do |data, marker|
      marker.lat data.latitude
      marker.lng data.longitude
    end

    category = []
    hoge_data = []

    @measurement.records.each do |r| 
      category.push(r.id)
      hoge_data.push(r.depth)
    end

    @h = LazyHighCharts::HighChart.new("graph") do |f|
      f.chart(:type => "area")
      f.title(:text => "Depth Graph")
      f.xAxis(:categories => category)
      f.series(:name => "Depth", :data => hoge_data)
    end
  end


  def new
    @measurement = Measurement.new
  end


  def create
    @measurement = Measurement.new(params[:measurement].permit(:comment))
    if @measurement.save
      redirect_to measurements_path, notice: '計測を開始しました！'
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
