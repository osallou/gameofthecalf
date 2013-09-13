require 'tempfile'
require 'fileutils'

# Group is used to group a set of Users.
# User is in one group only.
# Group can be seen as a classroom owner by a professor.
class Group < ActiveRecord::Base
  attr_accessible :description, :name, :email, :levels
  attr_accessible :bulls, :cows, :config_id, :market

  scope :recent, order("created_at desc")

  has_many :users, :dependent => :nullify
  has_many :games, :dependent => :nullify

  def mate()
    # Do mating for a group of user   
    games = Game.where(:group_id => self[:id])
    matingplans = {}
    gen = nil
    games.each do |game|
      gen = game[:level]
      level = Level.where(:game_id => game[:id], :level => game[:level]).first
      matingplans[game[:cattle]] = JSON.parse(level[:matingplan])
      if game[:level]< Settings.max_levels
        # Go to next level
        game[:level] += 1
        game[:status] = Level::STATUS_NEW

        level = Level.new(:game_id => game.id, :status => Level::STATUS_NEW, :level => game[:level])
        level.save!
      else
        game[:status] = Level::STATUS_COMPLETED
      end
      game.save
    end
    do_mating = Game.writeMatingPlan("group"+self[:id].to_s, gen+1, matingplans)
    if do_mating
      Game.mate("group"+self[:id].to_s, gen+1)
    end
    # Set statistics for each game
    games.each do |game|
      game.load_statistics()
      game.save 
    end
  end

  def close_market()
    # Get one game from the current group
    one_game = Game.where(:group_id => self[:id]).first()
    one_user = User.where(:id => one_game[:user_id]).first()
    cattle_path = one_game.get_cattle_path(one_user)
    cattle_file = 'bullMate_perfVG_Flock-1_generation-'+one_game.level.to_s+'.txt'
    # Select market_max_final best animal bids
    bids = Bid.select("sum(bid) as bids, market_id").where(:group_id => self[:id]).group("market_id").order("bids DESC").first(Settings.market_max_final)
    allowed_users = {}
    # Only users that made proposals can benefit from IA selection
    markets = Market.where(:group_id => self[:id])
    markets.each do |market|
      if ! allowed_users.has_key?(market[:owner])
          allowed_users[market[:owner].to_s] = true
      end    
    end

    tmpfile = Tempfile.new('bullmate')
    last_userid = nil
    last_animal_id = nil
    CSV.foreach(cattle_path + '/' + cattle_file, { col_sep: "\t" }) do |row|
       userid = row[0]
       animal_id = row[1]
       # init userid
       if last_userid == nil
         last_userid = userid
       end
       if last_animal_id == nil
         last_animal_id = animal_id
       end
       # if we switch to a new user, add IA animals, only if not from current
       # user
       if userid != last_userid
         if allowed_users.has_key?(last_userid)
           count = last_animal_id.to_i+1
           bids.each do |bid|
             market = Market.find(bid[:market_id])
             values = JSON.parse(market[:values])
             values[0] = last_userid
             values[1] = count.to_s
             count += 1
             values << "1"
             values << market[:owner].to_s+"-"+market[:animal].to_s
             tmpfile.write values.join("\t")+"\n" 
           end
         end
         last_userid = userid
       end
       last_animal_id = animal_id
       tmpfile.write row.join("\t")+"\n"
    end

    # Last user
    if allowed_users.has_key?(last_userid)
       count = last_animal_id.to_i+1
       bids.each do |bid|
         market = Market.find(bid[:market_id])
         values = JSON.parse(market[:values])
         values[0] = last_userid
         values[1] = count.to_s
         count += 1
         values << "1"
         values << market[:owner].to_s+"-"+market[:animal].to_s
         tmpfile.write values.join("\t")+"\n"
       end
    end
    tmp_file_path = tmpfile.path
    tmpfile.close()
    tmp_file = File.open(tmp_file_path,"r")

    new_cattle_file = File.open(cattle_path + '/' + cattle_file,"w")
    new_cattle_file.write(tmp_file.read)
    new_cattle_file.close()
    tmp_file.close()
    tmpfile.close()
  end


end
