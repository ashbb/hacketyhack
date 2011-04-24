# the home tab content

class HH::SideTabs::Home < HH::SideTab
  def home_bulletin(new_version)
    @bulletin_stack.clear do
      stack do
        background "#FF9"
        subtitle "Upgrade to #{new_version}!", :font => "Phonetica", :align => "center", :margin => 8
        para "A New Hackety Hack is Here!", :align => "center"
        para "Go to ", link("hackety-hack.com", :click => "http://hackety-hack.com/download"), " to get it!", :align => "center", :margin_bottom => 20
      end
    end
  end
  def initialize *args, &blk
    super *args, &blk
    # never changes so is most efficient to load here
    @samples = HH.samples
    Upgrade::check_latest_version do |version|
      if version['current_version'] != HH::VERSION
        home_bulletin(version['current_version'])
      end
    end
  end

  # auxiliary method to displays the arrows, for example in case
  # more than 5 programs have to be listed
  def home_arrows meth, start, total
    stack :top => 0, :right => 10 do
      nex = total > start + 5
      if start > 0
        glossb "<<", :top => 0, :right => 10 + (nex ? 100 : 0), :width => 50 do
          @homepane.clear { send(meth, start - 5) }
        end
      end
      if nex
        glossb "Next 5 >>", :top => 0, :right => 10, :width => 100 do
          @homepane.clear { send(meth, start + 5) }
        end
      end
    end
  end


  def home_scripts start=0
    display_scripts @scripts, start
  end

  def sample_scripts start=0
    display_scripts @samples, start, true
  end

  # auxiliary function used to both display the user programs (scripts)
  # and the samples
  def display_scripts scripts, start, samples = false
    if scripts.empty?
      para "You have no programs."
    else
      scripts[start,7].each do |script|
        stack :margin_left => 8, :margin_top => 4 do
          flow do
            britelink "icon-file.png", script[:name], script[:mtime] do
              load_file script
            end
            unless script[:sample]
              # if it is not a sample file
              para link(ins("x")){
                if confirm("Do you really want to delete \"#{script[:name]}\"?")
                  delete script
                end
              }, width: 20, margin: [20, 5, 0, 0]
            end
          end
          if script[:desc]
            para script[:desc], :stroke => "#777", :size => 9,
              :font => "Lacuna Regular", :margin => 0, :margin_left => 18,
              :margin_right => 140
          end
        end
      end
      # FIXME: sometimes :sample_scripts
=begin
      m = samples ? :sample_scripts : :home_scripts
      home_arrows m, start, scripts.length
=end
    end
  end

  def delete script
    File.delete "#{HH::USER}/#{script[:name]}.rb"
    reset
  end

  # I think this was meant to show all tables currently in the database
#  def home_tables start = 0
#    if @tables.empty?
#      para "You have no tables.", :margin_left => 12, :font => "Lacuna Regular"
#    else
#      @tables[start,5].each do |name|
#        stack :margin_left => 8, :margin_top => 4 do
#          britelink "icon-table.png", name do
#            alert("No tables page yet.")
#          end
#        end
#      end
#      home_arrows :home_tables, start, @tables.length
#    end
#  end

  def home_lessons
    para "You have no lessons.", :margin_left => 12, :font => "Lacuna Regular"
  end

  def hometab name, starts, x, y, &blk
    tab = [ rect(x, y, 105, 29, fill: "#555", curve: 6),
      rect(x, y-5, 105, 34, fill: rgb(233, 239, 224), curve: 6),
      para(fg(name, white), left: x+25, top: y+2, size: 11),
      para(fg(name, black), left: x+20, top: y)]
    tab[0].click{@tabs.each{|a| a.each &:toggle}; blk.call}
    timer(0.01){starts ? (tab[0].hide; tab[2].hide) : (tab[1].hide; tab[3].hide)}
    @tabs << tab
  end

  def on_click
    reset
  end

  # creates the content of the home tab
  def content
    image("#{HH::STATIC}/hhhello.png").move 305, 42
    rect 38, 0, width-38, 35, fill: "#CDC"
    rect 38, 0, width-38, 38, fill: black.push(0.05)..black.push(0.2)
    @tabs, @tables = [], HH::DB.tables
    @scripts = HH.scripts

    hometab "Programs", true, 50, 13 do
      @slot.append do
        @homepane.clear{home_scripts}
        flush
      end
    end
    hometab "Samples", false, 168, 13 do
      @slot.append do
        @homepane.clear{sample_scripts}
        flush
      end
    end
    rect 38, 38, 300, 4, fill: rgb(233, 239, 224)

    @slot.append do
      stack(height: 40){}
      @homepane = flow(margin_top: 10){home_scripts}
      flush
    end

=begin
      stack :margin_left => 12 do
        background rgb(233, 239, 224, 0.85)..rgb(233, 239, 224, 0.0)
        image 10, 70
      end
      @bulletin_stack = stack do
      end
=end
  end
end
