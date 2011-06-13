require 'app/boot'

require 'json'

# methods for the main app
module HH::App
  # starts a lesson
  # returns only once the lesson gets closed
  include HH::Markup
  def start_lessons name, blk, lesson_area
    @main_content.style(:width => -400)
    @lesson_stack = lesson_area
    @lesson_stack.show
    l = HH::LessonSet.new(name, blk).execute_in @lesson_stack
    l.on_event :close do hide_lesson end
  end

  def hide_lesson
    #@lesson_stack.hide
    #@main_content.style(:width => 1.0)
    @lesson_stack.clear_all
  end

  def load_file name={}
    if gettab(:Editor).load(name)
      opentab :Editor
    end
  end

  # replaces the "Running..." message of the currently running program
  def say arg
    # FIXME TODO: DECOMMENT TO REPRODUCE A SEGMENTATION FAULT: para (para "abc")
    if @program_running
      txt = case arg
      when String
        arg
      else
        highlight(txt.inspect)
      end
      @program_running.clear{para txt}
    end
  end

  def finalization
    # this method gets called on close
    HH::LessonSet.close_lesson
    gettab(:Editor).save_if_confirmed

    HH::PREFS['width'] = width
    HH::PREFS['height'] = height
    HH::save_prefs
  end
end

w = (HH::PREFS['width'] || '790').to_i
h = (HH::PREFS['height'] || '550').to_i
Shoes.app :title => "Hackety Hack", :width => w, :height => h do
  HH::APP = self
  extend HH::App, HH::Widgets, HH::Observable
  style Shoes::LinkHover, stroke: "#C66", underline: false
  style Shoes::Link, stroke: "#377", underline: false
  nostroke

  alias :icon_button :iconbutton

  @main_content = flow do
    background "#e9efe0", height: h
    flow margin_top: h - 150 do
      flow{background "#e9efe0".."#c1c5d0", height: 150}
    end
  end
  #@lesson_stack = stack :hidden => true, :width => 400
  #@lesson_stack.finish do
  #  finalization
  #end

  extend HH::HasSideTabs
  init_tabs @main_content

  addtab :Home, :icon => "tab-home.png"
  addtab :Editor, :icon => "tab-new.png"
  addtab :Lessons, :icon => "tab-tour.png"
  addtab :Help, :icon => "tab-help.png" do
    Shoes.show_manual 'English'
  end
  addtab :Cheat, :icon => "tab-cheat.png" do
    window :title => "Hackety Hack - Cheat Sheet", :width => 496 do
      image "#{HH::STATIC}/hhcheat.png"
    end
  end
  addtab :About, :icon => "tab-hand.png" do
    about = []
    about << rect(100, 30, width-170, height-60, fill: white)
    about << image("#{HH::STATIC}/hhabout.png", top: 30, left: 100)
    glossb "OK", left: width-170, top: height-100, width:50, height: 30, margin: [13, 5], color: "dark" do
      about.clear
      about[1].parent.contents.delete about[1]
    end
  end
  13.times{addtab :Dummy}
  addtab :Prefs, :hover => "Preferences", :icon => "tab-properties.png"
  addtab :Quit, :icon => "tab-quit.png" do
    exit
  end

  opentab :Home
=begin
  @tour_notice =
  stack :top => 46, :left => 22, :width => 250, :height => 54, :hidden => true do
    fill black(0.6)
    nostroke
    shape 0, 20 do
      line_to 23.6, 0
      line_to 23.6, 10
      line_to 0, 0
    end
    background black(0.6), :curve => 6, :left => 24, :width => 215
    para "Check out the Hackety Hack Tour to get started!",
      :stroke => "#FFF", :margin => 6, :size => 11, :margin_left => 22,
      :align => "center"
  end


  # splash screen
  stack :top => 0, :left => 0, :width => 1.0, :height => 1.0 do
    splash
    if HH::PREFS['first_run'].nil?
      @tour_notice.toggle
      @tour_notice.click { @tour_notice.hide }
      HH::PREFS['first_run'] = true
      HH::save_prefs
    end
  end

=end
end
