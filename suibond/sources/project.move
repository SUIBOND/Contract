module suibond::project {
  use std::string::{String};
  use suibond::milestone::{Self, Milestone};

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
  

  public fun add_milestone(
    project: &mut Project,
    milestone: Milestone) {
      project.milestones.push_back(milestone)
  }

  public fun create_and_add_milestone(
    project: &mut Project,
    milestone_number: u64,
    title: String,
    description: String,
    duration_epochs: u64,
    ctx: &mut TxContext) {
      let milestone = milestone::new(
        milestone_number,
        title,
        description,
        duration_epochs,
        ctx
      );
      project.add_milestone(milestone);
  }


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