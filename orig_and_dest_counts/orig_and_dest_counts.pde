// visualization of origin and destination counts

import java.util.Map;
import java.io.*;

// configuration
int frame_rate = 50;
boolean save_frame = false;
float day_start_time = 3*60*60;
int ncars = 0;
int reb_period = 0;
int counter = 0;

BufferedReader stationReader;
BufferedReader originReader;
BufferedReader destReader;
PImage bg; // to load background picture
String frame_filename; // for saving frames

// scale up/down the network to the size of the screen
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

// counter to store how many trips departures/arrives to each station
class Counter {
  public int count;
}

void settings() {
  size((int) w_width, (int) w_height);
} //settings

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
  String stationFile = "ecbd_stations21.txt";  
  stationReader = createReader(stationFile);

  // origin file
  String originFile = "origCounts_reb1800_stations21.txt";
  originReader = createReader(originFile);

  // destination file
  String destFile = "destCounts_reb1800_stations21.txt";
  destReader = createReader(destFile);
} // setup

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
} //readStationFile

// read counts (origin and destination) file
void readCountsFile(BufferedReader reader, int currentLine, ArrayList counts) {
  String line;
  if (counter == currentLine) {
    try {
      line = reader.readLine();
      //counter++;
      //println("currentLine1 inside read function: " + currentLine);
    } 
    catch (IOException e) {
      e.printStackTrace();
      line = null;
    }
    if (line == null) return;

    println(line);
    String[] cols = splitTokens(line);
    //println("readCountsFile function: There are: " + cols.length + " stations after splitting.");

    for (int i = 0; i < cols.length; i++) {
      Counter ct = new Counter();
      ct.count = parseInt(cols[i]);
      //println("ct.count: " + ct.count);
      counts.add(ct);
      //println("counts.size(): " + counts.size());
    }
    currentLine = reb_period;
    //println("currentLine2 inside read function: " + currentLine);
  }
} // readCountsFile

void draw() {
  background(bg);

  int origin_size = 250;
  int dest_size = 150; 
  readStationFile();

  int current_line = reb_period;
  ArrayList<Counter> countsOrigin = new ArrayList<Counter>();
  ArrayList<Counter> countsDest = new ArrayList<Counter>();

  if (current_line < stations.size()) {
    println("Origin: ");
    readCountsFile(originReader, current_line, countsOrigin);
    //println("Counts Origin size: " + countsOrigin.size());
    println("Destination: ");
    readCountsFile(destReader, current_line, countsDest);
    //println("Counts Destination size: " + countsDest.size());
  }

  // apply transformation
  pushMatrix();
  scale(scaling);
  //rotate(radians(45));
  translate(-min_x, -min_y);

  // draw stations as a function of origins
  stroke(100, 100, 100);
  fill(255, 51, 51, 127); // #6A5ACD = (106, 90, 205) purple, red = (255, 51, 51)
  //the 4th entry is transarency, where 0 means 0% opaque (completely transparent) and 255 is completely opaque  

  for (Map.Entry me : stations.entrySet()) {
    println("getKey type: " + me.getKey());
    //origin_size = countsOrigin.get(1);
    //for each key find the size of the station as a function of the number of originating trips

    Station st = (Station) me.getValue();
    ellipse(st.stationX, max_y - st.stationY + min_y, origin_size, origin_size);
  }

  // draw stations as a function of destinations
  stroke(100, 100, 100);
  fill(0, 193, 56, 127); // #00C138 =  (0, 193, 56) green
  for (Map.Entry me : stations.entrySet()) {
    //println("getKey funtion: " + me.getKey());

    //for each key find the size of the station as a function of the number of originating trips

    Station st = (Station) me.getValue();
    ellipse(st.stationX, max_y - st.stationY + min_y, dest_size, dest_size);
  }
  
  reb_period++;
  counter++;
  //println("reb_period: " + reb_period);
  popMatrix();
  fill(#0000FF);
}