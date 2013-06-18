
workdir = Settings.workdir
if Settings.workdir.empty?
    workdir = Rails.root.join('data')
    Dir.mkdir(workdir)
end
GameOfTheCalf::Application.config.pairtree = Pairtree.at(workdir, :prefix => 'bull:', :create => true)

puts "Initialize workdir at "+Settings.workdir
