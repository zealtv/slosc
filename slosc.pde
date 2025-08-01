import ddf.minim.*;
import ddf.minim.analysis.*;

// Audio variables
Minim minim;
AudioInput in;
AudioBuffer buffer;

// Customizable variables
color scopeColor = color(0, 255, 0);      // Green scope line
color backgroundColor = color(0, 0, 0);    // Black background
float timeWindow = 1000;                   // Time window in milliseconds
float amplitude = 500;                     // Amplitude scaling

// Display variables
ArrayList<Float> waveform;
int maxSamples;
int currentIndex = 0;

void setup() {
  size(800, 600);
  
  // Initialize audio
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 1024);
  
  // Calculate max samples based on time window
  maxSamples = int(timeWindow * in.sampleRate() / 1000000);
  waveform = new ArrayList<Float>();
  
  // Initialize waveform array
  for (int i = 0; i < maxSamples; i++) {
    waveform.add(0.0);
  }
}

void draw() {
  background(backgroundColor);
  
  // Capture audio samples
  captureAudio();
  
  // Draw oscilloscope
  drawScope();
  
  // Draw info text
  //drawInfo();
}

void captureAudio() {
  // Add new sample to waveform
  if (in.bufferSize() > 0) {
    float sample = in.mix.get(0);
    waveform.set(currentIndex, sample);
    currentIndex = (currentIndex + 1) % maxSamples;
  }
}

void drawScope() {
  stroke(scopeColor);
  strokeWeight(5);
  noFill();
  
  beginShape();
  
  float centerY = height / 2;
  float xStep = (float)width / maxSamples;
  
  for (int i = 0; i < maxSamples; i++) {
    int sampleIndex = (currentIndex + i) % maxSamples;
    float sample = waveform.get(sampleIndex);
    float x = i * xStep;
    float y = centerY + sample * amplitude;
    
    vertex(x, y);
  }
  
  endShape();
  
  // Draw center line
  stroke(red(scopeColor), green(scopeColor), blue(scopeColor), 50);
  strokeWeight(1);
  line(0, centerY, width, centerY);
}

void drawInfo() {
  fill(255);
  textAlign(LEFT);
  textSize(12);
  
  text("Time Window: " + timeWindow + "ms", 10, 20);
  text("Amplitude: " + amplitude, 10, 35);
  text("Press 'r' to change scope color", 10, 55);
  text("Press 'b' to change background color", 10, 70);
  text("Press UP/DOWN to adjust time window", 10, 85);
  text("Press LEFT/RIGHT to adjust amplitude", 10, 100);
}

void keyPressed() {
  switch(key) {
    case 'r':
    case 'R':
      // Cycle through scope colors
      if (scopeColor == color(0, 255, 0)) {
        scopeColor = color(255, 0, 0);     // Red
      } else if (scopeColor == color(255, 0, 0)) {
        scopeColor = color(0, 0, 255);     // Blue
      } else if (scopeColor == color(0, 0, 255)) {
        scopeColor = color(255, 255, 0);   // Yellow
      } else if (scopeColor == color(255, 255, 0)) {
        scopeColor = color(255, 0, 255);   // Magenta
      } else if (scopeColor == color(255, 0, 255)) {
        scopeColor = color(0, 255, 255);   // Cyan
      } else {
        scopeColor = color(0, 255, 0);     // Back to green
      }
      break;
      
    case 'b':
    case 'B':
      // Cycle through background colors
      if (backgroundColor == color(0, 0, 0)) {
        backgroundColor = color(30, 30, 30);   // Dark gray
      } else if (backgroundColor == color(30, 30, 30)) {
        backgroundColor = color(0, 0, 50);     // Dark blue
      } else if (backgroundColor == color(0, 0, 50)) {
        backgroundColor = color(0, 20, 0);     // Dark green
      } else {
        backgroundColor = color(0, 0, 0);      // Back to black
      }
      break;
  }
  
  // Handle special keys
  if (key == CODED) {
    switch(keyCode) {
        
      case LEFT:
        amplitude = constrain(amplitude - 20, 50, 500);
        break;
        
      case RIGHT:
        amplitude = constrain(amplitude + 20, 50, 500);
        break;
    }
  }
}

void stop() {
  in.close();
  minim.stop();
  super.stop();
}
