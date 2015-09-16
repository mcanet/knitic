
void setupSettings() {
  json = loadJSONObject("data/settings.json");
}

void saveUSBSelected(String devicePath) {
  println("save:"+devicePath);
  json.setString("usbDevice", devicePath);
  saveJSONObject(json, "data/settings.json");
}

void saveModelSelected(String machineType) {
  println("save:"+machineType);
  json.setString("kniticModel", machineType);
  saveJSONObject(json, "data/settings.json");
}

void saveKnittingType(String knittingType) {
  println("save:"+knittingType);
  json.setString("knittingType", knittingType);
  saveJSONObject(json, "data/settings.json");
}

String getKnittingType(){
  return json.getString("knittingType");
}

String getUSBSelected() {
  return json.getString("usbDevice");
}

String getMachineMode() {
  return json.getString("kniticModel");
}
