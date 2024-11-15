module suibond::milestone {
  use std::string::{String};

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

  // ====================================================
  // ================= Constants =================

  // Duration
  // ============
  const EXTENDING_DURATION_EPOCHS: u64 = 5;

  // Milestone State
  // ============
  const ADDED: u64 = 0;
  const PROCESSING: u64 = 1;

  const EXPIRED: u64 = 2;
  const SUBMITTED: u64 = 3;

  const CONFIRMED: u64 = 4;
  const REJECTED: u64 = 5;

  // ====================================================
  // ================= Create Functions =================
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
  
  // ===========================================================
  // ================= Entry Related Functions =================
  
	// ===========================================
  // ================= Methods =================

  // Read
  // ============
  public fun CONST_EXTENDING_DURATION_EPOCHS(): u64 {
    return EXTENDING_DURATION_EPOCHS
  }

  public fun duration_epochs(milestone: &Milestone): u64 {
    milestone.duration_epochs
  }
  
  // Borrow
  // ============

  // Check
  // ============
  public fun is_expired(milestone: &mut Milestone, ctx: &mut TxContext): bool {
    milestone.deadline_epochs < ctx.epoch()
  }


  // Set
  // ============
  public fun set_deadline_epochs(milestone: &mut Milestone, ctx: &mut TxContext) {
    milestone.deadline_epochs = ctx.epoch() + duration_epochs(milestone);
  }

  public fun set_state_expired(milestone: &mut Milestone) {
    milestone.state = EXPIRED;
  }

  public fun set_state_processing(milestone: &mut Milestone) {
    milestone.state = PROCESSING;
  }

  public fun set_state_submitted(milestone: &mut Milestone) {
    milestone.state = SUBMITTED;
  }

  public fun set_state_confirmed(milestone: &mut Milestone) {
    milestone.state = CONFIRMED;
  }

  public fun set_state_rejected(milestone: &mut Milestone) {
    milestone.state = REJECTED;
  }
  
  // =============================================================
  // ================= Public-Mutative Functions =================
  public fun submit_milestone(milestone: &mut Milestone, milestone_submission_id: ID, ctx: &mut TxContext) {
    milestone.milestone_submission = option::some(milestone_submission_id);
    milestone.submitted_epochs = ctx.epoch();
    milestone.set_state_submitted();
  }

  public fun request_extend_deadline_of_milestone(milestone: &mut Milestone) {
    milestone.deadline_epochs = milestone.deadline_epochs + EXTENDING_DURATION_EPOCHS;
    milestone.is_extended = true;
  }

  // ==================================================
  // ================= TEST FUNCTIONS =================
}