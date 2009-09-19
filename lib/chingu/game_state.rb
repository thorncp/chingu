#--
#
# Chingu -- Game framework built on top of the opengl accelerated gamelib Gosu
# Copyright (C) 2009 ippa / ippa@rubylicio.us
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++


module Chingu
  #
  # Chingu incorporates a basic push/pop game state system (as discussed here: http://www.gamedev.net/community/forums/topic.asp?topic_id=477320).
  # Game states is a way of organizing your intros, menus, levels.
  # Game states aren't complicated. In Chingu a GameState is a class that behaves mostly like your default Gosu::Window (or in our case Chingu::Window) game loop.
  #
  # # A simple GameState-example
  # class Intro < Chingu::GameState
  #   def update
  #     # game logic here
  #   end
  #
  #   def draw
  #     # screen manipulation here
  #   end
  #        
  #   # Called when we enter the game state
  #   def setup
  #     @player.angle = 0   # point player upwards
  #   end
  #    
  #   # Called when we leave the current game state
  #   def finalize
  #     push_game_state(Menu)   # switch to game state "Menu"
  #   end
  # end
  #

  class GameState
    include Chingu::GameStateHelpers    # Easy access to the global game state-queue
    include Chingu::GFXHelpers          # Adds fill(), fade() etc to each game state
    include Chingu::GameObjectHelpers   # adds game_objects_of_class etc ...
    include Chingu::InputDispatcher     # dispatch-helpers
    include Chingu::InputClient
    
    attr_reader :options                # so jlnr can access his :level-number
    attr_accessor :game_state_manager, :game_objects
    
    def initialize(options = {})
      @options = options
      ## @game_state_manager = options[:game_state_manager] || $window.game_state_manager
      @game_objects = GameObjectList.new
      @input_clients = Set.new          # Set is like a unique Array with Hash lookupspeed
      
      # Game state mamanger can be run alone
      if defined?($window) && $window.respond_to?(:game_state_manager)
        $window.game_state_manager.inside_state = self
      end
    end
        
    #
    # An unique identifier for the GameState-class, 
    # Used in game state manager to keep track of created states.
    #
    def to_sym
      self.class.to_s.to_sym
    end

    def to_s
      self.class.to_s
    end
    
    def setup
      # Your game state setup logic here.
    end
    
    #
    # Called when a button is pressed and a game state is active
    #
    def button_down(id)
      dispatch_button_down(id, self)
      @input_clients.each { |object| dispatch_button_down(id, object) } if @input_clients
    end
    
    #
    # Called when a button is released and a game state active
    #
    def button_up(id)
      dispatch_button_up(id, self)
      @input_clients.each { |object| dispatch_button_up(id, object) }   if @input_clients
    end
    
    #
    # Calls update on each game object that has current game state as parent (created inside that game state)
    #
    def update
      dispatch_input_for(self)
      
      @input_clients.each { |game_object| dispatch_input_for(game_object) }      
      
      @game_objects.update
    end
    
    #
    # Calls Draw on each game object that has current game state as parent (created inside that game state)
    #
    def draw
      @game_objects.draw
    end
        
    #
    # Closes game state by poping it off the stack (and activating the game state below)
    #
    def close
      pop_game_state
    end
    
    #
    # Closes main window and terminates the application
    #
    def close_game
      $window.close
    end
  end
end