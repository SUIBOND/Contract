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

  public fun new(
    proposal_id: ID,
    title: String,
    description: String,
    grant_size: u64,
    duration_epochs: u64,
    ctx: &mut TxContext): Project {
      Project{
        id: object::new(ctx),
        proposal: proposal_id,
        title: title,
        description: description,
        grant_size: grant_size,
        current_stake_amount: 0,
        duration_epochs: duration_epochs,
        milestones: vector<Milestone>[],
        current_processing_milestone_number: 0,
        state: 0
      }
  }

}