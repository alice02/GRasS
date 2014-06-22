# coding: utf-8
require "rubygems"
require "gnuplot"

class MeasurementsController < ApplicationController

  def index
    @measurements = Measurement.all
  end


  def show
    @measurement = Measurement.find(params[:id])
    # プロットするデータ
    triangle1 = [[10,  70,  40], [20, 20,  70],
                 [60, -30, -30], [ 0, 50, -50]]
    triangle2 = [[10,  70,  40], [60, 60,  10],
                 [60, -30, -30], [ 0, -50, 50]]

    Gnuplot.open {|gp|
      Gnuplot::Plot.new(gp) {|plot|
        # gnuplotにsetできるオプションは全てPlotクラスのメソッドになっている
        plot.terminal("png")
        plot.output("graph-sample.png")
        plot.xrange("[0:80]")
        plot.yrange("[0:80]")
        plot.size("square 0.5,0.5")
        plot.title("Star")
        
        triangle1[0].each_index {|i|
          plot.label("\"[#{i}]\" at #{triangle1[0][i]},#{triangle1[1][i]}")
        }

        # プロットするデータをDataSetへ込めてPlot#dataに設定する
        plot.data = [
                     Gnuplot::DataSet.new(triangle1) {|ds|
                       ds.with = "vectors"
                       ds.notitle
                     },
                     Gnuplot::DataSet.new(triangle2) {|ds|
                       ds.with = "vectors"
                       ds.notitle
                     }
                    ]
      }
    }

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
