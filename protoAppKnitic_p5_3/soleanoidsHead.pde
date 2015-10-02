/*
void checkNotOnSolenoidsForLongTime() {
  // Check if the head did move
  if (stitch !=_lastStitch) {
    _lastStitch = stitch;
    lastSolenoidChange = millis();
  }
  // Check if the solenoids stay on for more than a minute
  if (millis()-lastSolenoidChange>60000 && _16Solenoids !="00000000000000" && isPatternOnKnitting() ) {
    headDownSelenoid = true;
    sendSerial16();
    try {
      JOptionPane.showMessageDialog(frame, "The carriage is left without finish line and can heat up solenoid. Accept and continue knitting.", "Alert from Knitic", 2);
      lastSolenoidChange = millis();
    }
    catch(Exception e) {
    }
  }
  else {
    headDownSelenoid = false;
  }
}
*/
