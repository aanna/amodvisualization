// visualization of origin and destination counts

import java.util.Map;
import java.io.*;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;

// configuration
int frame_rate = 2; // how many frames is visualized per second
boolean save_frame = false;
float day_start_time = 3*60*60;
int ncars = 0;
int reb_period = 0;
int counter = 0; // used in readCountsFile function

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

void settings() {
  size((int) w_width, (int) w_height);
} //settings

void setup() {
  frameRate(frame_rate);
  stroke(255);
  bg = loadImage("mapbw_new.png");
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
void readCountsFile(BufferedReader reader, int currentLine, int[] counts) {
  String line;
  if (counter == currentLine) {
    try {
      line = reader.readLine();
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
      counts[i] = parseInt(cols[i]);
    }
    //println("counts: ");
    //for (int i = 0; i < counts.length; i++) {
    //println(counts[i]);
    //}
    currentLine = reb_period;
  }
} // readCountsFile

void draw() {
  background(bg);

  int origin_size = 250;
  int dest_size = 150; 
  readStationFile();

  int current_line = reb_period;
  //ArrayList<Counter> countsOrigin = new ArrayList<Counter>();
  //ArrayList<Counter> countsDest = new ArrayList<Counter>();
  int[] countsOrigin = new int[stations.size()];
  int[] countsDest = new int[stations.size()];

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
  int ii_o = 0;
  int ii_d = 0;
  for (Map.Entry me : stations.entrySet()) { 
    //println("getKey type: " + me.getKey());
    origin_size = countsOrigin[ii_o];
    Station st = (Station) me.getValue();
    ellipse(st.stationX, max_y - st.stationY + min_y, origin_size*3, origin_size*3);
    ii_o++;
  }

  // draw stations as a function of destinations
  stroke(100, 100, 100);
  fill(0, 193, 56, 127); // #00C138 =  (0, 193, 56) green
  for (Map.Entry me : stations.entrySet()) {
    //println("getKey funtion: " + me.getKey());
    dest_size = countsDest[ii_d];
    Station st = (Station) me.getValue();
    ellipse(st.stationX, max_y - st.stationY + min_y, dest_size*3, dest_size*3);
    ii_d++;
  }
  
  reb_period++;
  counter++;

  //println("reb_period: " + reb_period);
  popMatrix();
  fill(#C9E893);
  textSize(32);
  float sim_time = (counter-1)*30*60 + day_start_time;
  //println(sim_time);
  Calendar calendar = Calendar.getInstance();
  calendar.set(2000, 1, 1, 0, 0, 0);
  //calendar.setTimeInMillis((int) sim_time*1000);
  calendar.add(Calendar.SECOND, (int) sim_time);
  DateFormat formatter = new SimpleDateFormat("HH:mm:ss");
  text(formatter.format(calendar.getTime()), 10, 30);
}