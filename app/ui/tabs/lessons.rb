module Kernel
  # topmost instruction for the lessons DSL
  # starts a lesson set
  def lesson_set name, &blk
    HH::SideTabs::Lessons.load_lesson name, blk
  end
end

class HH::SideTabs::Lessons < HH::SideTab
  # auxiliary function used by Kernel#lesson_set
  # stores the code of the DSL used to write the lessons
  def self.load_lesson name, blk
    @@lessons << [@@difficulty, name, blk]
  end

  def on_click
    reset
  end

  # draws the lessons tab
  def content
    @slot.append do
      stack width: 372, margin: 10 do
        title "Lessons", font: "Coolvetica"
        @@lessons = []
        @@difficulty = "About Hackety"
        para "So you want to learn some programming, eh? You've come to the right place!"
        Dir["#{HH::LESSONS}/*.rb"].each { |f| load f }

        %w[beginner intermediate advanced expert].each do |d|
          @@difficulty = d.capitalize
          Dir["#{HH::LESSONS}/#{d}/*.rb"].each { |f| load f }
        end

        @@lessons.group_by{|i| i[0]}.each do |key, value|
          tagline key.to_s
          value.each do |v|
            stack do
              britelink "icon-file.png", v[1] do
                HH::APP.start_lessons v[1], v[2], @lesson_area
              end
            end
          end
        end
      end
      @lesson_area = stack(width: 420, height: height, margin: 10, hidden: true){}
      flush
    end
  end
end

