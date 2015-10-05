import ddf.minim.*;

Minim minim;
AudioSample ready;
AudioSample sent;
AudioSample done;
AudioSample reset;
AudioSample error;

void setupAudio(){
  minim = new Minim(this);
  ready = minim.loadSample("ready.aif", 512);
  sent = minim.loadSample("sent.aif", 512);
  done = minim.loadSample("done.aif", 1024);
  reset = minim.loadSample("reset.aif", 1024);  
  error = minim.loadSample("error.aif", 512);
}
