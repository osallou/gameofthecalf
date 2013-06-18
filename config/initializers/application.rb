
workdir = Settings.workdir
if Settings.workdir.nil? or Settings.workdir.empty?
    workdir = Rails.root.join('data')
    if not Dir.exists?(workdir)
        Dir.mkdir(workdir)
    end
end
GameOfTheCalf::Application.config.pairtree = Pairtree.at(workdir.to_s, :prefix => 'bull:', :create => true)

puts "Initialize workdir at "+workdir.to_s
