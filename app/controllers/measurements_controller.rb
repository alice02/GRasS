# coding: utf-8
class MeasurementsController < ApplicationController

  def index
    @measurements = Measurement.all
  end


  def show
    @measurement = Measurement.find(params[:id])
    @records = @measurement.records

    if @records.any?
      # アルゴリズム要検討
      File.open("public/out.dat", "w") do |io|
        for i in 0..9 do
          for j in 0..9 do
            io.print "#{i} #{j} #{@records[10*i+j].depth}\n" 
          end
          io.print "\n"
        end
      end
      # gnuplotでグラフ作成実行
      `./gplot.sh #{params[:id]}`
    end

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
