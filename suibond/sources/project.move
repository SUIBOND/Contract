module suibond::project {
  use std::string::{String};
  use suibond::milestone::{Self, Milestone};
  use sui::coin::{Self, Coin};
  use sui::sui::{Self, SUI};

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
  
  const UNSUBMITTED: u64 = 0;
  const SUBMITTED: u64 = 1;
  const REJECTED: u64 = 2;
  const PROCESSING: u64 = 3;
  const COMPLETED: u64 = 4;


  // ================= METHODS =================
  

  public fun add_milestone( project: &mut Project, milestone: Milestone) {
      project.milestones.push_back(milestone)
  }

  public fun create_and_add_milestone(
    project: &mut Project,
    title: String,
    description: String,
    duration_epochs: u64,
    ctx: &mut TxContext) {
      let milestone_number = project.milestones.length();
      let milestone = milestone::new(
        milestone_number,
        title,
        description,
        duration_epochs,
        ctx
      );
      project.add_milestone(milestone);
  }

  public fun add_stake_amount(project: &mut Project, stake: &Coin<SUI>) {
    project.current_stake_amount = project.current_stake_amount + stake.balance().value();
  }

  public fun set_state_submitted(project: &mut Project) {
      project.state = SUBMITTED;
  }

  public fun set_state_rejected(project: &mut Project) {
      project.state = REJECTED;
  }

  public fun set_state_processing(project: &mut Project) {
      project.state = PROCESSING;
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
        state: UNSUBMITTED
      }
  }

}