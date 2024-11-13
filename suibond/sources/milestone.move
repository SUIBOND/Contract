module suibond::milestone {
  use std::string::{String};
  use std::option::{Self, Option};


  public struct Milestone has key, store {
    id: UID,
    milestone_number: u64,

    title: String,
    description: String,

    duration_epochs: u64,
    submitted_epochs: u64,
    deadline_epochs: u64,
    milestone_submission: Option<ID>,

    is_extended: bool,
    state: u64,
  }

  const EXTENDING_DURATION_EPOCHS: u64 = 5;

  const ADDED: u64 = 0;
  const EXPIRED: u64 = 1;
  const PROCESSING: u64 = 2;

  const SUBMITTED: u64 = 3;

  const REJECTED: u64 = 4;

  // ================= METHODS =================

  public fun CONST_EXTENDING_DURATION_EPOCHS(): u64 {
    return EXTENDING_DURATION_EPOCHS
  }

  public fun duration_epochs(milestone: &Milestone): u64 {
    milestone.duration_epochs
  }

  public fun set_milestone_state_processing(milestone: &mut Milestone) {
    milestone.state = PROCESSING;
  }

  public fun is_milestone_expired(milestone: &mut Milestone, ctx: &mut TxContext): bool {
    milestone.deadline_epochs < ctx.epoch()
  }

  public fun submit_milestone(milestone: &mut Milestone, milestone_submission_id: ID, ctx: &mut TxContext) {
    milestone.milestone_submission = option::some(milestone_submission_id);
    milestone.submitted_epochs = ctx.epoch();
    milestone.state = SUBMITTED;
  }

  public fun request_extend_deadline_of_milestone(milestone: &mut Milestone) {
    milestone.deadline_epochs = milestone.deadline_epochs + EXTENDING_DURATION_EPOCHS;
    milestone.is_extended = true;
  }


  // ================= FUNCTIONS =================

  public fun new(
    milestone_number: u64,
    title: String,
    description: String,
    duration_epochs: u64,
    ctx: &mut TxContext): Milestone {
      Milestone {
        id: object::new(ctx),
        milestone_number: milestone_number,
        title: title,
        description: description,
        duration_epochs: duration_epochs,
        submitted_epochs: 0,
        deadline_epochs: 0,
        milestone_submission: option::none(),
        state: ADDED,
        is_extended: false,
      }
  }
}