
void setupSettings() {
  json = loadJSONObject("data/settings.json");
  String usb = json.getString("usbDevice");
  String machine = json.getString("kniticModel");
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

String getUSBSelected() {
  return json.getString("usbDevice");
}

String getMachineMode() {
  return json.getString("kniticModel");
}
