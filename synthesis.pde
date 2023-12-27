import controlP5.*;
import beads.*;
import java.util.Arrays; 

AudioContext ac;

int waveCount = 20;
float baseFrequency = 440.0;
Buffer CosineBuffer = new CosineBuffer().getDefault();

// Array of Glide UGens for series of harmonic frequencies for each wave type (fundamental wave, square, triangle, sawtooth)
Glide[] waveFrequency = new Glide[waveCount];
// Array of Gain UGens for harmonic frequency series amplitudes (i.e. baseFrequency + (1/3)*(baseFrequency*3) + (1/5)*(baseFrequency*5) + ...)
Gain[] waveGain = new Gain[waveCount];
Gain masterGain;
Glide masterGainGlide;
// Array of wave wave generator UGens - will be summed by masterGain to additively synthesize square, triangle, sawtooth waves
WavePlayer[] waveTone = new WavePlayer[waveCount];

void setup() {
  size(400,400);
  
  float waveIntensity = 1.0;
  ac = new AudioContext();
  
  masterGainGlide = new Glide(ac, .2, 200);  
  masterGain = new Gain(ac, 1, masterGainGlide);
  ac.out.addInput(masterGain);

  // create a UGen graph to synthesize a square wave from a base/fundamental frequency and 9 odd harmonics with amplitudes = 1/n
  // square wave = base freq. and odd harmonics with intensity decreasing as 1/n
  // square wave = baseFrequency + (1/3)*(baseFrequency*3) + (1/5)*(baseFrequency*5) + ...
    
  for( int i = 0, n = 1; i < waveCount; i++, n++) {
    // create the glide that will control this WavePlayer's frequency
    // create an array of Glides in anticipation of connecting them with ControlP5 sliders
    waveFrequency[i] = new Glide(ac, baseFrequency * n, 200);
    
    // Create harmonic frequency WavePlayer - i.e. baseFrequency * 3, baseFrequency * 5, ...
    //waveTone[i] = new WavePlayer(ac, waveFrequency[i], CosineBuffer);
    waveTone[i] = new WavePlayer(ac, waveFrequency[i], Buffer.SINE);
    
    // Create gain coefficients for each harmonic - i.e. 1/3, 1/5, 1/7, ...
    waveIntensity = n == 1 ? 1.0 : 0; // fundamental only
    // For a square wave, we only want odd harmonics, so set all even harmonics to 0 gain/intensity
    //waveIntensity = (n % 2 == 1) ? (float) (1.0 / n) : 0; // square
    //waveIntensity = (n % 2 == 1) ? 1.0 / sq(n) : 0; // triangle
    //waveIntensity = 1.0 / n; // sawtooth
    
    println(n, ": ", waveIntensity, " * ", baseFrequency * n);
    
    waveGain[i] = new Gain(ac, 1, waveIntensity); // create the gain object
    waveGain[i].addInput(waveTone[i]); // then connect the waveplayer to the gain
  
    // finally, connect the gain to the master gain
    // masterGain will sum all of the wave waves, additively synthesizing a square wave tone
    masterGain.addInput(waveGain[i]);
  }
  
  // Reset WavePlayers and Gain coefficients to play triangle wave
  triangleWave();
  
  ac.start();
}

public void triangleWave() {
  float waveIntensity;

  for( int i = 0, n = 1; i < waveCount; i++, n++) {
    // triangle wave is a sum of Cosine WavePlayers
    waveTone[i].setBuffer(CosineBuffer);
    // fundamental, square and sawtooth should use Sine WavePlayers, so
    // waveTone[i].setBuffer(Buffer.SINE);
    
    // Create gain for each harmonic - i.e. 1/3, 1/5, 1/7, ...
    // For a triangle wave, we only want odd harmonics, so set all even harmonics to 0 gain/intensity
    waveIntensity = (n % 2 == 1) ? 1.0 / sq(n) : 0; // triangle
    
    println(n, ": ", waveIntensity, " * ", baseFrequency * n);
    
    waveGain[i].setGain(waveIntensity); // set gain for each harmonic
  }
}

// Oscilliscope trace
void drawWaveform() {
  fill (0, 32, 0, 32);
  rect (0, 0, width, height);
  stroke (32);
  for (int i = 0; i < 11 ; i++){
    line (0, i*75, width, i*75);
    line (i*75+25, 0, i*75+25, height);
  }
  stroke (0);
  line (width/2, 0, width/2, height);
  line (0, height/2, width, height/2);
  stroke (128,255,128);
  int crossing=0;
  // draw the waveforms so we can see what we are monitoring
  for(int i = 0; i < ac.getBufferSize() - 1 && i<width+crossing; i++)
  {
    if (crossing==0 && ac.out.getValue(0, i) < 0 && ac.out.getValue(0, i+1) > 0) crossing=i;
    if (crossing!=0) {
      line( i-crossing, height/2 + ac.out.getValue(0, i)*300, i+1-crossing, height/2 + ac.out.getValue(0, i+1)*300 );
    }
  }
}

void draw() {
  drawWaveform();
}
