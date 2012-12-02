// first line of the file should be the column headers
// first column should be the row titles
// all other values are expected to be floats
// getFloat(0, 0) returns the first data value in the upper lefthand corner
// files should be saved as "text, tab-delimited"
// empty rows are ignored
// extra whitespace is ignored


class FloatTable {
  int rowCount;
  int columnCount;
  float[][] data;
  String[] rowNames;
  String[] columnNames;
  
  
  FloatTable(String filename) {
    String[] rows = loadStrings(filename);
    
    String[] columns = split(rows[0], TAB);
    columnNames = columns; // upper-left corner ignored
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
      data[rowCount] = parseFloat(pieces);

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
int columnCount;
int rowCount;
float datamin, datamax;
float pltx1, plty1;
float pltx2, plty2;
float labelx, labely;
float x_interval;
float current_x1, current_x2;
float[][] coordinates;
float triangle_min, triangle_max, triangle_swap_min, triangle_swap_max;
boolean [] order_flags;
boolean [] row_flags;
int [] map_column;
float [] data_min_array;
float [] data_max_array;
int mouselock_X, mouselock_Y;
float [] triangle_min_min;
float [] triangle_min_max;
float [] triangle_max_min;
float [] triangle_max_max;
String [] cluster_names;
int num_clusters = 4;
int [] row_cluster;
int [] cluster_colors;
int aux_start;
boolean drag = false;
int available_colors = 5;
int [] color_list = new int[] {#0000FF, #009900, #FF0000, #0099CC, #CC00CC};

float [] color_assignee_x_min;
float [] color_assignee_x_max;
float [] color_assignee_y_min;
float [] color_assignee_y_max;

float [] color_recepient_x_min;
float [] color_recepient_x_max;
float [] color_recepient_y_min;
float [] color_recepient_y_max;

float [] clear_dimensions = new float[4];


void setup()
{
  size(1200, 600);
  //data = new FloatTable("cars_data.tsv");
  data = new FloatTable("camera_data.tsv");
  columnCount = data.getColumnCount();
  rowCount = data.getRowCount();
  
  coordinates = new float[columnCount][4];
  
  triangle_min_min = new float[columnCount];
  triangle_min_max = new float[columnCount];
  triangle_max_min = new float[columnCount];
  triangle_max_max = new float[columnCount];
  
  cluster_colors = new int[num_clusters];
  
  for(int ii = 0; ii < num_clusters; ii++)
  {
    cluster_colors[ii] = #000000;
  }
  
  row_cluster = new int[rowCount];
  
  for(int ii = 0; ii < rowCount; ii++)
  {
    row_cluster[ii] = 99;    
  }
  
  map_column = new int[columnCount];

  
  for (int col = 0; col < columnCount; col++)
  {
    map_column[col] = col;
  }
  
  data_min_array = new float[columnCount];
  data_max_array = new float[columnCount];
  
  for(int col = 0; col < columnCount; col++)
  {
    data_min_array[col] = data.getColumnMin(col);
    data_max_array[col] = data.getColumnMax(col);
  }
  
  order_flags = new boolean[columnCount];
  
  for(int col = 0; col < columnCount; col++)
  {
    order_flags[col] = false;
  }

  row_flags = new boolean[rowCount];  
  
  for(int row = 0; row < rowCount; row++)
  {
    row_flags[row] = true;
  }
  
  pltx1 = 30;
  pltx2 = width - 230;
  plty1 = 60;
  plty2 = height - 60;
  
  aux_start = width - 200;
  
  x_interval = ((pltx2 -10) - (pltx1 + 10)) / (columnCount - 1);
  current_x1 = pltx1 + 10;
  
  //Axes co-ordinates
  for(int i = 0; i < columnCount; i++)
  {
    coordinates[i][0] = current_x1;
    coordinates[i][1] = plty1 + 5;
    coordinates[i][2] = current_x1 + 5;
    coordinates[i][3] = plty2 - 5; 
    current_x1 = current_x1 + x_interval;
  }
  
  //k-means clustering
  clustering(num_clusters);  
  cluster_names = new String[num_clusters];
  for(int ii = 0; ii < num_clusters; ii++)
  {
    cluster_names[ii] = Integer.toString(ii);;
  }
  smooth();
}


void clustering(int k)
{
  int [] cluster_array = new int[k];
  //Choosing Random k means
  for(int ii = 0; ii < k; ii++)
 {   
   while(true)
   {
   boolean present_flag = false;
   int chosen_element = ceil(random(rowCount - 1));
   for(int jj =0; jj < k; jj++)
   {
     if(chosen_element == cluster_array[jj])
     {
       present_flag = true;
     }
   }
   if(!present_flag)
   {
     cluster_array[ii] = chosen_element;
     row_cluster[chosen_element] = ii;
     break;
   }
   }
 } 
 
 //Assignning initial means
 float [][] cluster_means = new float[k][columnCount];
 for(int ii = 0; ii < k; ii++)
 {
   for(int col = 0; col < columnCount; col++)
   {
     cluster_means[ii][col] = data.getFloat(cluster_array[ii], col);
   }
 }
 
 //Actual clustering by iterating on all the elements
 for(int looping = 0; looping < 1; looping++)
 {
 for(int row = 0; row < rowCount; row++)
 {
   //Ignoring the already chosen ones
   boolean present_flag = false;
   for(int ii = 0; ii < k; ii++)
   {
     if(row == cluster_array[ii])
     {
       present_flag = true;
       break;
     }     
   }
   if(present_flag)
   {
     continue;
   }
   //Finding the mean with the closest distance
   float smallest_distance = 10000000;
   int smallest_index = -1;
   
   for (int ii = 0; ii < k; ii++)
   {
     //calculate_distance
     float distance = 0;
     for(int col = 0; col < columnCount; col++)
     {
       float dista = cluster_means[ii][col] - data.getFloat(row, col);
       distance = distance + (dista * dista);
     }
     distance = sqrt(distance);
     if(distance < smallest_distance)
     {
       smallest_distance = distance;
       smallest_index = ii;
     }     
   }
   
   if(smallest_index == -1)
   {
     smallest_index = ceil(random(k - 1));
   }
      
   //Assigning a cluster
   row_cluster[row] = smallest_index;
 }
 
  for (int row = 0; row < k; row++)
  {
    for(int col =0 ; col< columnCount; col++)
    {
      cluster_means[row][col] = 0;
    }
  }
 
  for(int row = 0; row < rowCount; row++)
  {
    int cluster_index = row_cluster[row];
    //calculating new mean
    for (int col = 0; col < columnCount; col++)
    {
      cluster_means[cluster_index][col] = cluster_means[cluster_index][col] + data.getFloat(row, col);
    }
  }
  for(int row = 0; row < k; row++)
  {
    for(int col=0; col < columnCount; col++)
    {
     cluster_means[row][col] = cluster_means[row][col] / columnCount;
    }
  }
 }
}


void draw()
{
  background(120);
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(pltx1, plty1, pltx2, plty2);
  
  rectMode(CORNERS);
  stroke(#000000);
  noFill();
  strokeWeight(2);
  
  //Draw Coordinates
  for(int i = 0; i < columnCount; i++)
  {
    rect(coordinates[i][0], coordinates[i][1], coordinates[i][2], coordinates[i][3]);
    int col = map_column[i];
    textAlign(CENTER);
    textSize(13);
    textLeading(15);
    fill(255);
    if(order_flags[col])
    {
      text(ceil(data.getColumnMax(col)), coordinates[i][2] - 5, coordinates[i][1] - 20);
      text(ceil(data.getColumnMin(col)), coordinates[i][2] - 5, coordinates[i][3] + 20);     
    }
    else
    {
      text(ceil(data.getColumnMin(col)), coordinates[i][2] - 5, coordinates[i][1] - 20);
      text(ceil(data.getColumnMax(col)), coordinates[i][2] - 5, coordinates[i][3] + 20);
    }
    if (i % 2 == 0)
    {
      text(data.getColumnName(col), coordinates[i][2] - 5, coordinates[i][3] + 30);
    }
    else
    {
      text(data.getColumnName(col), coordinates[i][2] - 5, coordinates[i][3] + 50);
    }
  }
  
  //Draw lines
  
  noFill();
  stroke(#000000);
  strokeWeight(0.2);
  for(int row = 0; row < rowCount; row++)
  {
    //Update Row flags
    row_flags[row] = true;
    for(int col = 0; col < columnCount; col++)
    {
      int map_col = map_column[col];
      float data_min = data_min_array[map_col];
      float data_max = data_max_array[map_col];
      if(data_max < data_min)
      {
        float temp = data_min;
        data_min = data_max;
        data_max = temp;
      }
      float value = data.getFloat(row, map_col);
      row_flags[row] = row_flags[row] && (value >= data_min && value <= data_max);
    }
    if(row_flags[row])
    {
      strokeWeight(1);
    }
    else
    {
      strokeWeight(0);
    }
    int cluster_index = row_cluster[row];
    if(cluster_index == 99)
    {
      stroke(#000000);
    }
    else
    {
      stroke(cluster_colors[cluster_index]);
    }

    float y;
    beginShape();
    for(int col = 0; col < columnCount; col++)
    {
      int map_col = map_column[col];
      datamin = data.getColumnMin(map_col);
      datamax = data.getColumnMax(map_col);
      float value = data.getFloat(row, map_col);
      if (order_flags[map_col])
      {
        y = map(value, datamax, datamin, plty1 + 5, plty2 - 5);
      }
      else
      {
        y = map(value, datamin, datamax, plty1 + 5, plty2 - 5);
      }
      vertex(coordinates[col][0] + 2.5, y);
    }
    endShape();
  }
 
  //Triangles for Inverting the axes 
  for(int col = 0; col < columnCount; col ++)
  {
    int map_col = map_column[col];
    fill(0);
    if (order_flags[map_col])
    {
        triangle(coordinates[col][2] - 10, coordinates[col][3] + 50, coordinates[col][2], coordinates[col][3] + 50, coordinates[col][2] - 5, coordinates[col][3] + 60);
    }
    else
    {
        triangle(coordinates[col][2] - 5, coordinates[col][3] + 50, coordinates[col][2] - 10, coordinates[col][3] + 60, coordinates[col][2], coordinates[col][3] + 60);
    }
  }
  triangle_min = plty2 + 45;
  triangle_max = plty2 + 65;
    
  //Triangles for reordering the axes
  for (int col = 0; col < columnCount - 1; col ++)
  {
    fill(0);
    triangle(coordinates[col][2] + (x_interval / 2) - 10, coordinates[col][3] + 45, coordinates[col][2] + (x_interval / 2), coordinates[col][3] + 40, coordinates[col][2] + (x_interval / 2), coordinates[col][3] + 50);
    triangle(coordinates[col][2] + (x_interval / 2) + 10, coordinates[col][3] + 45, coordinates[col][2] + (x_interval / 2), coordinates[col][3] + 40, coordinates[col][2] + (x_interval / 2), coordinates[col][3] + 50);
  }
  
  triangle_swap_min = plty2 + 35;
  triangle_swap_max = plty2 + 55;
  
  //Triangles for defining ranges
  
  for (int col = 0; col < columnCount; col++)
  {
    int map_col = map_column[col];
    float relativemin_y = map(data_min_array[map_col], data.getColumnMin(map_col), data.getColumnMax(map_col), plty1 + 5, plty2 - 5);
    float relativemax_y = map(data_max_array[map_col], data.getColumnMin(map_col), data.getColumnMax(map_col), plty1 + 5, plty2 - 5);
    
    if(relativemin_y < plty1 + 5)
    {
      relativemin_y = plty1 + 5;
    }
    if(relativemax_y > plty2 - 5)
    {
      relativemax_y = plty2 - 5;
    }
    fill(0);
    if(!order_flags[map_col])
    {
      triangle(coordinates[col][2] - 5, relativemin_y, coordinates[col][2] - 12.5, relativemin_y - 5, coordinates[col][2] - 12.5, relativemin_y + 5);
      triangle(coordinates[col][2] - 5, relativemax_y, coordinates[col][2] - 12.5, relativemax_y - 5, coordinates[col][2] - 12.5, relativemax_y + 5);    
            
      triangle_min_min[map_col] = relativemin_y - 10;
      triangle_min_max[map_col] = relativemin_y + 10;
      triangle_max_min[map_col] = relativemax_y - 10;
      triangle_max_max[map_col] = relativemax_y + 10;
      
    }
    else
    {
      float y_len = (plty2 - 5) - (plty1 + 5);
      triangle(coordinates[col][2] - 5, plty2 - 5 - (relativemin_y - (plty1 + 5)), coordinates[col][2] - 12.5, plty2 - 5 - (relativemin_y - (plty1 + 5)) - 5, coordinates[col][2] - 12.5, plty2 - 5 - (relativemin_y - (plty1 + 5)) + 5);
      triangle(coordinates[col][2] - 5, plty2 - 5 - (relativemax_y - (plty1 + 5)), coordinates[col][2] - 12.5, plty2 - 5 - (relativemax_y - (plty1 + 5)) - 5, coordinates[col][2] - 12.5, plty2 - 5 - (relativemax_y - (plty1 + 5)) + 5);
      
      triangle_min_min[map_col] = plty2 - 5 - (relativemin_y - (plty1 + 5)) - 10;
      triangle_min_max[map_col] = plty2 - 5 - (relativemin_y - (plty1 + 5)) + 10;
      triangle_max_min[map_col] = plty2 - 5 - (relativemax_y - (plty1 + 5)) - 10;
      triangle_max_max[map_col] = plty2 - 5 - (relativemax_y - (plty1 + 5)) + 10;

    }
  }  
  
  color_assignee_x_min = new float[available_colors];
  color_assignee_x_max = new float[available_colors];
  color_assignee_y_min = new float[available_colors];
  color_assignee_y_max = new float[available_colors];

  color_recepient_x_min = new float[num_clusters];
  color_recepient_x_max = new float[num_clusters];
  color_recepient_y_min = new float[num_clusters];
  color_recepient_y_max = new float[num_clusters];  
  //Aux box with legend
  fill(255);
  rect(aux_start + 20, plty1 + 40, width - 20, plty2 - 40);
  float left_x = aux_start + 60;
  float text_x = aux_start + 40;
  float start_y = plty1 + 50;
  
  for(int ii = 0; ii < num_clusters; ii++)
  {
    if ((ii % 2) == 0)
    {
      textAlign(CENTER);
      textSize(13);
      textLeading(15);
      fill(0);
      text(cluster_names[ii], text_x, start_y + 15);
    }
    else
    {
      textAlign(CENTER);
      textSize(13);
      textLeading(15);
      fill(0);
      text(cluster_names[ii], text_x + 70, start_y + 15);
      start_y = start_y + 30;
    }
  }
  
  left_x = aux_start + 60;
  start_y = plty1 + 50; 
  
  fill(255);
  for(int ii = 0; ii < num_clusters; ii ++)
  {
    if ((ii % 2) == 0)
    {
      fill(cluster_colors[ii]);      
      rect(left_x, start_y, left_x + 20, start_y + 20);
      color_recepient_x_min[ii] = text_x;
      color_recepient_x_max[ii] = left_x + 20;
      color_recepient_y_min[ii] = start_y;
      color_recepient_y_max[ii] = start_y + 20;
    }
    else
    {      
      fill(cluster_colors[ii]);
      rect(left_x + 70, start_y, left_x + 90, start_y + 20);
      color_recepient_x_min[ii] = text_x + 70;
      color_recepient_x_max[ii] = left_x + 90;
      color_recepient_y_min[ii] = start_y;
      color_recepient_y_max[ii] = start_y + 20;
      start_y = start_y + 30;
    }
  }
  textAlign(CENTER);
  textSize(13);
  textLeading(15);
  fill(0);
  
  text("CLUSTERS", text_x + 55, start_y + 40);
  
  textAlign(CENTER);
  textSize(13);
  textLeading(15);
  fill(0);
  text("Available Colors", text_x + 60, start_y + 70);
  
  
  start_y = start_y + 80;
  for(int ii = 0; ii < available_colors; ii ++)
  {
    if ((ii % 2) == 0)
    {
      fill(color_list[ii]);
      stroke(color_list[ii]);
      rect(left_x, start_y, left_x + 20, start_y + 20);
      color_assignee_x_min[ii] = left_x;
      color_assignee_x_max[ii] = left_x + 20;
      color_assignee_y_min[ii] = start_y;
      color_assignee_y_max[ii] = start_y + 20;
    }
    else
    { 
      fill(color_list[ii]);     
      stroke(color_list[ii]);
      rect(left_x + 70, start_y, left_x + 90, start_y + 20);
      color_assignee_x_min[ii] = left_x + 70;
      color_assignee_x_max[ii] = left_x + 90;
      color_assignee_y_min[ii] = start_y;
      color_assignee_y_max[ii] = start_y + 20;
      start_y = start_y + 30;
    }
  }
  
  //Clear Box
  fill(255);
  stroke(0);
  rect(left_x + 10, start_y + 50, left_x + 70, start_y + 70);
  
  textAlign(CENTER);
  textSize(13);
  textLeading(15);
  fill(0);
  
  text("CLEAR", left_x + 40, start_y + 65);

  clear_dimensions[0] = left_x + 10;
  clear_dimensions[1] = start_y + 50;
  clear_dimensions[2] = left_x + 70;
  clear_dimensions[3] = start_y + 70;
}

void mousePressed()
{
  mouselock_X = mouseX;
  mouselock_Y = mouseY;
  //Axes flipping
  for(int col = 0; col < columnCount; col++)
  {
    int map_col = map_column[col];
    if (mouseY > triangle_min && mouseY < triangle_max)
   {
     if (mouseX > (coordinates[col][2] - 15) && mouseX < coordinates[col][2] + 5)
     {            
      order_flags[map_col] = !order_flags[map_col];    
     }
   }
  }
  
  //Reordering Axes
  for(int col = 1; col < columnCount; col++)
  {
    if (mouseY > triangle_swap_min && mouseY < triangle_swap_max)
    {
      if (mouseX > (coordinates[col - 1][2] + (x_interval / 2) - 15) && mouseX < (coordinates[col - 1][2] + (x_interval / 2) + 15))
      {
        int temp = map_column[col];
        map_column[col] = map_column[col - 1];
        map_column[col - 1] = temp;
      }
    } 
  }
  
  //Clear click
  if(mouseX >= clear_dimensions[0] && mouseY >= clear_dimensions[1] && mouseX <= clear_dimensions[2] && mouseY <= clear_dimensions[3])
  {
    for(int ii = 0; ii < num_clusters; ii++)
    {
      cluster_colors[ii] = #000000;
    }    
  }
}

void mouseDragged()
{
  drag = true;
  for(int col = 0; col < columnCount; col++)
  {
       int map_col = map_column[col];
       if(mouselock_X > (coordinates[col][0] - 10) && (mouselock_X < coordinates[col][0] + 10))
      {
          if(mouselock_Y > triangle_min_min[map_col] && mouselock_Y < triangle_min_max[map_col])
          {
            if(!order_flags[map_col])
            {
              data_min_array[map_col] = map(mouseY, plty1 + 5, plty2 - 5, data.getColumnMin(map_col), data.getColumnMax(map_col));      
            }
            else
            {
              data_min_array[map_col] = map(mouseY, plty2 - 5, plty1 + 5, data.getColumnMin(map_col), data.getColumnMax(map_col)); 
            }
          } 
      
          else if(mouselock_Y > triangle_max_min[map_col] && mouselock_Y < triangle_max_max[map_col])
          {
            if(!order_flags[map_col])
            {
              data_max_array[map_col] = map(mouseY, plty1 + 5, plty2 - 5, data.getColumnMin(map_col), data.getColumnMax(map_col));            
            }
            else
            {
              data_max_array[map_col] = map(mouseY, plty2 - 5, plty1 + 5, data.getColumnMin(map_col), data.getColumnMax(map_col));
            }
          }
       }               
  } 
}

void mouseReleased()
{
  if(drag)
  {
    for(int ii = 0; ii < available_colors; ii ++)
    {
      if(mouselock_X >= color_assignee_x_min[ii]  && mouselock_X <= color_assignee_x_max[ii] && mouselock_Y >= color_assignee_y_min[ii]  && mouselock_Y <= color_assignee_y_max[ii])
      {
        for(int jj = 0; jj < num_clusters; jj++)
        {
          if(mouseX >= color_recepient_x_min[jj]  && mouseX <= color_recepient_x_max[jj] && mouseY >= color_recepient_y_min[jj]  && mouseY <= color_recepient_y_max[jj])
          {
            cluster_colors[jj] = color_list[ii];
            break;
          }
        }
      }
    }   
    drag = false;
  }
}
