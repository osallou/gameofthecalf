# Main game class. A game represent a complete player game.
# It is composed of a set of levels up to final level.
# It gathers statistics, interactions etc... with the player
# as well as global rules.
class Game < ActiveRecord::Base
  attr_accessible :user_id, :level, :status
  
  scope :recent, order("created_at desc")
  
  belongs_to :user

  has_many :levels, :dependent => :destroy

  # Generate X cattles calling external scripts
  def generate_new_cattle
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
