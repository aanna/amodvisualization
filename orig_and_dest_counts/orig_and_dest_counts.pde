// visualization of origin and destination counts

import java.util.Map;

// configuration
float time_window = 30; // 1 second
int frame_rate = 50;
boolean save_frame = false;
float day_start_time = 3*60*60;
int ncars = 0;
String frame_filename;
float prev_time = -1;
PImage bg = loadImage("/Users/katarzyna/Documents/Processing/vizualizationSimMobility/mapbw.png");

// Station structure to load the stations from file 
class Station {
  public int station_id;
  public float stationX;
  public float stationY;

  public Station(int station_id, float stationX, float stationY) {
    this.station_id = station_id;
    this.stationX = stationX;
    this.stationY = stationY;
  }

  public Station() {
    this.station_id = 0;
    this.stationX = 0.0;
    this.stationY = 0.0;
  }
}

void setup() {

  void readStationCoord(){
    
    
  }
  
  
  void readCountsFile(float end_time, String count){
   if (end_time < prev_time) {
    return;
  } 
  String line;
  ncars = 0;
  while (true) {
    try {
      line = reader.readLine();
    } 
    catch (IOException e) {
      e.printStackTrace();
      line = null;
    }
    if (line == null) return;
    
  }
  
  
  // load counts of origins and destinations for each time of the day
  String counts[] = loadStrings("/Users/katarzyna/Dropbox/matlab/2015-09_FleetSizeEstimation/origCounts_reb1800_stations21.txt");
  println("there are " + counts.length + " lines");
  for (int i = 0 ; i < counts.length; i++) {
    println(counts[i]);
    origin_count[i] = counts[i];
    println("added to origin_count [" + i + "]");
  }
}

