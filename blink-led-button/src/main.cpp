#include "application.h"

#define BUTTON D2
#define LED D7
#define FLASH_DURATION 5000

#define BUTTON_PRESSED(value) (value == LOW)
#define LED_FLASHING(state) (state == FLASHING)

typedef enum {
  FLASHING,
  NOT_FLASHING,
} state_t;

uint32_t wait_remain = 0;
uint32_t led_state = LOW;
state_t state = NOT_FLASHING;

void led_set(uint32_t value) {
  digitalWrite(LED, value);
  led_state = value;
}

void setup() {
  pinMode(BUTTON, INPUT_PULLUP);
  pinMode(LED, OUTPUT);
  led_set(LOW);
}

void loop() {
  int32_t value = digitalRead(BUTTON);

  if (LED_FLASHING(state)) {
    if (wait_remain > FLASH_DURATION / 2) {
      if (led_state == LOW)
        led_set(HIGH);
    } else {
      if (led_state == HIGH)
        led_set(LOW);
    }
  } else {
    if (led_state == HIGH)
      led_set(LOW);
  }

  if (wait_remain > 0)
    wait_remain -= 1;
  else if (LED_FLASHING(state))
    wait_remain = FLASH_DURATION;

  if (BUTTON_PRESSED(value) && !LED_FLASHING(state)) {
    wait_remain = FLASH_DURATION;
    state = FLASHING;
  } else if (!BUTTON_PRESSED(value)) {
    state = NOT_FLASHING;
  }
}
