import http.requests.*;
import java.util.*;

String days [] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
String months[] = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
String temp = "", hum = "", desc = "";

// create an app on https://developer.spotify.com/dashboard/
String token = "";// dynamic token allocation not yet supported, generate a token from https://developer.spotify.com/console/get-user-player 
//scopes 'user-read-playback-state' 'user-read-playback-position'

String weatherUrl = "https://api.openweathermap.org/data/2.5/weather?lat=xxxxxxxx&lon=xxxxxxxxxx&appid=xxxxxxxxxxxxxxxxxxxxxxxx&units=metric";//replace xxxxx
//https://openweathermap.org/



PImage art, cloud, spotify;

String track = "", artist = "", album = "", url = "";
String lName = "";
int sc = 0;


void setup() {
  size(1024, 600);



  //getWeather();
  if (getPlayer()) {
    lName = track;
    art = loadImage(url, "png");
  }
  cloud = loadImage("clouds.png");
  cloud.resize(0, 70);
  spotify = loadImage("spotify.png");
  spotify.resize(0, 70);
  imageMode(CENTER);
}

void draw() {
  background(0);

  //time
  textSize(140);
  textAlign(CENTER, CENTER);
  Calendar c = Calendar.getInstance();
  text(getTime(), 300, 100);
  textSize(70);
  text(days[c.get(Calendar.DAY_OF_WEEK)-1], 300, 250);
  textSize(50); 
  text(str(day()) +" "+ months[month()-1] + " "+year(), 300, 350);

  //lines
  strokeCap(ROUND);
  strokeWeight(8.0);
  stroke(255);
  line(600, 50, 600, 550);
  line(50, 450, 550, 450);

  //weather
  textSize(50);
  text(temp, 120, 520);
  text(hum, 480, 520);
  image(cloud, 300, 520);

  //spotify
  image(spotify, 800, 80);
  
  textAlign(LEFT, CENTER);
  textSize(20);
  text(track, 650, 480);
  text(artist, 650, 510);
  text(album, 650, 540);
  if (sc != (second()/10)) {

    sc = (second()/10);
    if (getPlayer()) { // get track info every 10s
      if (lName != track) { // if track has changed reload artwork
        lName = track;
        art = loadImage(url, "png");
        image(art, 800, 300);
      }
    }
  }
}

String getTime() {
  int h = hour();
  int m = minute();

  String tm = "";
  if (h < 10) {
    tm += "0" + h;
  } else {
    tm += str(h);
  }
  if (m < 10) {
    tm += ":0" + m;
  } else {
    tm += ":"+str(m);
  }
  return tm;
}

void getWeather() {
  GetRequest get = new GetRequest(weatherUrl);
  get.send();
  //println("Reponse Content: " + get.getContent());
  JSONObject json = parseJSONObject(get.getContent());
  if (json == null) {
    return;
  }
  temp = str(int(json.getJSONObject("main").getFloat("temp"))) + "°C";
  hum = str(int(json.getJSONObject("main").getFloat("humidity"))) + "%";
  desc = json.getJSONArray("weather").getJSONObject(0).getString("main");
}


boolean getPlayer() {
  GetRequest http = new GetRequest("https://api.spotify.com/v1/me/player");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Accept", "application/json");
  http.addHeader("Authorization", "Bearer " + token);
  http.send();

  //println(http.getContent());

  JSONObject json = parseJSONObject(http.getContent());
  if (json == null) {
    return false;
  }

  String type = json.getString("currently_playing_type");
  if (type == "ad") {
    return false;
  }
  if (json.getJSONObject("item") != null) {

    track = json.getJSONObject("item").getString("name");
    album = json.getJSONObject("item").getJSONObject("album").getString("name");
    artist = "";

    JSONArray arr = json.getJSONObject("item").getJSONArray("artists");

    for (int i = 0; i < arr.size(); i++) {
      JSONObject ob = arr.getJSONObject(i);
      artist += ob.getString("name") + " ";
    }

    url = json.getJSONObject("item").getJSONObject("album").getJSONArray("images").getJSONObject(1).getString("url");
    return true;
  }
  return false;
}
