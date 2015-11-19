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
BufferedReader stationReader;
PImage bg;
String origin_count[];

float mult_x = 1.0;
float mult_y = 1.0;
float min_x = 365000*mult_x; //365558.56; //longitude;
float min_y = 140000*mult_y;//140278.73; //latitude;
float max_x = 377000*mult_x; //376789.19;;
float max_y = 149000*mult_y;//142433.66;;
float range_x = max_x - min_x;
float range_y = max_y - min_y;
float w_width = 900;  
float w_height = (range_y/range_x)*w_width;
float scale_x = 1;
float scale_y = 1;
float scaling = 1;

// Station class to load the stations from file 
class Station {
  public float stationX, stationY;
}

HashMap<Integer, Station> stations = new HashMap<Integer, Station>();

void settings() {
  size((int) w_width, (int) w_height);
}

void setup() {
  frameRate(frame_rate);
  stroke(255);
  bg = loadImage("mapbw.png");
  background(bg);
  smooth();

  // compute transformation vector
  scale_x = w_width/range_x;
  scale_y = w_height/range_y;
  scaling = w_height/range_y;

  // station file
  String stationFile = "/Users/katarzyna/Dropbox/matlab/2015-09_FleetSizeEstimation/inputDemand/ecbd_stations21.txt";  
  stationReader = createReader(stationFile);

  // origin file
} 

//read station file
void readStationFile() {
  String line;
  int i = 0;
  while (true) {
    try {
      line = stationReader.readLine();
    } 
    catch (IOException e) {
      e.printStackTrace();
      line = null;
    }
    if (line == null) return;

    int station_id;
    String[] cols = split(line, ' ');
    station_id = parseInt(i);
    Station st = new Station();
    st.stationX = parseFloat(cols[1]);
    st.stationY = parseFloat(cols[2]);  
    stations.put(station_id, st); 
    i++;
    println(stations.size());
  }
}

//// load counts of origins and destinations for each time of the day
//String counts[] = loadStrings("/Users/katarzyna/Dropbox/matlab/2015-09_FleetSizeEstimation/origCounts_reb1800_stations21.txt");
//println("there are " + counts.length + " rebalancing periods.");
//for (int i = 0; i < counts.length; i++) {
//  println(counts[i]);
//  String[] cols = splitTokens(counts[i]);
//  //println("Lenght of s: " + cols.length + " stations.");
//  //println("added to origin_count [" + i + "]");
//}

void draw() {
  background(bg);

  float station_size = 150; //0.000001
  readStationFile();

  // apply transformation
  pushMatrix();
  scale(scaling);
  //rotate(radians(45));
  translate(-min_x, -min_y);

  // draw stations
  stroke(100, 100, 100);
  fill(#6A5ACD);
  for (Map.Entry me : stations.entrySet()) {
    //println(me.getKey());
    Station st = (Station) me.getValue();
    ellipse(st.stationX, max_y - st.stationY + min_y, station_size, station_size);
  }
  popMatrix();
  fill(#0000FF);
}