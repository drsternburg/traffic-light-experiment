# TrafficLight.py -
# MSK, 2018
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#
#

import pygame, os
from FeedbackBase.PygameFeedback import PygameFeedback
from __builtin__ import str
from collections import deque


class TrafficLight(PygameFeedback):


    def init(self):

        PygameFeedback.init(self)
        
        ########################################################################
        
        self.FPS = 200
        self.screenPos = [1280, 0]
        self.screenSize = [1280, 1024]
        self.screen_center = [self.screenSize[0]/2,self.screenSize[1]/2]
        self.caption = "TrafficLight"
        
        self.trafficlight_size = (self.screenSize[1]/6, self.screenSize[1]/2)
        self.trafficlight_states = ('','green','red','yellow','yellowgreen','yellowred')
        
        self.background_color = [127, 127, 127]
        self.text_fontsize = 75
        self.text_color = [64,64,64]
        self.char_fontsize = 100
        self.char_color = [0,0,0]
        
        self.prompt_text = 'Were you about to press?'
        self.pause_text = 'Pause. Press pedal to continue...'
        self.paused = True
        self.on_trial = False
        
        ########################################################################
        
        self.duration_light_yellow = 1000
        self.duration_light_redgreen = 1300
        self.duration_prompt = 1500
        self.duration_cross = 3000
        self.min_waittime = 1500
        
        self.marker_keyboard_press = 199
        self.marker_quit = 255
        self.marker_base_start = 10
        self.marker_base_interruption = 20
        self.marker_trial_end = 30
        self.marker_prompt = 40
        
        self.marker_identifier = {20 : 'move silent light',
                                  21 : 'move red light',
                                  22 : 'move green light',
                                  23 : 'idle red light',
                                  24 : 'idle green light',
                                  40 : 'prompt'}
        
        ########################################################################
        # MAIN PARAMETERS TO BE SET IN MATLAB
        
        self.listen_to_keyboard = 1
        self.make_interruptions = 1
        self.make_prompts = 0
        self.pause_every_x_events = 20
        self.end_after_x_events = 60
        self.end_pause_counter_type = 4 # 1 - button presses, 2 - move lights, 3 - idle lights, 4 - seconds
        self.bci_delayed_idle = 0
        self.trial_assignment = [4,3,4,3,4,3] # 1 - move red, 2 - move green, 3 - idle red, 4 - idle green
        self.ir_idle_waittime = [3000.0,3000.0,3000.0,3000.0,3000.0,3000.0]
        
        ########################################################################  


    def pre_mainloop(self):
        PygameFeedback.pre_mainloop(self)
        self.font_text = pygame.font.Font(None, self.text_fontsize)
        self.font_char = pygame.font.Font(None, self.char_fontsize)
        self.trial_counter = 0
        self.block_counter = 0
        self.move_counter = 0
        self.idle_counter = 0
        self.pedalpress_counter = 0
        self.time_recording_start = pygame.time.get_ticks() 
        if self.make_interruptions:
            self.queue_waittime = deque(self.ir_idle_waittime)
            self.queue_trial = deque(self.trial_assignment)
        self.reset_trial_states()
        self.load_images()
        self.on_pause()
        
        
    def reset_trial_states(self):
        self.time_trial_end = float('infinity')
        self.time_trial_start = float('infinity')
        self.yellow_until = float('infinity')
        self.redgreen_until = float('infinity')
        self.yellow_on = False
        self.redgreen_on = False
        self.already_interrupted = False
        self.already_interrupted_silent = False
        self.already_pressed = False
        self.this_prompt = False
        self.this_premature = False
        

    def post_mainloop(self):
        PygameFeedback.post_mainloop(self)
    
   
    def on_pause(self):
        self.log('Paused. Waiting for participant to continue...')
        self.time_trial_start = float('infinity')
        self.paused = True
        self.on_trial = False
    
    
    def unpause(self):
        self.log('Starting block '+str(self.block_counter+1))
        now = pygame.time.get_ticks()
        self.paused = False
        self.time_trial_end = now
        self.trial_counter -= 1 # ugly hack


    def tick(self):
        now = pygame.time.get_ticks()
        if self.listen_to_keyboard:
            self.on_keyboard_event()
        if not self.paused:
            if now > self.time_trial_end: # it's time to end trial
                # however, first check if we want to prompt
                if self.make_interruptions and self.make_prompts and not self.this_prompt and not self.already_pressed and self.already_interrupted and self.this_interruption_color=='red':
                    self.send_parallel_log(self.marker_prompt)
                    self.this_prompt = True
                    self.time_trial_end = now + self.duration_prompt
                elif self.make_interruptions and self.make_prompts and not self.this_prompt and self.already_pressed and self.already_interrupted and self.this_interruption_color=='green':
                    self.send_parallel_log(self.marker_prompt)
                    self.this_prompt = True
                    self.time_trial_end = now + self.duration_prompt
                else: # otherwise, end trial
                    self.on_trial = False
                    self.reset_trial_states()
                    self.trial_counter += 1
                    self.send_parallel(self.marker_trial_end)
                    self.time_trial_start = now + self.duration_cross
                    self.time_trial_end = float('infinity')
            if now > self.time_trial_start: # it's time to start the next trial
                # however, first check if it's time ...
                # ... to end
                if self.count_events() >= self.end_after_x_events:
                    self.send_parallel(self.marker_quit)
                    self.on_stop()
                # ... or to pause
                elif self.count_events() - self.pause_every_x_events*self.block_counter >= self.pause_every_x_events:
                    self.block_counter += 1
                    self.on_pause()
                # otherwise, start new trial
                else:
                    self.on_trial = True
                    self.this_trial()
                    self.send_parallel(self.this_start_marker)
                    self.time_trial_start = float('infinity')
            # for testing purposes and/or interrupting without listening to classifier
            if not self.bci_delayed_idle:
                if self.on_trial and not self.already_interrupted and not self.already_pressed and self.make_interruptions:
                    if self.this_trial_type>2 and now > self.this_start_time + self.this_idle_waittime:
                        self.do_interruption()
            # update traffic light
            self.change_traffic_light()
        self.present_stimulus()
    
    
    def count_events(self):
        if self.end_pause_counter_type==1:
            nr_events = self.pedalpress_counter
        elif self.end_pause_counter_type==2:
            nr_events = self.move_counter
        elif self.end_pause_counter_type==3:
            nr_events = self.idle_counter
        elif self.end_pause_counter_type==4:
            now = pygame.time.get_ticks()
            nr_events = (now - self.time_recording_start)/1000
        return nr_events

    
    def change_traffic_light(self):
        now = pygame.time.get_ticks()
        if now > self.yellow_until:
            self.yellow_on = False
            self.yellow_until = float('infinity')
        if now > self.redgreen_until:
            self.redgreen_on = False
            self.redgreen_until = float('infinity')
        identifier = str()
        if self.yellow_on:
            identifier = identifier + 'yellow'
        if self.redgreen_on:
            identifier = identifier + self.this_interruption_color
        self.this_trafficlight_index = self.trafficlight_states.index(identifier)

    
    def on_control_event(self,data):
        if self.on_trial:
            now = pygame.time.get_ticks()
            if data['cl_output']==-1 and not self.already_interrupted and not self.already_pressed and self.make_interruptions and self.bci_delayed_idle:
                if self.this_trial_type>2 and now > self.this_start_time + self.this_idle_waittime:
                    self.do_interruption() # IDLE interruption
                    self.idle_counter += 1
            if data['cl_output']==1 and not self.already_interrupted and not self.already_pressed and self.make_interruptions:
                if now > self.this_start_time + self.min_waittime:
                    if self.this_trial_type<3: # MOVE interruption
                        self.do_interruption()
                        self.move_counter += 1
                    if self.this_trial_type>2 and not self.already_interrupted_silent: # silent MOVE interruption
                        self.send_parallel_log(self.this_interruption_marker_silent)
                        self.already_interrupted_silent = True
            if data['cl_output']==10 and not self.already_pressed and not self.this_prompt:
                self.pedal_press()
        if self.paused:
            if data['cl_output']==10:
                self.unpause()
        
    
    def on_keyboard_event(self):
        self.process_pygame_events()
        if self.keypressed:
            if self.on_trial and not self.already_pressed and not self.this_prompt:
                self.keypressed = False
                self.pedal_press()
            if self.paused:
                self.keypressed = False
                self.unpause()
            if not self.on_trial:
                self.keypressed = False
                self.already_interrupted = False 
        
        
    def this_trial(self):
        self.reset_trial_states()
        now = pygame.time.get_ticks()
        self.this_start_time = now
        if self.make_interruptions:
            self.this_trial_type = self.queue_trial.pop()
            self.this_idle_waittime = self.queue_waittime.pop()
            self.this_start_marker = self.marker_base_start + self.this_trial_type
            self.this_interruption_marker = self.marker_base_interruption + self.this_trial_type
            if (self.this_trial_type==1) or (self.this_trial_type==3):
                self.this_interruption_color = 'red'
                self.this_interruption_marker_silent = self.marker_base_interruption
            else:
                self.this_interruption_color = 'green'
                self.this_interruption_marker_silent = self.marker_base_interruption
            if (self.this_trial_type==1) or (self.this_trial_type==2):
                self.log('Trial %d | MOVE | %s | Listening to classifier...' % (self.trial_counter+1,self.this_interruption_color))
            else:
                if self.bci_delayed_idle:
                    self.log('Trial %d | IDLE | %s | Listening to classifier in %02.1f sec...' % (self.trial_counter+1,self.this_interruption_color,self.this_idle_waittime/1000))
                else:
                    self.log('Trial %d | IDLE | %s | Interrupting in %02.1f sec...' % (self.trial_counter+1,self.this_interruption_color,self.this_idle_waittime/1000))
        else:
            self.this_start_marker = self.marker_base_start
            self.log('Trial %d | No interruptions...' % (self.trial_counter+1))
    
    
    def do_interruption(self):
        self.send_parallel_log(self.this_interruption_marker)
        now = pygame.time.get_ticks()
        self.already_interrupted = True
        self.redgreen_on = True
        self.redgreen_until = now + self.duration_light_redgreen
        self.time_trial_end = now + self.duration_light_redgreen

    
    def pedal_press(self):
        self.already_pressed = True
        now = pygame.time.get_ticks()
        self.time_trial_end = now + self.duration_light_yellow
        if now < self.this_start_time + self.min_waittime:
            self.this_premature = True
        else:
            self.pedalpress_counter += 1
            self.yellow_on = True
            self.yellow_until = now + self.duration_light_yellow
        self.log('button press')


    def present_stimulus(self):
        self.screen.fill(self.background_color)
        if self.paused:
            self.render_text(self.pause_text)
        else:
            if self.on_trial:
                if self.this_prompt:
                    self.render_text(self.prompt_text)
                else:
                    self.show_trafficlight()
            else:
                self.draw_fixcross()
        pygame.display.update()


    def show_trafficlight(self):
        this_trafficlight = self.trafficlight_image[self.this_trafficlight_index]
        image_size = this_trafficlight.get_size()
        self.screen.blit(this_trafficlight,((self.screenSize[0]/2-image_size[0]/2),(self.screenSize[1]/2-image_size[1]/2)))


    def render_text(self, text):
        disp_text = self.font_text.render(text,0,self.text_color)
        textsize = disp_text.get_rect()
        self.screen.blit(disp_text, (self.screen_center[0] - textsize[2]/2, self.screen_center[1] - textsize[3]/2))
    
    
    def draw_fixcross(self):
        disp_text = self.font_char.render('+',0,self.char_color)
        textsize = disp_text.get_rect()
        self.screen.blit(disp_text, (self.screen_center[0] - textsize[2]/2, self.screen_center[1] - textsize[3]/2))
    
         
    def load_images(self):
        path = os.path.dirname(globals()["__file__"])
        self.trafficlight_image = [None,None,None,None,None,None]
        for c, color in enumerate(self.trafficlight_states):
            self.trafficlight_image[c] = pygame.image.load(os.path.join(path, 'tl_' + color + '.png')).convert_alpha()

   
    def send_parallel_log(self, event):
        self.send_parallel(event)
        self.log(self.marker_identifier[event])
    
    
    def log(self,print_str):
        now = pygame.time.get_ticks()
        print '[%4.2f sec] %s' % (now/1000.0,print_str)



if __name__ == "__main__":
   fb = TrafficLight()
   fb.on_init()
   fb.on_play()
