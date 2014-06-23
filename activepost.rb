require "rubygems"
require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "db/development.sqlite3",
)

class Measurement < ActiveRecord::Base
end

class Record < ActiveRecord::Base
end

class Management < ActiveRecord::Base
end


def dms2dec(val)
  i_deg = (val / 10000).to_i
  i_min = ((val - i_deg*10000) / 100).to_i
  i_sec = (val - (i_deg*10000) - (i_min*100));
  return i_deg + (i_min.to_f / 60.0) + (i_sec.to_f / 60.0 / 60.0);
end

def latlong2xy(lat, long, kei)
  lat0 = 360000.0
  long0 = 1395000.0

  a = 6378137;
  f = 1 / 298.257222101;
  m0 = 0.9999;

  decLat = dms2dec(lat);
  decLong = dms2dec(long);
  decLat0 = dms2dec(lat0);
  decLong0 = dms2dec(long0);

  radLat = decLat * Math::PI / 180
  radLong = decLong * Math::PI / 180
  radLat0 = decLat0 * Math::PI / 180
  radLong0 = decLong0 * Math::PI / 180

  e1 = Math::sqrt(2 * f - f**2)
  e2 = Math::sqrt(2 * (1 / f) - 1) / ((1 / f) - 1)

  pA = 1.0 + 3.0 / 4.0 * e1**2 + 45.0 / 64.0 * e1**4 + 175.0 / 256.0 * e1**6 + 11025.0 / 16384.0 * e1**8 + 43659.0 / 65536.0 * e1**10 + 693693.0 / 1048576.0 * e1**12 + 19324305.0 / 29360128.0 * e1**14 + 4927697775.0 / 7516192768.0 * e1**16

  pB = 3.0 / 4.0 * e1**2 + 15.0 / 16.0 * e1**4 + 525.0 / 512.0 * e1**6 + 2205.0 / 2048.0 * e1**8 + 72765.0 / 65536.0 * e1**10 + 297297.0 / 262144.0 * e1**12 + 135270135.0 / 117440512.0 * e1**14 + 547521975.0 / 469762048.0 * e1**16

  pC = 15.0 / 64.0 * e1**4 + 105.0 / 256.0 * e1**6 + 2205.0 / 4096.0 * e1**8 + 10395.0 / 16384.0 * e1**10 + 1486485.0 / 2097152.0 * e1**12 + 45090045.0 / 58720256.0 * e1**14 + 766530765.0 / 939524096.0 * e1**16

  pD = 35.0 / 512.0 * e1**6 + 315.0 / 2048.0 * e1**8 + 31185.0 / 131072.0 * e1**10 + 165165.0 / 524288.0 * e1**12 + 45090045.0 / 117440512.0 * e1**14 + 209053845.0 / 469762048.0 * e1**16

  pE = 315.0 / 16384.0 * e1**8 + 3465.0 / 65536.0 * e1**10 + 99099.0 / 1048576.0 * e1**12 + 4099095.0 / 29360128.0 * e1**14 + 348423075.0 / 1879048192.0 * e1**16

  pF = 693.0 / 131072.0 * e1**10 + 9009.0 / 524288.0 * e1**12 + 4099095.0 / 117440512.0 * e1**14 + 26801775.0 / 469762048.0 * e1**16

  pG = 3003.0 / 2097152.0 * e1**12 + 315315.0 / 58720256.0 * e1**14 + 11486475.0 / 939524096.0 * e1**16

  pH = 45045.0 / 117440512.0 * e1**14 + 765765.0 / 469762048.0 * e1**16

  pI = 765765.0 / 7516192768.0 * e1**16

  bCoef = a * (1 - e1**2);
  b1 = bCoef * pA;
  b2 = bCoef * -pB / 2;
  b3 = bCoef * pC / 4;
  b4 = bCoef * -pD / 6;
  b5 = bCoef * pE / 8;
  b6 = bCoef * -pF / 10;
  b7 = bCoef * pG / 12;
  b8 = bCoef * -pH / 14;
  b9 = bCoef * pI / 16;

  s0 = b1 * radLat0 + b2 * Math::sin(2 * radLat0) + b3 * Math::sin(4 * radLat0) + b4 * Math::sin(6 * radLat0) + b5 * Math::sin(8 * radLat0) + b6 * Math::sin(10 * radLat0) + b7 * Math::sin(12 * radLat0) + b8 * Math::sin(14 * radLat0) + b9 * Math::sin(16 * radLat0)

  s = b1 * radLat + b2 * Math::sin(2 * radLat) + b3 * Math::sin(4 * radLat) + b4 *Math::sin(6 * radLat) + b5 * Math::sin(8 * radLat) + b6 * Math::sin(10 * radLat) + b7 * Math::sin(12 * radLat) + b8 * Math::sin(14 * radLat) + b9 * Math::sin(16 * radLat)

  deltaLambda = radLong - radLong0

  eta2 = e2**2 * Math::cos(radLat)**2

  t = Math::tan(radLat)

  w = Math::sqrt(1 - e1**2 * Math::sin(radLat)**2)
  n = a / w

  x = ((s - s0) + 1.0 / 2.0 * n * Math::cos(radLat)**2 * t * deltaLambda**2 + 1.0 / 24.0 * n * Math::cos(radLat)**4 * t * (5 - t**2 + 9 * eta2 + 4 * eta2**2) * deltaLambda**4 - 1.0 / 720.0 * n * Math::cos(radLat)**6 * t * (-61 + 58 * t**2 - t**4 - 270 * eta2 + 330 * t**2 * eta2) * deltaLambda**6 - 1.0 / 40320.0 * n * Math::cos(radLat)**8 * t * (-1385 + 3111 * t**2 - 543 * t**4 + t**6) * deltaLambda**8) * m0

  y = (n * Math::cos(radLat) * deltaLambda - 1.0 / 6.0 * n * Math::cos(radLat)**3 * (-1 + t**2 - eta2) * deltaLambda**3 - 1.0 / 120.0 * n * Math::cos(radLat)**5 * (-5 + 18 * t**2 - t**4 - 14 * eta2 + 58 * t**2 * eta2) * deltaLambda**5 - 1.0 / 5040.0 * n * Math::cos(radLat)**7 * (-61 + 479 * t**2 - 179 * t**4 + t**6) * deltaLambda**7) * m0;

  return x, y
end

srand(12)


@management = Management.find(1)

id = @management.measurementid

for i in 1..100 do
  num = rand * 100
  lat = 360000.0 + rand*100
  long = 1395000.0 + rand*100
  x, y = latlong2xy(lat, long, 0)
  p = Record.new(:depth => num, :latitude => lat, :longitude => long, :x => x, :y => y, :measurement_id => id)
  p.save
#  sleep(0.5)
end
