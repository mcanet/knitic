
void setupSettings() {
  json = loadJSONObject("data/settings.json");
}

void saveUSBSelected(String devicePath) {
  println("save:"+devicePath);
  json.setString("usbDevice", devicePath);
  saveJSONObject(json, "data/settings.json");
}

void saveModelSelected() {
  println("save:"+machineList.getCaptionLabel().getText());
  json.setString("kniticModel", machineList.getCaptionLabel().getText());
  saveJSONObject(json, "data/settings.json");
}

void saveKnittingType() {
  println("save:"+knittingTypeList.getCaptionLabel().getText());
  json.setString("knittingType", knittingTypeList.getCaptionLabel().getText());
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
