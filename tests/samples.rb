require_relative "../lib/flammarion.rb"
require 'faker'

unless defined?("sample")
def sample(name)
  return if ARGV[0] and name.to_s != ARGV[0]
  puts "Showing: #{name}"
  f = Flammarion::Engraving.new(title:name.to_s.split("_").collect{|w| w[0] = w[0].upcase; w}.join(" "))
  yield(f)
  f.wait_until_closed
end
end

sample :message_sender_with_contacts do |f|
  f.orientation = :horizontal
  f.subpane("number").input("Phone Number")
  f.checkbox("Request Read Receipt")
  f.input("Body", multiline:true)
  f.button("Send") {f.status("Error: #{ArgumentError.new("Dummy Error")}".red)}
  f.pane("contacts", weight:0.7).puts("Contacts", replace:true)
  icons = %w[thumbs-up meh-o bicycle gears star-o star cow cat cactus] + [nil] * 5
  30.times do |i|
    right_icon = icons.sample
    left_icon = icons.sample
    name = Faker::Name.name
    f.pane("contacts").button(name, right_icon:right_icon, left_icon: left_icon) do
      f.subpane("number").replace("To: #{name.light_magenta}")
    end
  end
end

sample :table_with_side_panes do |f|
  f.orientation = :horizontal
  f.table( 20.times.map do |i|
    [i, Faker::Name.name, Faker::Address.street_address]
  end, headers: ["Id", "Name", "Address"].map{|h| h.light_magenta})
  f.pane("sidebar").pane("side1").puts("<a href='https://github.com/zach-capalbo/flammarion'>Home Page</a>", escape_html:false)
  f.pane("sidebar").pane("side1").puts Faker::Hipster.paragraph.red
  f.pane("sidebar").pane("side2").puts Faker::Hipster.paragraph.green
  f.pane("sidebar").pane("side2").markdown("#{Faker::Hipster.paragraph.gsub(/\s/){|m| m + ((rand > 0.75) ? " :#{%w[cow cat smile thumbsup].sample}: " : "")}} [And Such](https://github.com/zach-capalbo/flammarion)", escape_icons:true)

  3.times { f.status(Faker::Hipster.sentence.light_green)}
end

sample :log_viewer do |f|
  wordwrap = false
  f.button_box("b").button("Clear", right_icon:'trash-o') {f.subpane('s').clear}
  unless wordwrap then
    f.button_box("b").button("w-w") { f.subpane('s').style({'word-wrap' => 'initial', 'white-space' => 'pre'})}
    wordwrap = true
  else
    f.button_box("b").button("w-w") { f.subpane('s').style({'word-wrap' => 'break-word', 'white-space' => 'pre-wrap'})}
    wordwrap = false
  end
  20.times { f.subpane('s', fill:true).puts(Faker::Hipster.paragraph) }
end

sample :readme do |f|
  f.orientation = :horizontal
  f.markdown(File.read("#{File.dirname(__FILE__)}/../Readme.md"))
  f.pane("code").highlight(File.read(__FILE__))
end

sample :colors do |f|
  colors = %w[black red green yellow blue magenta cyan white]
  ([:none] + colors + colors.collect{|b| "light_#{b}"}).each do |bg|
    f.table(colors.collect do|c|
      [c.colorize(:color => c.to_sym, :background => bg.to_sym),
        "light_#{c}".colorize(:color => "light_#{c}".to_sym, :background => bg.to_sym)]
    end, style:{'float' => 'left'})
  end
end

sample :sine_wave_plot do |f|
  data = 100.times.collect {|x| Math.sin(x / 100.0 * 5.0 * Math::PI)}
  f.plot(data)
end

sample :date_time_plot do |f|
  f.plot(x: (1..10).to_a.map{|t| Time.now + t * 60 * 60 * 24}, y:(1..10).to_a.map{|x| Math.exp(x)}, type:'bar')
end

sample :multi_plot do |f|
  f.plot(5.times.map{|t| {y:100.times.map{rand * t}}})
end

sample :echo do |f|
  f.subpane("o")
  f.input("> ", history:true, autoclear: true, enter_only:true) do |m|
    f.subpane("o").highlight(m)
  end
end

sample :password do |f|
  f.puts('Deferred Password:'.green)
  pw = f.input('Enter deferred password', password:true, value:'deferred pw')
  f.puts('Block Password:'.green)
  f.input('Enter block password', history:true, autoclear: true, enter_only:true, password:true, value:'block pw') { |m|
    f.puts("Block password is #{m['text'].magenta}. Deferred password is #{pw.to_s.magenta}.")
  }
  f.puts("Initial deferred password is #{pw.to_s.magenta}.")
end

sample :emoji do |f|
  f.emoji.keys.each_slice(20) {|e| f.puts e.join(" "), escape_icons:true}
end

sample :frake do |f|
  Dir.chdir(File.join(File.dirname(__FILE__), "../")) do
    f.markdown "# Rake Tasks: "
    f.break
    `rake -T`.each_line do |l|
      f.puts
      parts = l.split("#")
      task = parts[0]
      desc = parts[1]
      f.puts desc.strip
      f.button(task) do
        run(task)
      end
    end
  end
end
