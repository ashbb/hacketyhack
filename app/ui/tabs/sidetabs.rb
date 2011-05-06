class HH::SideTabs
  include HH::Observable
  ICON_SIZE = 16
  HOVER_WIDTH = 140
  def initialize slot, dir
    @slot, @directory = slot, dir
    @n_tabs = {:top => 0, :bottom => 1}
    # tabs whose file has been loaded
    @loaded_tabs = {}
    sidetabs = self
    width = HOVER_WIDTH
    tabs = (%w[home editor lessons help cheat about] + %w[dummy] * 13 + %w[preferences quit]).
      map &:capitalize
    tips = []
    tabs.each_with_index do |tab, i|
      (tips.push nil; next) if tab == 'Dummy'
      y = i*26+4
      slot.app.instance_eval do
        tips << [rect(38, y, 100, 24, fill: "#F7A", curve: 4, hidden: true, front: true), 
          rect(38, y, 10, 24, fill: "#F7A", hidden: true, front: true), 
          para(fg(tab, white), left: 44, top: y+2, hidden: true, front: true)]
      end
    end
    tip = {}
    tabs.each_with_index{|tab, i| tip.merge! tab => tips[i]}
    append_to @slot do
      left = stack :width => 38, :height => height do
        # colored background
        background "#cdc", :width => 38
        background "#dfa", :width => 36
        background "#fda", :width => 30
        background "#daf", :width => 24
        background "#aaf", :width => 18
        background "#7aa", :width => 12
        background "#77a", :width => 6
      end
      right = flow width: width() - 38, height: height
      sidetabs.instance_eval{@left, @right, @tip = left, right, tip}
    end
  end

  # +opts+ is an hash
  # if a block is given no file gets loaded
  def addtab symbol, opts={}, &blk
    # default options
    if not symbol.is_a?(Symbol)
      raise ArgumentError
    end
    tab = opts
    tab[:symbol] = symbol
    tab[:icon] ||= "icon-file.png"
    tab[:hover] ||= symbol.to_s
    
    hover = tab[:hover]
    icon_path = HH::STATIC + "/" + tab[:icon]
    tip = @tip
    onclick = proc do
      opentab symbol
    end
    width = HOVER_WIDTH+22;
    append_to @left do
      (stack(width: 38, height: 26){}; break) if symbol == :Dummy
      stack width: 38, height: 26, margin: 4 do
        bg = img = nil
        flow do
          bg = background "#DFA", width: 32, curve: 6, hidden: true
          img = image(icon_path, margin: 4)
        end
        img.hover do
          bg.show
          tip[hover].each &:show
        end
        img.leave do
          bg.hide
          tip[hover].each &:hide
        end
        img.click &onclick
      end
    end

    if blk
      @loaded_tabs[symbol] = HH::NoContentSideTab.new blk
    end
  end

  def opentab symbol
    return if symbol == @current_tab.class.to_s.split('::').last.to_sym
    tab = gettab symbol
    if tab.has_content?
      @current_tab.close if @current_tab
      @current_tab = tab
    end
    tab.open
    emit :tab_opened, symbol
  end

  def gettab symbol
    if @loaded_tabs.include? symbol
      return @loaded_tabs[symbol]
    else
      require "app/ui/tabs/#{symbol.downcase}.rb"
      @loaded_tabs[symbol] = self.class.const_get(symbol).new(@right)
    end
  end

  private
  def append_to slot, &blk
    slot.app do
      slot.append {self.instance_eval &blk}
    end
  end
end

module HH::HasSideTabs
  def init_tabs slot, dir="app/ui/tabs"
    @__side_tab_class = HH::SideTabs.new slot, dir
    # effectively redirects event to HH::APP
    @__side_tab_class.on_event :tab_opened, :any do |newtab|
      emit :tab_opened, newtab
    end
  end

  # returns the created tab
  def addtab *args, &blk
    @__side_tab_class.addtab *args, &blk
  end
  
  def opentab symbol
    @__side_tab_class.opentab symbol
  end

  def gettab symbol
    @__side_tab_class.gettab symbol
  end
end

class HH::SideTab
  def initialize slot
    @slot = slot
    slot.append do
      @content = flow
    end
  end

  def open
    on_click
    if has_content?
      @content.show
    end
  end

  def close
    if has_content?
      [@slot, @homepane, @tabs, @gbs, @bgs].clear
      @slot.contents = [] if @slot
      @homepane.contents = [] if @homepane
    end
  end

  def clear &blk
    @content.clear &blk
  end

  def reset
    clear {content}
  end

  def has_content?
    self.class.method_defined?(:content)
  end

  def method_missing symbol, *args, &blk
    #slot = @slot
    @slot.app.send symbol, *args, &blk
  end

  def on_click
    # by default does nothing
  end
end

class HH::NoContentSideTab < HH::SideTab
  def initialize blk
    @blk = blk
  end
  def on_click
    @blk.call
  end
end

