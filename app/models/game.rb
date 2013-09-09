# Main game class. A game represent a complete player game.
# It is composed of a set of levels up to final level.
# It gathers statistics, interactions etc... with the player
# as well as global rules.
class Game < ActiveRecord::Base

  attr_accessible :user_id, :level, :status, :cattle, :group_id, :data
  
  scope :recent, order("created_at desc")
  
  belongs_to :user
  belongs_to :group

  has_many :levels, :dependent => :destroy
       
  #Load statistical data from perfVG file
  def load_statistics()
    if Settings.simulate != nil
        return
    end
    user = User.find(self.user_id)
    cattle_path = self.get_cattle_path(user)
    cattle_file = 'bullMate_perfVG_Flock-1_generation-'+self.level.to_s+'.txt'

    weight_4m = []
    weight_7m = []

    found = false
    CSV.foreach(cattle_path + '/' + cattle_file, { col_sep: "\t" }) do |row|
        if row[0].to_i == self.cattle
            weight_4m << row[3]
            weight_7m << row[4]
            found = true
        elsif found
            break
        end
    end
    if self.data.nil? or self.data.empty?
        self.data = "{}"
    end
    data = JSON.parse(self.data)
    data[self.level.to_s] = {"weight_4m" => weight_4m.to_scale().mean(), "weight_7m" => weight_7m.to_scale().mean() }
    self.data = JSON.dump(data)
    
  end

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
    if Settings.simulate != nil
      return
    end
    pairtree = GameOfTheCalf::Application.config.pairtree
    cattle_path = pairtree.get('bull:'+id).path
    matingfile = cattle_path+'/bullMate_matingDATA-G'+gen.to_s+'-1.txt'
    File.open(matingfile, 'w') {|f| 
      matingplans.each do |cattle,plan|
        if plan!=nil
          line = "##\n"
          plan.each do |bull,cows|
            line += cattle.to_s+"\t"+bull.to_s+"\t"+cows.join(",").to_s+"\n"
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
    CSV.foreach(cattle_path + '/' + cattle_file, { col_sep: "\t" }) do |row|
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
    
    
    maxbulls = [ Settings.max_bulls, bulls.length ].max
    maxcows = [ Settings.max_cows, cows.length ].max
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
          " --gen "+gen.to_s+" --group 1 --matrix "+game_path+"/covar_poids_4_7_mois"+
          # Load previous perfVG
          " --vg "+game_path+"/bullMate_perfVG_Flock-1_generation-"+(gen-1).to_s+".txt"+
          " --mating "+game_path+"/bullMate_matingDATA-G"+gen.to_s+"-1.txt"+
          " -d "+game_path+
          " -e "+game_path+"/covar_envPermanent_4_7_mois"+
          " --config "+game_path+"/config.yml"
    err = system(cmd)
    if not err
        raise 'Error while trying to execute command '+cmd
    end
  end
  

  def self.generate_config(game_path, config)
    conf = {}
    conf['nbtraits'] = config['nbtrait']
    conf['mortality'] = config['mortality']
    conf['mean_weight'] = {}
    mean = config['mean_weight'].split(',')
    conf['mean_weight']['WEIGHT4M'] = mean[0]
    conf['mean_weight']['WEIGHT7M'] = mean[1]
    sex_effect = config['sex_effect'].split(',')
    conf['sex_effect'] = {}
    conf['sex_effect']['MALE_P4M'] = sex_effect[0]
    conf['sex_effect']['MALE_P7M'] = sex_effect[1]
    conf['heritability'] = config['heritability'].split(',')  
    File.open(game_path+'/config.yml', 'w') do |f|
        f.puts conf.to_yaml  
    end
    #File.open(game_path+'/poids_4_7mois', 'w') do |f|  
    #    f.puts "#W4M\tW7M"
    #    weight_elts = config['mean_weight'].split(',')
    #    f.puts weight_elts[0]+"\t"+weight_elts[1]
    #end
    File.open(game_path+'/covar_poids_4_7_mois', 'w') do |f|
        f.puts "#W4Md\tW7Md\tW4Mm\tW7Mm"
        covar_weight_elts = config['covar_weight'].split('|')
        covar_weight_elts.each do |covar_weight_elt|
          covars = covar_weight_elt.split(',')
          f.puts covars[0]+"\t"+covars[1]+"\t"+covars[2]+"\t"+covars[3]
        end   
    end 
    #File.open(game_path+'/heritability_poids_4_7_mois', 'w') do |f|   
    #    f.puts "#W4Md\tW7Md\tW4Mm\tW7Mm"
    #    heritabilitys = conf['heritability']
    #    f.puts heritabilitys[0]+"\t"+heritabilitys[1]+"\t"+heritabilitys[2]+"\t"+heritabilitys[3]
    #end 
    File.open(game_path+'/covar_envPermanent_4_7_mois', 'w') do |f|   
        f.puts "#W4M\tW7M"
        covar_envPermanent_elts = config['covar_envPermanent'].split('|')
        covar_envPermanent_elts.each do |covar_envPermanent_elt|
          covars = covar_envPermanent_elt.split(',')
          f.puts covars[0]+"\t"+covars[1]
        end  
    end   
  end

  # Generate X cattles calling external scripts
  def self.generate_new_cattle(players=1,id=0,bulls=Settings.default_bulls,cows=Settings.default_cows)
    if Settings.simulate!=nil
        return
    end
    # Create a path
    obj = GameOfTheCalf::Application.config.pairtree.mk('bull:'+id)
    game_path = obj.path
    # Load default config
    config = GameConfig.where(:default => true).first
    if id.match(/^group/)
      # If a group, load group config
      group = Group.find(id.sub(/group/,'').to_i)
      if ! group.nil?
        config = GameConfig.find(group[:config_id])
      end
    end
    Game.generate_config(game_path, config)
    
    cmd = "perl "+Settings.binaries+"/bullmate_01_generateInitialPop.pl"+
        #" -w "+game_path+"/poids_4_7mois"+
        " -m "+game_path+"/covar_poids_4_7_mois"+
        #" -h "+game_path+"/heritability_poids_4_7_mois"+
        " -f "+players.to_s+
        " -b "+bulls.to_s+" --cow "+cows.to_s+" -e "+
        game_path+"/covar_envPermanent_4_7_mois"+
        " -g 1 -d "+game_path+
        " --config "+game_path+"/config.yml"
    err = system(cmd)
    if not err
        raise 'Error while trying to execute command '+cmd
    end
    cmd = "perl "+Settings.binaries+"/bullmate_02_generateNextGeneration.pl"+
          " -b "+game_path+"/bullMate_breederEffect_B-1"+
          " -p "+game_path+"/bullMate_pedigree_Flock-1.txt"+
          " --gen 1 --group 1 --matrix "+game_path+"/covar_poids_4_7_mois"+
          " --vg "+game_path+"/bullMate_perfVG_Flock-1.txt"+
          " --mating "+game_path+"/bullMate_matingDATA-G0-1.txt"+
          " -d "+game_path+
          " -e "+game_path+"/covar_envPermanent_4_7_mois"+
          " --config "+game_path+"/config.yml"
    err = system(cmd)
    if not err
        raise 'Error while trying to execute command '+cmd
    end
  end
  
  def complete_level(matingplan="{}")
    
    max_levels = Settings.max_levels
    
    # Update current level
    level = Level.where(:game_id => self[:id], :level => self[:level]).first
    level[:matingplan] = matingplan
    level.status = Level::STATUS_COMPLETED
    level.save
    
    if self[:group_id]!=nil
        self[:status] = Level::STATUS_COMPLETED
        self.save
    else
      Game.writeMatingPlan("game"+self[:id].to_s, level[:level]+1,{ self[:cattle] => JSON.parse(level[:matingplan]) })
      Game.mate("game"+self[:id].to_s, self[:level]+1)
      if self[:level] < max_levels
        # Go to next level
        self[:level] += 1
        self[:status] = Level::STATUS_NEW

        level = Level.new(:game_id => self.id, :status => Level::STATUS_NEW, :level => self[:level])
        level.save!
      else
        self[:status] = Level::STATUS_COMPLETED
      end
      self.load_statistics()
      self.save
    end
  end

end
