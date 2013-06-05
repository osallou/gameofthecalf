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
    if user.group_id != nil
        group = Group.find(user.group_id)
        pathid = 'group'+group.id.to_s
    else
        pathid = 'game'+self.id.to_s
    end 
    pairtree = GameOfTheCalf::Application.config.pairtree
    cattle_path = pairtree.get('bull:'+pathid).path
  end

  # Generate X cattles calling external scripts
  def self.generate_new_cattle(players=1,id=0,bulls=Settings.default_bulls,cows=Settings.default_cows)
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
    # execute:
    # bullmate_01_generateInitialPop.pl -w poids_4_7mois -m covar_poids_4_7_mois
    # -h heritability_poids_4_7_mois -f 10 -b 5 -c 50 -e
    # covar_envPermanent_4_7_mois -g groupid -d workdir
    # Then
    # perl  bullmate_02_generateNextGeneration.pl -b
    # /tmp/bullMate_breederEffect_B-1  -p
    # /tmp/bullMate_pedigree_Flock-1_Bull-5_Cow-50.txt --gen 1 --group 1
    # --matrix covar_poids_4_7_mois  --vg
    # /tmp/bullMate_perfVG_Flock-1_Bull-5_Cow-50.txt  --mating
    # /tmp/bullMate_matingDATA-G0-1.txt  -d /tmp/ -e covar_envPermanent_4_7_mois
  end

end
