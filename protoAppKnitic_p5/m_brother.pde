class m_brother{
ArrayList<String> knittingTypeListName;
int passDoubleBed;
m_brother(){
  setupKnittingType();
  passDoubleBed = 0;
}

 
void setupKnittingType(){
  knittingTypeListName = new ArrayList<String>();
  knittingTypeListName.add("Single bed");
  knittingTypeListName.add("Double bed - 2 colors");
  knittingTypeListName.add("Double bed - 3 colors");
}

int getIDKnittingTypeSelected(){
  int out = 0;
  for(int i=0;i<knittingTypeListName.size();i++){
    if(knittingTypeListName.get(i).equals(knittingTypeList.getCaptionLabel().getText())){
      out = i;
    }
  }
  return out;
}

void resetPassDoubleBed(){
  passDoubleBed = 0;
}

void nextPassDoubleBed(){
  passDoubleBed+=1;
  if(passDoubleBed==4) passDoubleBed=0;
}

int getPassDoubleBed(){
  return passDoubleBed;
}

void jumpToRow(){
  resetPassDoubleBed();
}

}
