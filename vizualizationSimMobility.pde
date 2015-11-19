// visualization of AMOD in SimMobility 
// input files: a background map in png format which must be the same size as the parameters
// into the size() method. In this program, the size of the image is 900 x 675 pixels.
// and the trips data in txt file where each row is as follow: 
// 

import java.util.Map;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;

// configuration
float time_window = 30; // 1 second
int frame_rate = 50;
boolean save_frame = false;
float day_start_time = 3*60*60;
int ncars = 0;
String frame_filename;
float prev_time = -1;
PImage bg;

// Event structure to load the data from the file
class Event {
  public int id;
  public int type;
  public float t;
  public float x;
  public float y;
  public float s;
  public int status;

  public Event(int id, int type, float t, float x, float y, float s, int status) {
    this.id = id;
    this.type = type;
    this.t = t;
    this.x = x;
    this.y = y;
    this.s = s;
    this.status = status;
  }

  public Event() {
    this.id = 0;
    this.type = 0;
    this.t = 0;
    this.x = 0;
    this.y = 0;
    this.s = 0;
    this.status = 0;
  }
} //class event   

float current_time = 0; // start time is 0
int current_event = 0; // starting event = 0
BufferedReader reader;
float mult_x = 1.0;
float mult_y = 1.0;
float min_x = 365000*mult_x; //365558.56; //longitude;
float min_y = 140000*mult_y;//140278.73; //latitude;
float max_x = 377000*mult_x; //376789.19;;
float max_y = 149000*mult_y;//142433.66;;
float scale_x = 1;
float scale_y = 1;
float scaling = 1;
float range_x = max_x - min_x;;
float range_y = max_y - min_y;;

float w_width = 900;  
float w_height = (range_y/range_x)*w_width;
  
class Location {
  public float x, y, s;
}

HashMap<Integer, Location> locs = new HashMap<Integer, Location>();

void settings(){
  size((int) w_width, (int) w_height);
  
}
// setup the simulation
void setup() {
  frameRate(frame_rate);
  //load data from file
  String filename = "/Users/katarzyna/Downloads/ecbd_log_2150Vehs.txt";  

  reader = createReader(filename);

  stroke(255);
  bg = loadImage("/Users/katarzyna/Documents/Processing/vizualizationSimMobility/mapbw.png");
  background(bg);
  //background(0, 0, 0);
  smooth();
  // compute transformation vector
  scale_x = w_width/range_x;
  scale_y = w_height/range_y;
  scaling = w_height/range_y;
}

// read log file
void readLogFile(float end_time, ArrayList events) {
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

    String[] cols = split(line, ' ');
    Event e = new Event();

    if (parseInt(cols[3]) < 4 && parseInt(cols[3]) > 0 ) { //based on event id in AMODBase
      // moves, dropoffs or pickups
      //println(line);
      e.id = parseInt(cols[2]);
      e.type = parseInt(cols[3]);
      e.t = parseFloat(cols[0]);
      e.x = parseFloat(cols[7])*mult_x;
      e.y = parseFloat(cols[8])*mult_y;
      e.status = parseInt(cols[9]);
      e.s = 1;
      if (e.type == 2) {
        ncars++;
      }
    } else if (parseInt(cols[3]) == 5 ||  parseInt(cols[3]) == 6) {
      // location
      e.id = parseInt(cols[2]);
      e.type = parseInt(cols[3]);
      e.t = parseFloat(cols[0]);
      e.x = parseFloat(cols[7])*mult_x;
      e.y = parseFloat(cols[8])*mult_y;
      e.s = parseFloat(cols[9]);
      int locid;


      if (e.type == 6) {
        String[] entities = split(cols[6], ',');
        locid = parseInt(entities[0]);
        //println(locid);
        Location loc = new Location();
        loc.x = e.x;
        loc.y = e.y;
        loc.s = e.s;
        locs.put(locid, loc);
      }
    }

    events.add(e);
    //println(e.id);
    if (e.t > end_time) {
      prev_time = e.t;
      break;
    }
  }
}

// draw function
void draw() {
  background(bg);
  //    println(frameCount);
  //    fill(0, 0, 0, 50);
  //    noStroke();
  //    rect(0, 0, width, height);

  float sc_factor = 10; //30
  float loc_s_factor = 0.000001; //1.0

  //line(150, 25, mouseX, mouseY);
  float start_time = current_time;
  float end_time = start_time + time_window;
  ArrayList<Event> events = new ArrayList<Event>();
  readLogFile(end_time, events);

  // apply transformation
  pushMatrix();
  scale(scaling);
  //rotate(radians(45));
  translate(-min_x, -min_y);


  // draw locations
  stroke(100, 100, 100);
  fill(100, 100, 100, 100);
  for (Map.Entry me : locs.entrySet()) {
    //println(me.getKey());
    Location l = (Location) me.getValue();
    ellipse(l.x, max_y-l.y+min_y, l.s*loc_s_factor, l.s*loc_s_factor);
  }
  noStroke();
  for (int i=0; i<events.size (); i++) {
    Event e = events.get(i);
    // if the event is after the end_time, break

    // draw the event
    // enum EventType {EVENT_MOVE, EVENT_ARRIVAL, EVENT_PICKUP, EVENT_DROPOFF};
    if (e.type == 1) {
      if (e.status == 8) {
        fill(#6A5ACD); //yellow FFAF00, purple #6A5ACD
      } else {
        fill(#EE3A8C); //blue #00B0FF
      }
      ellipse(e.x, max_y-e.y+min_y, 5*sc_factor, 5*sc_factor);  // move event
      //println("", e.x, " " , e.y);
    } else if (e.type == 2) {
      fill(#6A5ACD); //yellow
      ellipse(e.x, max_y-e.y+min_y, 8*sc_factor, 8*sc_factor);
    } else if (e.type == 3) {
      fill(#00C138); //green
      ellipse(e.x, max_y-e.y+min_y, 10*sc_factor, 10*sc_factor);
    } else if (e.type == 4) {
      fill(#FF00E6); //pink
      ellipse(e.x, max_y-e.y+min_y, 12*sc_factor, 12*sc_factor);
    }
    //println("Test:", e.x, e.y);
  }

  current_time = end_time;

  popMatrix();
  fill(#0000FF);
  textSize(32);
  float sim_time = current_time + day_start_time;
  //println(sim_time);
  println(current_time);
  Calendar calendar = Calendar.getInstance();
  calendar.set(2000, 1, 1, 0, 0, 0);
  //calendar.setTimeInMillis((int) sim_time*1000);
  calendar.add(Calendar.SECOND, (int) sim_time);
  DateFormat formatter = new SimpleDateFormat("HH:mm:ss");
  text(formatter.format(calendar.getTime()), 10, 30);
  textSize(16);
  text(str(ncars) + " dispatches", 10, 50);
  if (save_frame) {
    saveFrame(frame_filename);
  }
}