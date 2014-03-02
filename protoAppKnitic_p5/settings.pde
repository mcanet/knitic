
void setupSettings() {
  json = loadJSONObject("data/settings.json");
}

void saveUSBSelected() {
  println("save:"+usbList.getCaptionLabel().getText());
  json.setString("usbDevice", usbList.getCaptionLabel().getText());
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
