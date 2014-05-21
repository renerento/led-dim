/* Rotary encoder handler for arduino.
 *
 * Copyright 2011 Ben Buxton. Licenced under the GNU GPL Version 3.
 * Contact: bb@cactii.net
 *
 * Quick implementation of rotary encoder routine.
 *
 * More info: http://www.buxtronix.net/2011/10/rotary-encoders-done-properly.html
 *
 * Copyright 2014 Rene Rento. Licenced under the GNU GPL Version 3.
 * 
 * I just took the Ben´s encoder-part and included it to modified LCD-code found somewhere from the net. 
 * With this code one can dim LED with rotary encoder and an LCD shows current brightness in numerical value.
 * This code was made with Arduino version 0022.
 *
 * Contact:renerento@gmail.com       
 *
 * This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 General Public License for more details.
 
 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
 #include <LiquidCrystal.h>
// Half-step mode?
#define HALF_STEP
// Arduino pins the encoder is attached to. Attach the center to ground.
#define ROTARY_PIN1 10
#define ROTARY_PIN2 8
// define to enable weak pullups.
#define ENABLE_PULLUPS

#ifdef HALF_STEP
// Use the half-step state table (emits a code at 00 and 11)
const char ttable[6][4] = {
  {0x3 , 0x2, 0x1,  0x0}, {0x83, 0x0, 0x1,  0x0},
  {0x43, 0x2, 0x0,  0x0}, {0x3 , 0x5, 0x4,  0x0},
  {0x3 , 0x3, 0x4, 0x40}, {0x3 , 0x5, 0x3, 0x80}
};
#else
// Use the full-step state table (emits a code at 00 only)
const char ttable[7][4] = {
  {0x0, 0x2, 0x4,  0x0}, {0x3, 0x0, 0x1, 0x40},
  {0x3, 0x2, 0x0,  0x0}, {0x3, 0x2, 0x1,  0x0},
  {0x6, 0x0, 0x4,  0x0}, {0x6, 0x5, 0x0, 0x80},
  {0x6, 0x5, 0x4,  0x0},
};
#endif
volatile char state = 0;
int en = 0 ;
int muutos = 5;
// LCD=======================================================
//initialize the library with the numbers of the interface pins
LiquidCrystal lcd(13, 11, 5, 4, 1, 0);
#define LCD_WIDTH 40
#define LCD_HEIGHT 2
/* Call this once in setup(). */
void rotary_init() {
  pinMode(ROTARY_PIN1, INPUT);
  pinMode(ROTARY_PIN2, INPUT);
#ifdef ENABLE_PULLUPS
  digitalWrite(ROTARY_PIN1, HIGH);
  digitalWrite(ROTARY_PIN2, HIGH);
#endif
}
char rotary_process() {
  char pinstate = (digitalRead(ROTARY_PIN2) << 1) | digitalRead(ROTARY_PIN1);
  state = ttable[state & 0xf][pinstate];
  return (state & 0xc0);
}
void setup() {
  rotary_init();
  lcd.begin(LCD_WIDTH, LCD_HEIGHT,1);
  lcd.setCursor(10,0);
  lcd.print("LED Dimming Test");
  delay(1000);
  lcd.clear();
}
void loop() { 
  char result = rotary_process();
  if (result) {
         if (result == -128)
         {
          en = en - muutos;
          lcd.clear();
          lcd.setCursor(10,0);
          lcd.print(en);
          }
         else 
         {
         en = en + muutos;
         lcd.clear();
         lcd.setCursor(10,0);
          lcd.print(en);
         } 
        if (en > 255)
        {
         en = 255;
         lcd.clear();
         lcd.setCursor(10,0);
         lcd.print("Maximum value reached!");
        }
        if (en < 1)
       {
       en = 0;
       lcd.clear();
       lcd.setCursor(10,0);
       lcd.print("Minimum value reached!");
       }
analogWrite(3, en);
} 
}
