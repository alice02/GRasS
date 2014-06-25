# coding: utf-8
class MeasurementsController < ApplicationController

  def index
    @measurements = Measurement.all
    @management = Management.find(1)
  end


  def show
    @measurement = Measurement.find(params[:id])
    @records = @measurement.records

    if @records.any?
      File.open("public/out.dat", "w") do |io|
        @records.each do |r|
          io.print "#{r.x} #{r.y} #{r.depth}\n" 
        end
      end
      # gnuplotでグラフ作成実行
      `./gplot.sh #{params[:id]}`
    end
  end


  def export_csv
    @measurement = Measurement.find(params[:id])
    @records = @measurement.records
    data = CSV.generate do |csv|
      csv << ["depth", "x", "y"]
      @records.each do |r|
        csv << [r.depth, r.x, r.y]
      end
    end
    send_data(data, type: 'text/csv', filename: "Record_#{@measurement.id}_#{Time.now.strftime('%Y%m%d%H%M%S')}")
  end


  def new
    @measurement = Measurement.new
  end


  def create
    @measurement = Measurement.new(params[:measurement].permit(:comment))
    @management = Management.find(1)
    if @management.state == true
      redirect_to measurements_path, notice: '現在その操作はできません！'
    elsif @measurement.save
      @management.state = true
      @management.measurementid = @management.measurementid + 1
      @management.save
      redirect_to measurements_path, notice: '計測を開始しました！'
    else
      render action 'new'
    end
  end


  def edit
    @measurement = Measurement.find(params[:id])
  end


  def update
    @measurement = Measurement.find(params[:id])
    if @measurement.update(params[:measurement].permit(:comment))
      redirect_to measurements_path, notice: '更新されました！'
    else
      render action: 'edit'
    end
  end


  def destroy
    @measurement = Measurement.find(params[:id])
    @measurement.destroy
    redirect_to measurements_path
  end

end
