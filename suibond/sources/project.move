module suibond::project {
  use std::string::{String};
  use suibond::milestone::{Milestone};

  public struct Project has key, store {
    id: UID,
    proposal: ID,

    title: String,
    description: String,

    grant_size: u64,
    current_stake_amount: u64,

    duration_epochs: u64,
    milestones: vector<Milestone>,
    current_processing_milestone_number: u64,

    state: u64
  }


  // ================= METHODS =================


  // ================= FUNCTIONS =================

}