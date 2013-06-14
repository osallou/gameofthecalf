# Main game class. A game represent a complete player game.
# It is composed of a set of levels up to final level.
# It gathers statistics, interactions etc... with the player
# as well as global rules.
class Game < ActiveRecord::Base

  attr_accessible :user_id, :level, :status, :cattle, :group_id
  
  scope :recent, order("created_at desc")
  
  belongs_to :user
  belongs_to :group

  has_many :levels, :dependent => :destroy

  #Get the path to the cattle files according to user
  def get_cattle_path(user)
    if Settings.simulate != nil
        return Rails.root.join('test', 'fixtures', 'fakedata', '/')
    end
    if user.group_id != nil
        group = Group.find(user.group_id)
        pathid = 'group'+group.id.to_s
    else
        pathid = 'game'+self.id.to_s
    end 
    pairtree = GameOfTheCalf::Application.config.pairtree
    cattle_path = pairtree.get('bull:'+pathid).path
    return cattle_path
  end

  def self.writeMatingPlan(id, gen, matingplans)
    # matingplans is an associative array with cattle id and mating plan
    pairtree = GameOfTheCalf::Application.config.pairtree
    cattle_path = pairtree.get('bull:'+id).path
    matingfile = cattle_path+'/bullMate_matingDATA-G'+gen.to_s+'-1.txt'
    File.open(matingfile, 'w') {|f| 
      matingplans.each do |cattle,plan|
        if plan!=nil
          line = '##'
          plan.each do |bull,cows|
            line = cattle.to_s+"\t"+bull.to_s+"\t"+cows.join(",").to_s+"\n"
          end       
          f.write(line)
        end   
      end  
      }  
  end

  def generateFakeMatingPlan()
    #level = Level.where(:game_id => self.id, :level => self.level).first
    user = User.find(self.user_id)
    cattle_path = self.get_cattle_path(user)
    cattle_file = 'bullMate_perfVG_Flock-1_generation-'+self.level.to_s+'.txt'

    bulls = []
    cows = []

    found = false
    CSV.foreach(cattle_path+'/'+cattle_file, col_sep:"\t") do |row|
        if row[0].to_i == self.cattle
            if row[2].to_i == 0
                bulls << row
            else
                cows << row
            found = true
            end
        elsif found
            break
        end
    end

    matingplan = {}
    i = 0
    maxbulls = Settings.max_bulls
    maxcows = Settings.max_cows
    if self.group_id != nil
        group  = Group.find(self.group_id)
        maxbulls = group[:bulls]
        maxcows = group[:cows]
    end
    cowsperbull = maxcows / maxbulls
    remaining = maxcows - (maxbulls * cowsperbull)
    cow = 0
    for cbull in 0..(maxbulls-1)
        bull = bulls[cbull]
        matingplan[bull[1]] = []
        for j in (cowsperbull*cbull)..((cowsperbull*(cbull+1)-1))
            matingplan[bull[1]] << cows[j][1]
            cow+=1
        end 
    end
    for j in cow..(cow+remaining-1)
        matingplan[bull[maxbulls-1]] << cows[j][1]
    end 
    return matingplan 

  end

  def self.mate(id, gen)
    if Settings.simulate != nil
        return
    end
    obj = GameOfTheCalf::Application.config.pairtree.mk('bull:'+id)
    game_path = obj.path
    cmd = "perl "+Settings.binaries+"/bullmate_02_generateNextGeneration.pl"+
          " -b "+game_path+"/bullMate_breederEffect_B-1"+
          " -p "+game_path+"/bullMate_pedigree_Flock-1.txt"+
          " --gen "+gen.to_s+" --group 1 --matrix "+Settings.binaries+"/covar_poids_4_7_mois"+
          " --vg "+game_path+"/bullMate_perfVG_Flock-1.txt"+
          " --mating "+game_path+"/bullMate_matingDATA-G"+gen.to_s+"-1.txt"+
          " -d "+game_path+
          " -e "+Settings.binaries+"/covar_envPermanent_4_7_mois"
    err = system(cmd)
    if not err
        raise 'Error while trying to execute command '+cmd
    end    
  end
  

  # Generate X cattles calling external scripts
  def self.generate_new_cattle(players=1,id=0,bulls=Settings.default_bulls,cows=Settings.default_cows)
    if Settings.simulate!=nil
        return
    end
    # Create a ppath
    obj = GameOfTheCalf::Application.config.pairtree.mk('bull:'+id)
    game_path = obj.path
    cmd = "perl "+Settings.binaries+"/bullmate_01_generateInitialPop.pl -w "+
        Settings.binaries+"/poids_4_7mois -m "+
        Settings.binaries+"/covar_poids_4_7_mois -h "+
        Settings.binaries+"/heritability_poids_4_7_mois -f "+players.to_s+
        " -b "+bulls.to_s+" -c "+cows.to_s+" -e "+
        Settings.binaries+"/covar_envPermanent_4_7_mois "+
        "-g 1 -d "+game_path
    err = system(cmd)
    if not err
        raise 'Error while trying to execute command '+cmd
    end
    cmd = "perl "+Settings.binaries+"/bullmate_02_generateNextGeneration.pl"+
          " -b "+game_path+"/bullMate_breederEffect_B-1"+
          " -p "+game_path+"/bullMate_pedigree_Flock-1.txt"+
          " --gen 1 --group 1 --matrix "+Settings.binaries+"/covar_poids_4_7_mois"+
          " --vg "+game_path+"/bullMate_perfVG_Flock-1.txt"+
          " --mating "+game_path+"/bullMate_matingDATA-G0-1.txt"+
          " -d "+game_path+
          " -e "+Settings.binaries+"/covar_envPermanent_4_7_mois"
    err = system(cmd)
    if not err
        raise 'Error while trying to execute command '+cmd
    end
  end

end
