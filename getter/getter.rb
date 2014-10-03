# -*- coding: utf-8 -*-

# 6/27
# 座標変換部分をクラス化して，別ファイルから読み込むようにしました．
#
# 07/11
# あちこちに散らばったテストコードをマージしました．

#### Requires
require "serialport"
require 'pi_piper'
require "rubygems"
require "active_record"
require File.dirname(__FILE__) + "/LatLong2XY"



#### Const
# GPS
GpsPort = '/dev/ttyAMA0'
GpsBaudrate = 9600
GpsDatabit = 8
GpsStopbit = 1
GpsParitycheck = 0
GpsDelimiter = "\r\n"

# Sonar
SonarPort = '/dev/ttyUSB0'
SonarBaudrate = 4800
SonarDatabit = 8
SonarStopbit = 1
SonarParitycheck = 0
SonarDelimiter = "\r\n"
SonarMAWeight = [0.25, 0.25, 0.5]

# GPIO Pin
StartSWPin = 3
ShutDownSWPin = 4
LEDPin = 2



#### Initializing
# 状態に応じてステータスLEDを点滅させる
# :ready 	のとき 消灯
# :running	のとき データ受信時に点滅（このスレッドで消灯させる）
# :wakeup	のとき 点灯
$status = :wakeup

led = PiPiper::Pin.new :pin => LEDPin, :direction => :out
t_led = Thread.new do
  loop do
    case $status

    when :wakeup
      led.on

    when :ready then
      led.on
      sleep 0.2
      led.off

    when :running then 
      led.on

    when :shutdown
      led.on
    end

    sleep 0.2
  end
end


# ActiveRecord Settings
ActiveRecord::Base.default_timezone = 'Tokyo'

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "/home/pi/gomihiroi/grass/db/development.sqlite3",
  timeout: "60000"
)

class Measurement < ActiveRecord::Base
end

class Record < ActiveRecord::Base
end

class Management < ActiveRecord::Base
end


# Serial Port Settings
sp_gps = SerialPort.new(GpsPort, GpsBaudrate, GpsDatabit, GpsStopbit, GpsParitycheck) 
sp_gps.read_timeout=1000
# sp_gps.write "\$JASC,GPGGA,5\r\n"
sp_gps.flush_input

sp_sonar = SerialPort.new(SonarPort, SonarBaudrate, SonarDatabit, SonarStopbit, SonarParitycheck) 
sp_sonar.read_timeout=1000
sp_sonar.flush_input


# スタートボタンが押されたときに status を変える
PiPiper::after :pin => StartSWPin, :goes => :low do
  if $status == :ready then

    sp_gps.flush_input
    sp_sonar.flush_input
    # initialize database
    # create new measurement
    p = Measurement.new()
    p.save
    # load management data
    m = Management.find(1)
    $id = m.measurementid
    $kei = m.kei
    n = m.measurementid + 1
    m.update(:measurementid => n, :state => true)
    p "id: #{$id} kei: #{$kei}"
    # definition class
    $ll2xy = LatLong2XY.new($kei)

    $status = :running

  elsif $status == :running then
    $status = :ready

    # finalize database
    m = Management.find(1)
    m.update(:state => false)
  end

  # チャタリング防止
  sleep 0.05
end


# シャットダウンスイッチ
$shutdownflag = false
PiPiper::after :pin => ShutDownSWPin, :goes => :low do
  print "This machine will shutdown in 5 seconds."

  $shutdownflag = true 
  $status = :shutdown
  sleep 5

  if $shutdownflag == true then
    `sudo halt`
    exit
  end
end

PiPiper::after :pin => ShutDownSWPin, :goes => :high do
  $shutdownflag = false
  $status = :ready
end


# # GPSが衛星を捕捉するまで待機
# loop do 
#   # "$GPGGA"で始まるセンテンスを取り出す
#   begin 
#     gps_msg = sp_gps.gets("#{GpsDelimiter}") 
#   end while gps_msg == nil or !(gps_msg =~ /^\$GPGGA/)
#   gps_msg.strip!
#   # ステータスを調べる
#   gps_quality = gps_msg.split(",")[6].to_i
#   if gps_quality != 0 then 
#     break
#   end
# end


# # test code
# sonar_msg = 0
# declat = 0
# declong = 0


# Initializing was Done.
$status = :ready



#### Main loop
loop do
  if $status == :running then

    # Sonarの値を3度読み取り移動平均をとる
    depth = 0.0
    3.times do |k|
      begin
        sonar_msg = sp_sonar.gets("#{SonarDelimiter}") 
      end while sonar_msg == nil
      sonar_msg.strip!
      depth += sonar_msg.split(",")[2].to_f * SonarMAWeight[k]
    end
    p depth

    sp_gps.flush_input
    begin 
      gps_msg = sp_gps.gets("#{GpsDelimiter}") 

      # if gps_msg != nil
      #   gps_msg.strip!
      # end

      gps_acceptflag =  (gps_msg != nil and 
                         gps_msg.ascii_only? and 
                         gps_msg =~ /^\$GPGGA/ and 
                         gps_msg.split(",")[6].to_i >= 1 and
                         # gps_msg =~ /\*\w\w$/ and 
                         gps_msg[1..-6].bytes.reduce(0,:^) == gps_msg[-4..-3].to_i(16) )
                         # true)

      p "LOOP;", gps_msg
      p gps_acceptflag
    end while gps_acceptflag == false or gps_acceptflag == nil

    gps_msg.strip!
    p gps_msg

    lat = (gps_msg.split(",")[2]).to_f
    long = (gps_msg.split(",")[4]).to_f


    x, y, declat, declong = $ll2xy.to_xy(lat, long)

    # if rand(6) % 2 == 1
    #   sonar_msg = sonar_msg + 1
    # else
    #   sonar_msg = sonar_msg - 1
    # end

    p "x:#{x}, y:#{y}, latitude:#{lat}, longitude:#{long}, depth:#{depth}, status:#{$status}"
    p = Record.new(:depth => depth, :latitude => declat, :longitude => declong, :x => x, :y => y, :measurement_id => $id)
    p.save

    # LED点灯(ステータスLED管理スレッドの中でOFFにしてくれる)
    led.off

  else
    puts "Status: #{$status}"
    sleep 0.7
  end


end

