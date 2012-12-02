// first line of the file should be the column headers
// first column should be the row titles
// all other values are expected to be floats
// getFloat(0, 0) returns the first data value in the upper lefthand corner
// files should be saved as "text, tab-delimited"
// empty rows are ignored
// extra whitespace is ignored
int NUMSTEPS = 60;

class Integrator {

  float _value, _start, _target;
  int _t;
  
  final int NUM_STEPS = NUMSTEPS;
  final float STEP_SIZE = 1.0 / (float)(NUM_STEPS);
  float _normalization;

  boolean _targeting;

  Integrator(float value) {
    _value = value;
    _t = 0;
    
    // compute the normalization variable
    float total = 0.0;
    for ( int i = 0; i <= NUM_STEPS; i++ ) {
      total += f( (float)i*STEP_SIZE );
    }
    _normalization = 1.0/total;
  }
  
  float f( float x ) {
   return (1.0 - (2.0*x-1.0)*(2.0*x-1.0)); 
   //return 1.0;
  }

  void update() {
    if ( _targeting ) {
      _value += f( (float)_t*STEP_SIZE )*_normalization*( _target - _start );
      ++_t;
      
      if ( _t > NUM_STEPS ) {
        noTarget();
      }
    }    
  }

  float value() {
    return _value; }

  void target(float t) {
    _start = _value;
    _t = 0;
    _targeting = true;
    _target = t;
  }


  void noTarget() {
    _targeting = false;
  }
}

class ColorIntegrator {

  color _value, _start, _target;
  int _t;
  float _time;
  
  final int NUM_STEPS = NUMSTEPS;
  final float STEP_SIZE = 1.0 / (float)(NUM_STEPS);
  float _normalization;

  boolean _targeting;

  ColorIntegrator(color value) {
    _value = value;
    _t = 0;
    _time = 0.0;
    
    // compute the normalization variable
    float total = 0.0;
    for ( int i = 0; i <= NUM_STEPS; i++ ) {
      total += f( (float)i*STEP_SIZE );
    }
    _normalization = 1.0/total;
  }
  
  float f( float x ) {
   return (1.0 - (2.0*x-1.0)*(2.0*x-1.0)); 
   //return 1.0;
  }

  void update() {
    if ( _targeting ) {
      //_value += color(f( (float)_t*STEP_SIZE )*_normalization*( _target - _start ));
      _time += f( (float)_t*STEP_SIZE )*_normalization;
      _value = lerpColor( _start, _target, _time );
      ++_t;
      
      if ( _t > NUM_STEPS ) {
        noTarget();
      }
    }    
  }

  color value() {
    return _value; }

  void target(color t) {
    _start = _value;
    _t = 0;
    _targeting = true;
    _target = t;
    _time = 0.0;
  }


  void noTarget() {
    _targeting = false;
  }
}

class FloatTable {
  int rowCount;
  int columnCount;
  float[][] data;
  String[] rowNames;
  String[] columnNames;
  
  
  FloatTable(String filename) {
    String[] rows = loadStrings(filename);
    
    String[] columns = split(rows[0], TAB);
    columnNames = subset(columns, 1); // upper-left corner ignored
    scrubQuotes(columnNames);
    columnCount = columnNames.length;

    rowNames = new String[rows.length-1];
    data = new float[rows.length-1][];

    // start reading at row 1, because the first row was only the column headers
    for (int i = 1; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }

      // split the row on the tabs
      String[] pieces = split(rows[i], TAB);
      scrubQuotes(pieces);
      
      // copy row title
      rowNames[rowCount] = pieces[0];
      // copy data into the table starting at pieces[1]
      data[rowCount] = parseFloat(subset(pieces, 1));

      // increment the number of valid rows found so far
      rowCount++;      
    }
    // resize the 'data' array as necessary
    data = (float[][]) subset(data, 0, rowCount);
  }
  
  
  void scrubQuotes(String[] array) {
    for (int i = 0; i < array.length; i++) {
      if (array[i].length() > 2) {
        // remove quotes at start and end, if present
        if (array[i].startsWith("\"") && array[i].endsWith("\"")) {
          array[i] = array[i].substring(1, array[i].length() - 1);
        }
      }
      // make double quotes into single quotes
      array[i] = array[i].replaceAll("\"\"", "\"");
    }
  }
  
  
  int getRowCount() {
    return rowCount;
  }
  
  
  String getRowName(int rowIndex) {
    return rowNames[rowIndex];
  }
  
  
  String[] getRowNames() {
    return rowNames;
  }

  
  // Find a row by its name, returns -1 if no row found. 
  // This will return the index of the first row with this name.
  // A more efficient version of this function would put row names
  // into a Hashtable (or HashMap) that would map to an integer for the row.
  int getRowIndex(String name) {
    for (int i = 0; i < rowCount; i++) {
      if (rowNames[i].equals(name)) {
        return i;
      }
    }
    //println("No row named '" + name + "' was found");
    return -1;
  }
  
  
  // technically, this only returns the number of columns 
  // in the very first row (which will be most accurate)
  int getColumnCount() {
    return columnCount;
  }
  
  
  String getColumnName(int colIndex) {
    return columnNames[colIndex];
  }
  
  
  String[] getColumnNames() {
    return columnNames;
  }


  float getFloat(int rowIndex, int col) {
    // Remove the 'training wheels' section for greater efficiency
    // It's included here to provide more useful error messages
    
    // begin training wheels
    if ((rowIndex < 0) || (rowIndex >= data.length)) {
      throw new RuntimeException("There is no row " + rowIndex);
    }
    if ((col < 0) || (col >= data[rowIndex].length)) {
      throw new RuntimeException("Row " + rowIndex + " does not have a column " + col);
    }
    // end training wheels
    
    return data[rowIndex][col];
  }
  
  
  boolean isValid(int row, int col) {
    if (row < 0) return false;
    if (row >= rowCount) return false;
    //if (col >= columnCount) return false;
    if (col >= data[row].length) return false;
    if (col < 0) return false;
    return !Float.isNaN(data[row][col]);
  }
  
  
  float getColumnMin(int col) {
    float m = Float.MAX_VALUE;
    for (int i = 0; i < rowCount; i++) {
      if (!Float.isNaN(data[i][col])) {
        if (data[i][col] < m) {
          m = data[i][col];
        }
      }
    }
    return m;
  }

  
  float getColumnMax(int col) {
    float m = -Float.MAX_VALUE;
    for (int i = 0; i < rowCount; i++) {
      if (isValid(i, col)) {
        if (data[i][col] > m) {
          m = data[i][col];
        }
      }
    }
    return m;
  }

  
  float getRowMin(int row) {
    float m = Float.MAX_VALUE;
    for (int i = 0; i < columnCount; i++) {
      if (isValid(row, i)) {
        if (data[row][i] < m) {
          m = data[row][i];
        }
      }
    }
    return m;
  } 

  
  float getRowMax(int row) {
    float m = -Float.MAX_VALUE;
    for (int i = 1; i < columnCount; i++) {
      if (!Float.isNaN(data[row][i])) {
        if (data[row][i] > m) {
          m = data[row][i];
        }
      }
    }
    return m;
  }
  
  
  float getTableMin() {
    float m = Float.MAX_VALUE;
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < columnCount; j++) {
        if (isValid(i, j)) {
          if (data[i][j] < m) {
            m = data[i][j];
          }
        }
      }
    }
    return m;
  }

  
  float getTableMax() {
    float m = -Float.MAX_VALUE;
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < columnCount; j++) {
        if (isValid(i, j)) {
          if (data[i][j] > m) {
            m = data[i][j];
          }
        }
      }
    }
    return m;
  }
}

FloatTable data;
float datamin, datamax;

float pltx1, plty1;
float pltx2, plty2;
float labelx, labely;

int currentColumn = 0;
int columnCount;
int rowCount;

int yearmin, yearmax;
int[] years;

PFont plotFont, plotFontVerdana, plotFontGeorgia;
int yearInterval = 10;
int volumeInterval = 10;

int volumeIntervalMinor = 5;
float barWidth = 4;
int displayType = 1;

float[] tabLeft, tabRight;
float tabTop, tabBottom;
float tabPad = 10;

Integrator[] interpolators;

boolean summary;
int[] colorlist = {#FF0000, #0000A0, #008000};

void setup()
{
  size(720, 405);
  data = new FloatTable("milk-tea-coffee.tsv");
  columnCount = data.getColumnCount();
  rowCount = data.getRowCount();
  years = int(data.getRowNames());
  yearmin = years[0];
  yearmax = years[years.length - 1];
  
  datamin = 0;
  datamax = ceil(data.getTableMax() / volumeInterval) * volumeInterval;
 
  interpolators = new Integrator[rowCount];
  for (int row = 0; row < rowCount; row++)
  {
    float initialValue = data.getFloat(row, 0);
    interpolators[row] = new Integrator(initialValue);
    //interpolators[row]._normalization = 0.1;
  }
  
  pltx1 = 120;
  pltx2 = width - 80;
  labelx = 50;
  plty1 = 60;
  plty2 = height - 70;
  labely = height - 25;
  
  plotFont = createFont("SansSerif", 20);
  plotFontVerdana = createFont("Verdana", 20);
  plotFontGeorgia = createFont("Georgia", 20);
  
  
  smooth();
}

void draw()
{
  background(224);
  
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(pltx1, plty1, pltx2, plty2);
  textFont(plotFontVerdana);
  drawTitle(summary);
  drawAxisLabels();
  drawTitleTabs(summary);
 
  for(int row = 0; row < rowCount; row++)
  {
    interpolators[row].update();
  }
  textFont(plotFontGeorgia);  
  
  if(summary)
  {
    noFill();
    strokeWeight(2);
    for(int col = 0; col < columnCount; col++)
    {
      beginShape();
      stroke(colorlist[col]);
      drawDataCurve(col);
      drawDataHighlight(col);
      endShape();
    }
    textFont(plotFontGeorgia);
    drawVolumeLabels(); 
    drawYearLabels();
  }
  else
  {
  if(displayType == 1)
  {
    stroke(#5679C1);
    strokeWeight(5);
    drawDataPoints(currentColumn);
    drawYearLabels();
  }
  else if(displayType == 2)
  {
    stroke(#5679C1);
    noFill();
    strokeWeight(2);
    drawDataLine(currentColumn);
    drawYearLabels();
  }
  else if(displayType == 3)
  {
    stroke(#5679C1);
    noFill();
    strokeWeight(2);
    drawDataCurve(currentColumn);
    drawYearLabels();
  }
  else if(displayType == 4)
  {
    noStroke();
    fill(#5679C1);
    drawDataArea(currentColumn);
    drawYearLabels();
  }
  else if(displayType == 5)
  {
    drawYearLabels();
    noStroke();
    fill(#5679C1);
    drawDataBars(currentColumn);
  }
  textFont(plotFontGeorgia);
  drawDataHighlight(currentColumn);
  }
}

void drawDataCurve(int col)
{
  beginShape();
  for(int row = 0; row < rowCount; row++)
  {
    if (data.isValid(row, col))
    {
      float value = data.getFloat(row, col);
      //float value = interpolators[row].value();
      float x = map(years[row], yearmin, yearmax, pltx1, pltx2);
      float y = map(value, datamin, datamax, plty2, plty1);
      
      curveVertex(x, y);
      if((row == 0) || (row == rowCount - 1))
      {
        curveVertex(x, y);
      }
    }
  }
  endShape();
}

void drawTitle(boolean summary)
{
  fill(0);
  textSize(20);
  textAlign(LEFT);
  String title;
  if(summary)
  {
    title = "Summary";
  }
  else
  {
    title = data.getColumnName(currentColumn);
  }
  text(title, pltx1, plty1 - 10);
}

void drawAxisLabels()
{
  fill(0);
  textSize(13);
  textLeading(15);
  pushMatrix();
  translate(labelx, (plty1+plty2)/2);
  rotate(4.7123);
  textAlign(CENTER, CENTER);
  text("Gallons\nconsumed\nper capita", 0, 0);
  popMatrix();
  textAlign(CENTER);
  text("Year", (pltx1+pltx2)/2, labely);
}

void drawDataPoints(int col)
{
  int rowCount = data.getRowCount();
  for (int row = 0; row < rowCount; row++)
  {
    if(data.isValid(row, col))
    {
      float value = data.getFloat(row, col);
      //float value = interpolators[row].value();
      float x = map(years[row], yearmin, yearmax, pltx1, pltx2);
      float y = map(value, datamin, datamax, plty2, plty1);
      point(x, y);
    }
  }
}

void drawDataLine(int col)
{
  beginShape();
  int rowCount = data.getRowCount();
  for (int row = 0; row < rowCount; row++)
  {
    if(data.isValid(row, col))
    {
      float value = data.getFloat(row, col);
      //float value = interpolators[row].value();
      float x = map(years[row], yearmin, yearmax, pltx1, pltx2);
      float y = map(value, datamin, datamax, plty2, plty1);
      vertex(x, y);
    }
  }
  endShape();
}

void keyPressed()
{
  if (key == '[')
  {
    currentColumn--;
    if(currentColumn < 0)
    {
      if(summary)
      {
        currentColumn = columnCount - 1;
        summary = false;
      }
      else
      {
        currentColumn++;
        summary = true;
      }
    }
    else
    {
      summary = false;
    }
  }
  else if(key == ']')
  {
    currentColumn++;
    if(currentColumn == columnCount)
    {
      if(summary)
      {
        summary = false;
        currentColumn = 0;
      }
      else
      {
        summary = true;
        currentColumn--;
      }
    }
    else
    {
      summary = false;
    }
  }
  else if(key == '1')
  {
    displayType =1;
    summary = false;
  }
  else if(key == '2')
  {
    displayType =2;
    summary = false;
  }
  else if(key == '3')
  {
    displayType =3;
    summary = false;
  }
  else if(key == '4')
  {
    displayType =4;
    summary = false;
  }
  else if(key == '5')
  {
    displayType =5;
    summary = false;
  } 
}

void drawYearLabels()
{
  fill(0);
  textSize(10);
  textAlign(10);
  textAlign(CENTER, TOP);
  stroke(224);
  strokeWeight(1);
  
  int rowCount = data.getRowCount();
  for (int row = 0; row < rowCount; row++)
  {
    if (years[row] % yearInterval == 0)
    {
      float x = map(years[row], yearmin, yearmax, pltx1, pltx2);
      text(years[row], x, plty2 + 10);
      line(x, pltx1, x, plty1);
      line(x, pltx1, x, plty2);
    }
  }
}

void drawVolumeLabels()
{
  fill(0);
  textSize(10);
  stroke(128);
  strokeWeight(1);
  
  
  for (float v = datamin; v < datamax; v += volumeIntervalMinor)
  {
    float y = map(v, datamin, datamax, plty2, plty1);
    if (v % volumeInterval == 0)
    {
      if (v == datamin)
      {
          textAlign(RIGHT);
      }
      else if (v == datamax)
      {
        textAlign(RIGHT, TOP);
      }
      else
      {
        textAlign(RIGHT, CENTER);
      }
      text(floor(v), pltx1 - 10, y);
      line(pltx1 - 4, y, pltx1, y);
    }
    else
    {
      line(pltx1 - 2, y, pltx1, y);
    }
  }
}

void drawDataHighlight(int col)
{
  for(int row = 0; row < rowCount; row++)
  {
  if (data.isValid(row, col))
  {
    float value = data.getFloat(row, col);
    float x = map(years[row], yearmin, yearmax, pltx1, pltx2);
    float y =  map(value, datamin, datamax, plty2, plty1);
    if (dist(mouseX, mouseY, x, y)< 3)
    {
      strokeWeight(10);
      point(x, y);
      fill(0);
      textSize(10);
      fill(0);
      textSize(10);
      textAlign(CENTER);
      text(nf(value, 0, 2) + " (" + years[row] + ")", x, y-8);
    }
  }
  }
}



void drawDataArea(int col)
{
  beginShape();
  for(int row = 0; row < rowCount; row++)
  {
    if (data.isValid(row, col))
    {
      float value = data.getFloat(row, col);
      //float value = interpolators[row].value();
      float x = map(years[row], yearmin, yearmax, pltx1, pltx2);
      float y = map(value, datamin, datamax, plty2, plty1);
      vertex(x, y);
    }
  }
  vertex(pltx2, plty2);
  vertex(pltx1, plty2);
  endShape(CLOSE);
}

void drawDataBars(int col)
{
  noStroke();
  rectMode(CORNERS);
  for (int row = 0; row < rowCount; row++)
  {
  if (data.isValid(row, col))
  {
    float value = data.getFloat(row, col);
    //float value = interpolators[row].value();
    float x = map(years[row], yearmin, yearmax, pltx1, pltx2);
    float y = map(value, datamin, datamax, plty2, plty1);
    rect(x -barWidth/2, y, x+barWidth/2, plty2);
  }
  }
}

void drawTitleTabs(boolean summaryflag)
{
  rectMode(CORNERS);
  noStroke();
  textSize(20);
  textAlign(20);
  textAlign(LEFT);
  
  if (tabLeft == null)
  {
    tabLeft = new float[columnCount + 1];
    tabRight = new float[columnCount + 1];
  }
  
  float runningX = pltx1;
  tabTop = plty1 - textAscent() - 15;
  tabBottom = plty1;
  String title;
  for (int col = 0; col < columnCount + 1; col++)
  {
    if(col == columnCount)
    {
      title = "Summary";
    }
    else
    {
      title = data.getColumnName(col);
    }
    tabLeft[col] = runningX;
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] +tabPad + titleWidth + tabPad;
    
    if(summaryflag)
    {
      fill(col == columnCount ? 255 : 224);
      rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
      fill(col == columnCount ? 0 : colorlist[col]);
      text(title, runningX + tabPad, plty1 - 10);
    }
    else
    {
      fill(col == currentColumn ? 255 : 224);
      rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    
      fill(col == currentColumn ? 0 : 64);
      text(title, runningX + tabPad, plty1 - 10);
    }
    runningX = tabRight[col];
  }
}

void setCurrent(int col)
{
  if (col != currentColumn)
  {
    currentColumn = col;
  }
  for (int row = 0; row < rowCount; row++)
  {
    interpolators[row].target(data.getFloat(row, col));
  }
}

void mousePressed()
{
  if (mouseY > tabTop && mouseY < tabBottom)
  {
    for (int col = 0; col < columnCount + 1; col++)
    {
      if (mouseX > tabLeft[col] && mouseX < tabRight[col])
      {
        if (col == columnCount)
        {
          summary = true;
        }
        else
        {
          summary = false;
          setCurrent(col);
        }
      }
    }
  }
}
